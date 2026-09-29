import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/strings.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
        title: Text(L10n.t(lang, 'history.title')),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: L10n.t(lang, 'history.clear_all'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(L10n.t(lang, 'history.confirm_clear')),
                  content: Text(lang == 'zh'
                      ? '确定清空全部翻译记录？'
                      : 'Delete all translation history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(L10n.t(lang, 'history.cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<AppProvider>()
                            .historyService
                            .clearAll();
                        Navigator.pop(ctx);
                      },
                      child: Text(L10n.t(lang, 'history.confirm')),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final lang2 = appProvider.settings.language.code;
          final history = appProvider.historyService;
          final entries = _searchQuery.isEmpty
              ? history.entries
              : history.search(_searchQuery);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: L10n.t(lang2, 'history.search_hint'),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history,
                                size: 48,
                                color: Theme.of(context).disabledColor),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? L10n.t(lang2, 'history.empty')
                                  : 'No matches found.',
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
                          return _historyCard(
                              context, entries[index], appProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _historyCard(
      BuildContext context, dynamic entry, AppProvider appProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = appProvider.settings.language.code;
    final result = entry.result;
    final isFav = entry.isFavorite;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            result.engine,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          result.sourceText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        subtitle: Text(
          _formatTimestamp(result.timestamp),
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFav ? Icons.star : Icons.star_outline,
                size: 16,
                color: isFav ? Colors.amber : null,
              ),
              onPressed: () {
                appProvider.historyService.toggleFavorite(entry.id);
                appProvider.historyService.save();
                appProvider.notifyListeners();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              onPressed: () {
                appProvider.historyService.removeEntry(entry.id);
                appProvider.historyService.save();
                appProvider.notifyListeners();
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    result.translatedText,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: result.translatedText));
                        },
                        icon:
                            const Icon(Icons.content_copy, size: 14),
                        label: Text(L10n.t(lang, 'history.copy'),
                            style: const TextStyle(fontSize: 11)),
                      ),
                      const Spacer(),
                      Text(
                        '${result.sourceLang} → ${result.targetLang}',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}