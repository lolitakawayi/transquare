import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_translator.dart';
import 'http_client_factory.dart';
import '../../models/translation_result.dart';

class MyMemoryTranslator extends BaseTranslator {
  @override
  String get engineName => 'MyMemory';

  @override
  bool get requiresApiKey => false;

  @override
  String get apiKeyUrl => '';

  @override
  String get apiDocUrl => 'https://mymemory.translated.net/doc/spec.php';

  @override
  Future<TranslationResult> translate(
    String text, {
    String sourceLang = 'auto',
    String targetLang = 'zh',
    String? proxyHost,
    int? proxyPort,
  }) async {
    final langPair = sourceLang == 'auto' ? 'auto|$targetLang' : '$sourceLang|$targetLang';

    final uri = Uri.parse(
      'https://api.mymemory.translated.net/get'
      '?q=${Uri.encodeComponent(text)}'
      '&langpair=${Uri.encodeComponent(langPair)}',
    );

    final client = createHttpClient(
      proxyHost: proxyHost,
      proxyPort: proxyPort,
    );
    try {
      final response = await client.get(uri);
      return _parseResponse(response, text, sourceLang, targetLang);
    } catch (e) {
      throw Exception('MyMemory translate error: $e');
    } finally {
      client.close();
    }
  }

  TranslationResult _parseResponse(
    http.Response response,
    String text,
    String sourceLang,
    String targetLang,
  ) {
    if (response.statusCode != 200) {
      throw Exception(
          'MyMemory error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final responseData = data['responseData'] as Map<String, dynamic>;
    final translatedText = responseData['translatedText'] as String?;

    if (translatedText == null || translatedText.isEmpty) {
      final match = responseData['match'] as String? ?? '0';
      throw Exception(
          'MyMemory returned no translation (match: $match). '
          'The text may be too long or the language pair is unsupported.');
    }

    String detectedLang = sourceLang;
    final detectedData = responseData['detectedLanguage'] as String?;
    if (detectedData != null && detectedData.isNotEmpty) {
      detectedLang = detectedData;
    }

    return TranslationResult(
      sourceText: text,
      translatedText: translatedText,
      sourceLang: detectedLang,
      targetLang: targetLang,
      engine: engineName,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<bool> validateApiKey(String key) async {
    return true;
  }
}