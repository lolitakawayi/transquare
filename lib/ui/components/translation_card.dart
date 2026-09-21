import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/translation_result.dart';
import '../../providers/app_provider.dart';
import '../../l10n/strings.dart';

class TranslationCard extends StatelessWidget {
  final TranslationResult result;
  final bool compact;

  const TranslationCard({
    super.key,
    required this.result,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) _buildHeader(context, primaryColor),
          _buildSourceText(context, isDark),
          const SizedBox(height: 8),
          _buildTranslatedText(context, isDark, primaryColor),
          if (!compact) ...[
            const SizedBox(height: 12),
            _buildFooter(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    final lang = context.read<AppProvider>().settings.language.code;
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
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
          const Spacer(),
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

  Widget _buildSourceText(BuildContext context, bool isDark) {
    final fontSize = context.watch<AppProvider>().settings.fontSize;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
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
          fontSize: fontSize - 1,
          color: isDark ? Colors.white70 : Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTranslatedText(
      BuildContext context, bool isDark, Color primaryColor) {
    final fontSize = context.watch<AppProvider>().settings.fontSize;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: SelectableText(
        result.translatedText,
        style: TextStyle(
          fontSize: fontSize,
          color: isDark ? Colors.white : Colors.black87,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final lang = context.read<AppProvider>().settings.language.code;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _actionButton(
          context,
          icon: Icons.volume_up_outlined,
          tooltip: L10n.t(lang, 'tts.play'),
          onTap: () {},
        ),
        const SizedBox(width: 4),
        _actionButton(
          context,
          icon: Icons.content_copy_outlined,
          tooltip: L10n.t(lang, 'card.copy_translation'),
          onTap: () {
            final appProvider =
                context.read<AppProvider>();
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
        _actionButton(
          context,
          icon: Icons.bookmark_outline,
          tooltip: L10n.t(lang, 'card.add_to_vocabulary'),
          onTap: () {
            final appProvider =
                context.read<AppProvider>();
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
        _actionButton(
          context,
          icon: Icons.push_pin_outlined,
          tooltip: L10n.t(lang, 'floating.pin_window'),
          onTap: () {
            context.read<AppProvider>().togglePinned();
          },
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
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