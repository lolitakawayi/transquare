import 'package:flutter/material.dart'; // Flutter Material Design 组件库
import 'package:flutter/services.dart'; // 系统服务（剪贴板 Clipboard）
import 'package:provider/provider.dart'; // Provider 状态管理
import '../../models/translation_result.dart'; // 翻译结果数据模型
import '../../providers/app_provider.dart'; // 应用全局状态提供者
import '../../l10n/strings.dart'; // 国际化字符串支持

import '../../services/tts_service.dart'; // TTS 语音朗读服务

/// 翻译结果卡片组件
///
/// 以纵向卡片形式展示单条翻译结果，包含原文、译文、
/// 翻译引擎标识、语言方向、缓存/实时标签以及底部操作按钮。
/// compact 模式仅隐藏头部标签栏，底部操作栏始终显示。
class TranslationCard extends StatelessWidget {
  /// 翻译结果数据
  final TranslationResult result;

  /// 是否使用紧凑模式（隐藏头部标签栏，底部操作栏始终显示）
  final bool compact;

  const TranslationCard({
    super.key,
    required this.result,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // 判断当前是否为暗色主题
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 获取主题主色调，用于高亮和边框
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 480), // 限制最大宽度，保持可读性
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 紧凑模式下隐藏头部（引擎标签、缓存/实时标签、语言方向）
          if (!compact) _buildHeader(context, primaryColor),
          // 原文展示区域
          _buildSourceText(context, isDark),
          const SizedBox(height: 8),
          // 译文展示区域
          _buildTranslatedText(context, isDark, primaryColor),
          const SizedBox(height: 12),
          _buildFooter(context),
        ],
      ),
    );
  }

  /// 构建卡片头部
  ///
  /// 显示翻译引擎名称标签、缓存/实时状态标签和语言方向（如"en → zh"）。
  Widget _buildHeader(BuildContext context, Color primaryColor) {
    final lang = context.read<AppProvider>().settings.language.code;
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // 翻译引擎标签：带主色调的半透明背景
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              result.engine,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // 缓存/实时状态标签：橙色=缓存，绿色=实时翻译
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: result.fromCache
                  ? Colors.orange.withValues(alpha: 0.15)
                  : Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              result.fromCache ? L10n.t(lang, 'card.cached') : L10n.t(lang, 'card.live'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color:
                    result.fromCache ? Colors.orange : Colors.green,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(), // 将语言方向推到行尾
          // 语言方向指示：如 "en → zh"
          Text(
            '${result.sourceLang} → ${result.targetLang}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建原文展示区域
  ///
  /// 以带背景和边框的容器展示源语言文本，文本可选中复制。
  Widget _buildSourceText(BuildContext context, bool isDark) {
    // 从 AppProvider 获取用户设置的字体大小
    final fontSize = context.watch<AppProvider>().settings.fontSize;

    return Container(
      width: double.infinity, // 撑满可用宽度
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // 半透明背景，与主题色融合
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: SelectableText(
        result.sourceText,
        style: TextStyle(
          fontSize: fontSize - 1, // 原文比译文略小，形成视觉层次
          color: isDark ? Colors.white70 : Colors.black87,
          height: 1.5, // 行高，提升可读性
        ),
      ),
    );
  }

  /// 构建译文展示区域
  ///
  /// 以带主色调背景和边框的容器展示翻译后的文本，文本可选中复制。
  Widget _buildTranslatedText(
      BuildContext context, bool isDark, Color primaryColor) {
    // 从 AppProvider 获取用户设置的字体大小
    final fontSize = context.watch<AppProvider>().settings.fontSize;

    return Container(
      width: double.infinity, // 撑满可用宽度
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // 主色调半透明背景，与原文区域形成视觉区分
        color: primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: SelectableText(
        result.translatedText,
        style: TextStyle(
          fontSize: fontSize, // 译文使用用户设置的字体大小
          color: isDark ? Colors.white : Colors.black87,
          height: 1.6, // 行高略大于原文，提升译文可读性
          fontWeight: FontWeight.w500, // 译文加粗，突出显示
        ),
      ),
    );
  }

  /// 构建底部操作栏
  ///
  /// 包含语音朗读、复制译文、添加到生词本和收藏四个操作按钮。
  Widget _buildFooter(BuildContext context) {
    final lang = context.read<AppProvider>().settings.language.code;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // 按钮靠右排列
      children: [
        // 语音朗读按钮
        _actionButton(
          context,
          icon: Icons.volume_up_outlined,
          tooltip: L10n.t(lang, 'tts.play'),
          onTap: () {
            final appProvider = context.read<AppProvider>();
            final langCode = TtsService.normalizeTtsLang(result.targetLang);
            appProvider.ttsService.speak(result.translatedText, language: langCode);
          },
        ),
        const SizedBox(width: 4),
        // 复制译文按钮
        _actionButton(
          context,
          icon: Icons.content_copy_outlined,
          tooltip: L10n.t(lang, 'card.copy_translation'),
          onTap: () {
            Clipboard.setData(
                ClipboardData(text: result.translatedText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(L10n.t(lang, 'card.copy_success')),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        // 添加到生词本按钮
        _actionButton(
          context,
          icon: Icons.bookmark_outline,
          tooltip: L10n.t(lang, 'card.add_to_vocabulary'),
          onTap: () {
            final appProvider = context.read<AppProvider>();
            appProvider.addToVocabulary(result);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(L10n.t(lang, 'card.vocab_success')),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        // 收藏按钮：收藏到收藏夹并加入生词本
        _actionButton(
          context,
          icon: Icons.star_outline,
          tooltip: L10n.t(lang, 'card.favorite'),
          onTap: () {
            final appProvider = context.read<AppProvider>();
            appProvider.historyService.favoriteLatest();
            appProvider.historyService.save();
            appProvider.addToVocabulary(result);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(L10n.t(lang, 'card.favorite_success')),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建单个操作按钮
  ///
  /// 封装了 Tooltip 提示、InkWell 点击效果和统一样式的操作按钮。
  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip, // 悬停时的提示文字
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6), // 水波纹圆角
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            // 半透明背景按钮
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ),
    );
  }
}