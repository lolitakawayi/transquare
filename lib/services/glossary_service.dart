import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/glossary_entry.dart';

class GlossaryService {
  final List<GlossaryEntry> _entries = [];
  final _uuid = const Uuid();
  bool _dirty = false;

  List<GlossaryEntry> get entries => List.unmodifiable(_entries);

  int get count => _entries.length;

  void addEntry({
    required String sourceTerm,
    required String targetTerm,
    String? notes,
  }) {
    final now = DateTime.now();
    final entry = GlossaryEntry(
      id: _uuid.v4(),
      sourceTerm: sourceTerm.trim(),
      targetTerm: targetTerm.trim(),
      notes: notes?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _entries.add(entry);
    _dirty = true;
  }

  void updateEntry(GlossaryEntry updated) {
    final index = _entries.indexWhere((e) => e.id == updated.id);
    if (index >= 0) {
      _entries[index] = updated.copyWith(updatedAt: DateTime.now());
      _dirty = true;
    }
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _dirty = true;
  }

  void removeAll() {
    _entries.clear();
    _dirty = true;
  }

  Map<String, String> get glossaryMap {
    final map = <String, String>{};
    for (final entry in _entries) {
      map[entry.sourceTerm] = entry.targetTerm;
    }
    return map;
  }

  List<GlossaryEntry> search(String query) {
    final lower = query.toLowerCase();
    return _entries
        .where((e) =>
            e.sourceTerm.toLowerCase().contains(lower) ||
            e.targetTerm.toLowerCase().contains(lower) ||
            (e.notes?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  Future<int> importCsv(String csvContent) async {
    final rows = const CsvToListConverter().convert(csvContent);
    int imported = 0;
    final now = DateTime.now();
    for (final row in rows) {
      if (row.isEmpty) continue;
      final sourceTerm = row[0].toString().trim();
      if (sourceTerm.isEmpty) continue;
      final targetTerm =
          row.length > 1 ? row[1].toString().trim() : '';
      final notes = row.length > 2 ? row[2].toString().trim() : null;
      final existingIndex = _entries.indexWhere(
          (e) => e.sourceTerm.toLowerCase() == sourceTerm.toLowerCase());
      if (existingIndex >= 0) {
        _entries[existingIndex] = _entries[existingIndex].copyWith(
          targetTerm: targetTerm,
          notes: notes,
          updatedAt: now,
        );
      } else {
        _entries.add(GlossaryEntry(
          id: _uuid.v4(),
          sourceTerm: sourceTerm,
          targetTerm: targetTerm,
          notes: notes,
          createdAt: now,
          updatedAt: now,
        ));
      }
      imported++;
    }
    _dirty = true;
    return imported;
  }

  String exportCsv() {
    final rows = <List<String>>[
      ['sourceTerm', 'targetTerm', 'notes'],
      ..._entries.map((e) => e.toCsvRow()),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  Future<File> get _glossaryFile async {
    final dir = await getApplicationSupportDirectory();
    final appDir = Directory('${dir.path}/transquare');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/glossary.json');
  }

  Future<void> load() async {
    try {
      final file = await _glossaryFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> data = jsonDecode(content) as List<dynamic>;
        _entries.clear();
        for (final item in data) {
          _entries.add(GlossaryEntry.fromJson(item as Map<String, dynamic>));
        }
        _dirty = false;
      }
    } catch (_) {}
  }

  Future<void> save() async {
    if (!_dirty) return;
    try {
      final file = await _glossaryFile;
      final data = _entries.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
      _dirty = false;
    } catch (_) {}
  }
}