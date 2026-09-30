import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/history_entry.dart';
import '../models/translation_result.dart';

class HistoryService {
  final List<HistoryEntry> _entries = [];
  final _uuid = const Uuid();
  bool _dirty = false;
  int maxSize = 100;

  List<HistoryEntry> get entries =>
      List.unmodifiable(_entries.where((e) => !e.isFavorite));

  List<HistoryEntry> get favorites =>
      List.unmodifiable(_entries.where((e) => e.isFavorite));

  int get count => entries.length;

  int get favoritesCount => favorites.length;

  void addEntry(TranslationResult result) {
    final entry = HistoryEntry(
      id: _uuid.v4(),
      result: result,
    );
    _entries.insert(0, entry);

    _trimNonFavorites();
    _dirty = true;
  }

  void _trimNonFavorites() {
    final nonFavCount = _entries.where((e) => !e.isFavorite).length;
    int excess = nonFavCount - maxSize;
    if (excess <= 0) return;

    for (int i = _entries.length - 1; i >= 0 && excess > 0; i--) {
      if (!_entries[i].isFavorite) {
        _entries.removeAt(i);
        excess--;
      }
    }
  }

  void toggleFavorite(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _entries[index] = _entries[index].copyWith(
        isFavorite: !_entries[index].isFavorite,
      );
      _dirty = true;
    }
  }

  void addToFavorites(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _entries[index] = _entries[index].copyWith(isFavorite: true);
      _dirty = true;
    }
  }

  void favoriteLatest() {
    if (_entries.isEmpty) return;
    _entries[0] = _entries[0].copyWith(isFavorite: true);
    _dirty = true;
  }

  void removeFromFavorites(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index >= 0) {
      final entry = _entries[index].copyWith(isFavorite: false);
      _entries.removeAt(index);
      _entries.insert(0, entry);
      _dirty = true;
    }
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _dirty = true;
  }

  void clearAll() {
    _entries.removeWhere((e) => !e.isFavorite);
    _dirty = true;
  }

  List<HistoryEntry> search(String query) {
    final lower = query.toLowerCase();
    return _entries
        .where((e) =>
            !e.isFavorite &&
            (e.result.sourceText.toLowerCase().contains(lower) ||
                e.result.translatedText.toLowerCase().contains(lower)))
        .toList();
  }

  List<HistoryEntry> searchFavorites(String query) {
    final lower = query.toLowerCase();
    return _entries
        .where((e) =>
            e.isFavorite &&
            (e.result.sourceText.toLowerCase().contains(lower) ||
                e.result.translatedText.toLowerCase().contains(lower)))
        .toList();
  }

  Future<File> get _historyFile async {
    final dir = await getApplicationSupportDirectory();
    final appDir = Directory('${dir.path}/transquare');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/history.json');
  }

  Future<void> load() async {
    try {
      final file = await _historyFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> data = jsonDecode(content) as List<dynamic>;
        _entries.clear();
        for (final item in data) {
          _entries
              .add(HistoryEntry.fromJson(item as Map<String, dynamic>));
        }
        _dirty = false;
      }
    } catch (_) {}
  }

  Future<void> save() async {
    if (!_dirty) return;
    try {
      final file = await _historyFile;
      final data = _entries.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
      _dirty = false;
    } catch (_) {}
  }
}