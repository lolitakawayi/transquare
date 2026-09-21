import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/translation_result.dart';
import '../../providers/app_provider.dart';
import '../../l10n/strings.dart';

class SideBySideView extends StatelessWidget {
  final TranslationResult result;

  const SideBySideView({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSize = context.watch<AppProvider>().settings.fontSize;
    final lang = context.watch<AppProvider>().settings.language.code;

    final sourceLines = result.sourceText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final translatedLines = result.translatedText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final maxLines = sourceLines.length > translatedLines.length
        ? sourceLines.length
        : translatedLines.length;

    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${L10n.t(lang, 'sbs.original')} (${result.sourceLang})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${L10n.t(lang, 'sbs.translation')} (${result.targetLang})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(maxLines, (index) {
            final sourceLine = index < sourceLines.length ? sourceLines[index] : '';
            final translatedLine = index < translatedLines.length ? translatedLines[index] : '';
            final isLast = index == maxLines - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        sourceLine,
                        style: TextStyle(
                          fontSize: fontSize - 1,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        translatedLine,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}