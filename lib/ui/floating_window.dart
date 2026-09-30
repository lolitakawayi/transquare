import 'package:flutter/material.dart'; // Flutter Material Design 组件库
import 'package:provider/provider.dart'; // Provider 状态管理，用于响应式获取 AppProvider
import 'package:window_manager/window_manager.dart'; // 桌面窗口管理，控制拖拽和置顶
import '../providers/app_provider.dart'; // 应用全局状态提供者（翻译状态、设置等）
import '../services/text_processor.dart'; // 文本处理服务
import '../l10n/strings.dart'; // 国际化字符串支持
import 'components/translation_card.dart'; // 翻译结果卡片组件（纵向布局）
import 'components/side_by_side_view.dart'; // 翻译结果并排对比视图组件

/// 悬浮翻译窗口 - 应用的核心翻译界面
///
/// 支持从外部传入初始文本自动翻译、窗口拖拽移动、始终置顶、
/// 翻译结果的卡片/并排双模式展示、错误重试等功能。
class FloatingWindow extends StatefulWidget {
  /// 外部传入的初始文本，非空时窗口打开后自动触发翻译
  final String? initialText;

  /// 窗口关闭回调，由父组件处理窗口隐藏/销毁逻辑
  final VoidCallback? onClose;

  const FloatingWindow({
    super.key,
    this.initialText,
    this.onClose,
  });

  @override
  State<FloatingWindow> createState() => _FloatingWindowState();
}

class _FloatingWindowState extends State<FloatingWindow> {
  /// 文本编辑控制器，管理输入框的文本内容
  final _textController = TextEditingController();

  /// 焦点节点，管理输入框的焦点状态
  final _focusNode = FocusNode();

  /// 用户选中或传入的待翻译文本
  String? _selectedText;

  /// 翻译结果展示模式：false=卡片视图, true=并排对比视图
  bool _showSideBySide = false;

  @override
  void initState() {
    super.initState();

    // 如果接收到外部传入的初始文本，保存并在首帧渲染后自动触发翻译
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _selectedText = widget.initialText;
      _textController.text = widget.initialText!;
      // 使用 addPostFrameCallback 确保 context 在 build 完成后可用
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerTranslation();
      });
    }
  }

  @override
  void dispose() {
    // 释放控制器和焦点节点占用的资源，防止内存泄漏
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 触发翻译的核心方法
  ///
  /// 优先使用 _selectedText，为空则从输入控制器获取文本。
  /// 文本为空时直接返回，不执行翻译。
  Future<void> _triggerTranslation() async {
    final text = _selectedText ?? _textController.text.trim();
    if (text.isEmpty) return;

    // 通过 Provider 获取 AppProvider 并调用 translate 方法
    // translate 内部会更新 isTranslating、currentResult、errorMessage 等状态
    final appProvider = context.read<AppProvider>();
    await appProvider.translate(text);
  }

  @override
  Widget build(BuildContext context) {
    // Consumer<AppProvider> 监听 AppProvider 变化，任何翻译状态改变都会触发重绘
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        // 判断当前是否为暗色主题
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // 判断是否有内容需要展示（翻译结果、翻译中、或有当前文本）
        final hasContent = appProvider.currentResult != null ||
            appProvider.isTranslating ||
            appProvider.currentText != null;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              // 根据主题切换背景色
              color: isDark
                  ? const Color(0xFF1E1E2E)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                // 外层阴影：较大的模糊和偏移，模拟远距离投影
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                // 内层阴影：较小的模糊和偏移，模拟近距离投影
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // 裁剪圆角，防止子组件溢出
              child: Column(
                children: [
                  // 标题栏：始终显示，包含拖拽、置顶、关闭按钮
                  _buildTitleBar(context, isDark, appProvider),

                  // 根据当前状态显示不同的内容区域
                  if (appProvider.isTranslating)
                    _buildLoadingState() // 翻译进行中：显示加载指示器
                  else if (appProvider.errorMessage != null)
                    _buildErrorState(appProvider, isDark) // 翻译出错：显示错误信息和重试按钮
                  else if (appProvider.currentResult != null)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _showSideBySide
                            ? SideBySideView(
                                result: appProvider.currentResult!)
                            : TranslationCard(
                                result: appProvider.currentResult!),
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: _buildIdleState(isDark, appProvider), // 空闲状态：显示欢迎提示
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建窗口标题栏
  ///
  /// 包含应用图标和名称、视图切换按钮（有结果时显示）、
  /// 窗口置顶切换按钮和关闭按钮。
  /// 整个标题栏可拖拽移动窗口。
  Widget _buildTitleBar(
      BuildContext context, bool isDark, AppProvider appProvider) {
    final lang = appProvider.settings.language.code;
    return GestureDetector(
      // 拖拽手势 → 调用 windowManager 开始窗口拖拽
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          // 标题栏半透明背景，与主题色融合
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            // 翻译图标
            Icon(Icons.translate,
                size: 16,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            // 应用名称
            Text(
              'Transquare',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const Spacer(), // 将右侧按钮推到行尾

            // 视图切换按钮：仅在有翻译结果时显示
            if (appProvider.currentResult != null)
              IconButton(
                icon: Icon(
                  // 当前为并排视图时显示"切换到卡片"图标，反之显示"切换到并排"图标
                  _showSideBySide
                      ? Icons.view_agenda_outlined
                      : Icons.view_column_outlined,
                  size: 16,
                ),
                tooltip: L10n.t(lang,
                    _showSideBySide ? 'floating.compact_view' : 'floating.side_by_side'),
                onPressed: () =>
                    setState(() => _showSideBySide = !_showSideBySide), // 切换视图模式
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                    minWidth: 28, minHeight: 28),
              ),

            // 窗口置顶切换按钮
            IconButton(
              icon: Icon(
                // 根据当前置顶状态显示实心/空心图钉图标
                appProvider.settings.windowPinned
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                size: 16,
              ),
              tooltip: L10n.t(lang, 'floating.pin_window'),
              onPressed: () {
                final newPinned = !appProvider.settings.windowPinned;
                appProvider.togglePinned(); // 更新 Provider 中的置顶状态
                windowManager.setAlwaysOnTop(newPinned); // 设置窗口是否始终置顶
              },
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
            ),

            // 关闭按钮
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () {
                widget.onClose?.call(); // 触发父组件的关闭回调
              },
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建翻译加载状态界面
  ///
  /// 显示一个居中的旋转加载指示器和"正在翻译…"文字提示。
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 旋转加载指示器
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 16),
          // 加载提示文字
          Text(
            L10n.t(context.read<AppProvider>().settings.language.code, 'floating.translating'),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 构建翻译错误状态界面
  ///
  /// 显示错误图标、错误信息文本和重试按钮。
  Widget _buildErrorState(AppProvider appProvider, bool isDark) {
    final lang = appProvider.settings.language.code;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 错误图标
          Icon(Icons.error_outline, size: 32, color: Colors.red.shade300),
          const SizedBox(height: 12),
          // 错误信息文本：优先显示 Provider 中的错误信息，否则显示通用未知错误
          Text(
            appProvider.errorMessage ?? L10n.t(lang, 'error.unknown'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          // 重试按钮：点击后重新触发翻译
          TextButton.icon(
            onPressed: _triggerTranslation,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(L10n.t(lang, 'floating.retry')),
          ),
        ],
      ),
    );
  }

  /// 构建空闲状态界面
  ///
  /// 当没有翻译内容时显示，包含装饰图标、提示文字和当前使用的翻译引擎名称。
  Widget _buildIdleState(bool isDark, AppProvider appProvider) {
    final lang = appProvider.settings.language.code;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 装饰性闪光图标
          Icon(
            Icons.auto_awesome,
            size: 40,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          // 输入提示文字
          Text(
            L10n.t(lang, 'floating.input_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          // 当前翻译引擎名称
          Text(
              appProvider.translationService.currentEngineName,
              style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}