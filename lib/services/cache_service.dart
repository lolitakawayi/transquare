import '../models/translation_result.dart';

class CacheService {
  final Map<String, TranslationResult> _cache = {};
  final int maxEntries;
  final List<String> _accessOrder = [];

  CacheService({this.maxEntries = 500});

  TranslationResult? get(String key) {
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
      _accessOrder.add(key);
      return _cache[key];
    }
    return null;
  }

  void set(String key, TranslationResult result) {
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
    }
    _cache[key] = result;
    _accessOrder.add(key);

    while (_cache.length > maxEntries) {
      final oldest = _accessOrder.removeAt(0);
      _cache.remove(oldest);
    }
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  int get size => _cache.length;

  bool containsKey(String key) => _cache.containsKey(key);

  String generateKey(String text, String engine, String sourceLang,
      String targetLang) {
    final normalized = text.trim().toLowerCase();
    return '${normalized}_${engine}_${sourceLang}_$targetLang';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    for (final entry in _cache.entries) {
      data[entry.key] = entry.value.toJson();
    }
    return data;
  }

  void fromJson(Map<String, dynamic> json) {
    _cache.clear();
    _accessOrder.clear();
    for (final entry in json.entries) {
      try {
        final result = TranslationResult.fromJson(
            entry.value as Map<String, dynamic>);
        _cache[entry.key] = result;
        _accessOrder.add(entry.key);
      } catch (_) {}
    }
  }
}