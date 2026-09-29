import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/vocabulary_entry.dart';
import '../../l10n/strings.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyUnmastered = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final lang = appProvider.settings.language.code;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t(lang, 'vocab.title')),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: L10n.t(lang, 'vocab.export_anki'),
            onPressed: () {
              final data = context
                  .read<AppProvider>()
                  .vocabularyService
                  .exportAnki();
              Clipboard.setData(ClipboardData(text: data));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(L10n.t(lang, 'vocab.export_success'))),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: L10n.t(lang, 'vocab.export_csv'),
            onPressed: () {
              final data = context
                  .read<AppProvider>()
                  .vocabularyService
                  .exportCsv();
              Clipboard.setData(ClipboardData(text: data));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(L10n.t(lang, 'vocab.export_success'))),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final lang2 = appProvider.settings.language.code;
          final vocab = appProvider.vocabularyService;
          final entries = _searchQuery.isEmpty
              ? (_showOnlyUnmastered ? vocab.unmastered : vocab.entries)
              : vocab.search(_searchQuery);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: L10n.t(lang2, 'vocab.search_hint'),
                          prefixIcon:
                              const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(L10n.t(lang2, 'vocab.unmastered')),
                      selected: _showOnlyUnmastered,
                      onSelected: (v) =>
                          setState(() => _showOnlyUnmastered = v),
                      selectedColor:
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${vocab.count} ${lang2 == 'zh' ? '个单词' : 'words'} (${vocab.masteredCount} ${lang2 == 'zh' ? '已掌握' : 'mastered'})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_outlined,
                                size: 48,
                                color: Theme.of(context).disabledColor),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? L10n.t(lang2, 'vocab.empty')
                                  : 'No matches found.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).disabledColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _vocabularyCard(
                              context, entry, appProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _vocabularyCard(
      BuildContext context, VocabularyEntry entry, AppProvider appProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = appProvider.settings.language.code;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: entry.mastered
            ? BorderSide(
                color: Colors.green.withValues(alpha: 0.3),
              )
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
          entry.mastered ? Icons.check_circle : Icons.circle_outlined,
          color: entry.mastered ? Colors.green : null,
          size: 20,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.word,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration:
                      entry.mastered ? TextDecoration.lineThrough : null,
                  color: entry.mastered
                      ? (isDark ? Colors.white38 : Colors.black38)
                      : null,
                ),
              ),
            ),
            if (entry.translation != null) ...[
              const Icon(Icons.arrow_forward, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  entry.translation!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: entry.context != null
            ? Text(entry.context!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                entry.mastered ? Icons.undo : Icons.check,
                size: 16,
              ),
              tooltip: entry.mastered ? L10n.t(lang, 'vocab.mark_learning') : L10n.t(lang, 'vocab.mark_mastered'),
              onPressed: () {
                appProvider.toggleVocabularyMastered(entry.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              onPressed: () {
                appProvider.removeVocabularyEntry(entry.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}