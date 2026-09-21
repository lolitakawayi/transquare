import 'package:flutter_test/flutter_test.dart';
import 'package:transquare/models/settings.dart';
import 'package:transquare/services/text_processor.dart';
import 'package:transquare/services/cache_service.dart';

void main() {
  group('TextProcessor', () {
    final textProcessor = TextProcessor();
    test('detects LaTeX formulas', () {
      final formulas = textProcessor.detectFormulas(r'$E=mc^2$ and $x^2$');
      expect(formulas.length, greaterThan(0));
    });

    test('detects citations', () {
      final citations = textProcessor.detectCitations('[1] and (Author, 2020)');
      expect(citations.length, greaterThan(0));
    });

    test('protects and unprotects formulas', () {
      const text = r'Mass-energy $E=mc^2$ equation';
      final protected = TextProcessor().protectFormulas(text);
      expect(protected, contains('<FORMULA>'));
      final unprotected = TextProcessor().unprotectFormulas(protected);
      expect(unprotected, equals(text));
    });

    test('protects and unprotects citations', () {
      const text = 'See [1] for details';
      final protected = TextProcessor().protectCitations(text);
      expect(protected, contains('<CITE>'));
      final unprotected = TextProcessor().unprotectCitations(protected);
      expect(unprotected, contains('[1]'));
    });
  });

  group('CacheService', () {
    test('stores and retrieves translations', () {
      final cache = CacheService(maxEntries: 10);
      final key = cache.generateKey('hello', 'Google', 'en', 'zh');
      expect(cache.get(key), isNull);

      cache.set(key, _createFakeResult('hello', '你好'));
      final cached = cache.get(key);
      expect(cached, isNotNull);
      expect(cached!.translatedText, equals('你好'));
    });

    test('evicts oldest entries when full', () {
      final cache = CacheService(maxEntries: 3);
      for (int i = 0; i < 5; i++) {
        final key = cache.generateKey('text$i', 'Google', 'en', 'zh');
        cache.set(key, _createFakeResult('text$i', 'result$i'));
      }
      expect(cache.size, lessThanOrEqualTo(3));
    });
  });

  group('AppSettings', () {
    test('serializes and deserializes correctly', () {
      final settings = AppSettings(
        engine: TranslationEngine.google,
        fontSize: 16.0,
        targetLang: 'zh',
      );
      final json = settings.toJson();
      final restored = AppSettings.fromJson(json);
      expect(restored.engine, equals(TranslationEngine.google));
      expect(restored.fontSize, equals(16.0));
      expect(restored.targetLang, equals('zh'));
    });
  });
}

dynamic _createFakeResult(String source, String translation) {
  return _FakeTranslationResult(source: source, translation: translation);
}

class _FakeTranslationResult {
  final String source;
  final String translation;
  final DateTime timestamp = DateTime.now();

  _FakeTranslationResult({required this.source, required this.translation});

  Map<String, dynamic> toJson() => {
        'sourceText': source,
        'translatedText': translation,
        'sourceLang': 'en',
        'targetLang': 'zh',
        'engine': 'Google',
        'timestamp': timestamp.toIso8601String(),
        'glossaryMatches': <String>[],
        'fromCache': false,
      };
}