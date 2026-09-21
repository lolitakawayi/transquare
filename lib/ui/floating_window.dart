import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/app_provider.dart';
import '../services/text_processor.dart';
import '../l10n/strings.dart';
import 'components/translation_card.dart';
import 'components/side_by_side_view.dart';

class FloatingWindow extends StatefulWidget {
  final String? initialText;

  const FloatingWindow({
    super.key,
    this.initialText,
  });

  @override
  State<FloatingWindow> createState() => _FloatingWindowState();
}

class _FloatingWindowState extends State<FloatingWindow>
    with WindowListener {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedText;
  bool _showSideBySide = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initializeWindow();

    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _selectedText = widget.initialText;
      _textController.text = widget.initialText!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerTranslation();
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeWindow() async {
    await windowManager.setSize(const Size(500, 180));
    await windowManager.center();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSkipTaskbar(true);
  }

  Future<void> _triggerTranslation() async {
    final text = _selectedText ?? _textController.text.trim();
    if (text.isEmpty) return;

    final appProvider = context.read<AppProvider>();
    await appProvider.translate(text);
  }

  @override
  void onWindowClose() {
    windowManager.hide();
    context.read<AppProvider>().clearCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final hasContent = appProvider.currentResult != null ||
            appProvider.isTranslating ||
            appProvider.currentText != null;

        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E2E)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleBar(context, isDark, appProvider),
                  if (appProvider.isTranslating)
                    _buildLoadingState()
                  else if (appProvider.errorMessage != null)
                    _buildErrorState(appProvider, isDark)
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
                    _buildIdleState(isDark, appProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleBar(
      BuildContext context, bool isDark, AppProvider appProvider) {
    final lang = appProvider.settings.language.code;
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.translate,
                size: 16,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Transquare',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const Spacer(),
            if (appProvider.currentResult != null)
              IconButton(
                icon: Icon(
                  _showSideBySide
                      ? Icons.view_agenda_outlined
                      : Icons.view_column_outlined,
                  size: 16,
                ),
                tooltip: L10n.t(lang,
                    _showSideBySide ? 'floating.compact_view' : 'floating.side_by_side'),
                onPressed: () =>
                    setState(() => _showSideBySide = !_showSideBySide),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                    minWidth: 28, minHeight: 28),
              ),
            IconButton(
              icon: Icon(
                appProvider.settings.windowPinned
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                size: 16,
              ),
              tooltip: L10n.t(lang, 'floating.pin_window'),
              onPressed: () => appProvider.togglePinned(),
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () {
                appProvider.clearCurrent();
                windowManager.hide();
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

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 16),
          Text(
            L10n.t(context.read<AppProvider>().settings.language.code, 'floating.translating'),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppProvider appProvider, bool isDark) {
    final lang = appProvider.settings.language.code;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 32, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            appProvider.errorMessage ?? L10n.t(lang, 'error.unknown'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _triggerTranslation,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(L10n.t(lang, 'floating.retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState(bool isDark, AppProvider appProvider) {
    final lang = appProvider.settings.language.code;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 40,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.t(lang, 'floating.input_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
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