import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/strings.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _newestFirst = true;

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
        title: Text(L10n.t(lang, 'favorites.title')),
        centerTitle: false,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final lang2 = appProvider.settings.language.code;
          final history = appProvider.historyService;
          final entries = _searchQuery.isEmpty
              ? history.favorites
              : history.searchFavorites(_searchQuery);
          final sortedEntries = _newestFirst
              ? entries
              : entries.reversed.toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: L10n.t(lang2, 'favorites.search_hint'),
                          prefixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _newestFirst
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 18,
                      ),
                      tooltip: _newestFirst
                          ? '最新优先 (Latest first)'
                          : '最早优先 (Oldest first)',
                      onPressed: () =>
                          setState(() => _newestFirst = !_newestFirst),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '${history.favoritesCount} ${lang2 == 'zh' ? '条收藏' : 'favorites'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sortedEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_outline,
                                size: 48,
                                color: Theme.of(context).disabledColor),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? L10n.t(lang2, 'favorites.empty')
                                  : (lang2 == 'zh' ? '无匹配结果' : 'No matches'),
                              style: TextStyle(
                                  color: Theme.of(context).disabledColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: sortedEntries.length,
                        itemBuilder: (context, index) {
                          return _favoriteCard(
                              context, sortedEntries[index], appProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _favoriteCard(
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
              tooltip: L10n.t(lang, 'favorites.unfavorite'),
              onPressed: () {
                appProvider.historyService.removeFromFavorites(entry.id);
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
                        Clipboard.setData(
                            ClipboardData(text: result.translatedText));
                      },
                      icon: const Icon(Icons.content_copy, size: 14),
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