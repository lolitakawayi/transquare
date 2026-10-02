import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:excel/excel.dart';
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

  Future<int> importXlsx(List<int> bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);

    final sharedStrings = <String>[];
    final ssFile = archive.findFile('xl/sharedStrings.xml');
    if (ssFile != null) {
      final ssXml = XmlDocument.parse(utf8.decode(ssFile.content as List<int>));
      for (final si in ssXml.findAllElements('si')) {
        sharedStrings.add(_sharedStringValue(si));
      }
    }

    int imported = 0;
    final now = DateTime.now();

    for (final file in archive.files) {
      if (!file.name.startsWith('xl/worksheets/sheet')) continue;

      final sheetXml = XmlDocument.parse(utf8.decode(file.content as List<int>));
      for (final row in sheetXml.findAllElements('row')) {
        final cells = <XmlElement>[
          for (final c in row.findAllElements('c')) c,
        ];
        cells.sort((a, b) => _columnIndex(a).compareTo(_columnIndex(b)));

        if (cells.isEmpty) continue;
        final sourceTerm =
            _cellStringValue(cells[0], sharedStrings).trim();
        if (sourceTerm.isEmpty) continue;
        final targetTerm = cells.length > 1
            ? _cellStringValue(cells[1], sharedStrings).trim()
            : '';

        final existingIndex =
            _entries.indexWhere((e) => e.sourceTerm == sourceTerm);
        if (existingIndex >= 0) {
          _entries[existingIndex] = _entries[existingIndex].copyWith(
            targetTerm: targetTerm,
            updatedAt: now,
          );
        } else {
          _entries.add(GlossaryEntry(
            id: _uuid.v4(),
            sourceTerm: sourceTerm,
            targetTerm: targetTerm,
            createdAt: now,
            updatedAt: now,
          ));
        }
        imported++;
      }
    }
    _dirty = true;
    return imported;
  }

  String _sharedStringValue(XmlElement si) {
    final t = si.findAllElements('t').firstOrNull;
    if (t != null && t.innerText.isNotEmpty) return t.innerText;

    final runs = <String>[];
    for (final r in si.findAllElements('r')) {
      final rt = r.findAllElements('t').firstOrNull;
      if (rt != null) runs.add(rt.innerText);
    }
    return runs.join();
  }

  String _cellStringValue(XmlElement cell, List<String> sharedStrings) {
    final t = cell.getAttribute('t');
    if (t == 's') {
      final v = cell.findAllElements('v').firstOrNull;
      if (v == null) return '';
      final idx = int.tryParse(v.innerText);
      if (idx == null || idx >= sharedStrings.length) return '';
      return sharedStrings[idx];
    }
    if (t == 'inlineStr') {
      final isEl = cell.findAllElements('is').firstOrNull;
      if (isEl == null) return '';
      final tEl = isEl.findAllElements('t').firstOrNull;
      return tEl?.innerText ?? '';
    }
    if (t == 'str') {
      return cell.findAllElements('v').firstOrNull?.innerText ?? '';
    }
    final v = cell.findAllElements('v').firstOrNull;
    return v?.innerText ?? '';
  }

  int _columnIndex(XmlElement cell) {
    final r = cell.getAttribute('r') ?? '';
    final letters = r.replaceAll(RegExp(r'\d'), '');
    int result = 0;
    for (int i = 0; i < letters.length; i++) {
      result = result * 26 + (letters.codeUnitAt(i) - 0x41 + 1);
    }
    return result;
  }

  List<int> exportXlsx() {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    for (final entry in _entries) {
      sheet.appendRow([TextCellValue(entry.sourceTerm), TextCellValue(entry.targetTerm)]);
    }
    return excel.encode() ?? [];
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