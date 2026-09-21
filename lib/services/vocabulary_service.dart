import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/vocabulary_entry.dart';

class VocabularyService {
  final List<VocabularyEntry> _entries = [];
  final _uuid = const Uuid();
  bool _dirty = false;

  List<VocabularyEntry> get entries => List.unmodifiable(_entries);

  List<VocabularyEntry> get unmastered =>
      _entries.where((e) => !e.mastered).toList();

  int get count => _entries.length;
  int get masteredCount => _entries.where((e) => e.mastered).length;

  void addEntry({
    required String word,
    String? translation,
    String? context,
    String? sourceApp,
  }) {
    final existingIndex =
        _entries.indexWhere((e) => e.word.toLowerCase() == word.toLowerCase());
    final now = DateTime.now();
    if (existingIndex >= 0) {
      _entries[existingIndex] = _entries[existingIndex].copyWith(
        translation: translation ?? _entries[existingIndex].translation,
        context: context,
        sourceApp: sourceApp,
        reviewedAt: now,
        reviewCount: _entries[existingIndex].reviewCount + 1,
      );
    } else {
      _entries.add(VocabularyEntry(
        id: _uuid.v4(),
        word: word.trim(),
        translation: translation?.trim(),
        context: context?.trim(),
        sourceApp: sourceApp?.trim(),
        addedAt: now,
        reviewedAt: now,
      ));
    }
    _dirty = true;
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _dirty = true;
  }

  void toggleMastered(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _entries[index] = _entries[index].copyWith(
        mastered: !_entries[index].mastered,
        reviewedAt: DateTime.now(),
        reviewCount: _entries[index].reviewCount + 1,
      );
      _dirty = true;
    }
  }

  bool contains(String word) {
    return _entries
        .any((e) => e.word.toLowerCase() == word.trim().toLowerCase());
  }

  List<VocabularyEntry> search(String query) {
    final lower = query.toLowerCase();
    return _entries
        .where((e) =>
            e.word.toLowerCase().contains(lower) ||
            (e.translation?.toLowerCase().contains(lower) ?? false) ||
            (e.context?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  String exportCsv() {
    final buffer = StringBuffer();
    buffer.writeln('word,translation,context,source,added,mastered');
    for (final entry in _entries) {
      buffer.writeln(entry.toCsvRow().join(','));
    }
    return buffer.toString();
  }

  String exportAnki() {
    final buffer = StringBuffer();
    buffer.writeln('#separator:tab');
    buffer.writeln('#html:true');
    buffer.writeln('#tags:transquare');
    for (final entry in _entries) {
      buffer.writeln('${entry.word}\t${entry.translation ?? ''}');
    }
    return buffer.toString();
  }

  Future<File> get _vocabularyFile async {
    final dir = await getApplicationSupportDirectory();
    final appDir = Directory('${dir.path}/transquare');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/vocabulary.json');
  }

  Future<void> load() async {
    try {
      final file = await _vocabularyFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> data = jsonDecode(content) as List<dynamic>;
        _entries.clear();
        for (final item in data) {
          _entries
              .add(VocabularyEntry.fromJson(item as Map<String, dynamic>));
        }
        _dirty = false;
      }
    } catch (_) {}
  }

  Future<void> save() async {
    if (!_dirty) return;
    try {
      final file = await _vocabularyFile;
      final data = _entries.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
      _dirty = false;
    } catch (_) {}
  }
}