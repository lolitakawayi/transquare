import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_translator.dart';
import 'http_client_factory.dart';
import '../../models/translation_result.dart';

class GoogleFreeTranslator extends BaseTranslator {
  @override
  String get engineName => 'Google (Free)';

  @override
  bool get requiresApiKey => false;

  @override
  String get apiKeyUrl => '';

  @override
  String get apiDocUrl => '';

  @override
  Future<TranslationResult> translate(
    String text, {
    String sourceLang = 'auto',
    String targetLang = 'zh',
    String? proxyHost,
    int? proxyPort,
  }) async {
    final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx'
      '&sl=$sourceLang'
      '&tl=$targetLang'
      '&dt=t'
      '&q=${Uri.encodeComponent(text)}',
    );

    final client = createHttpClient(
      proxyHost: proxyHost,
      proxyPort: proxyPort,
    );
    try {
      final response = await client.get(uri);
      return _parseResponse(response, text, sourceLang, targetLang);
    } catch (e) {
      throw Exception('Google Free translate error: $e');
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
          'Google Free error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    final sentences = data[0] as List<dynamic>;

    final buffer = StringBuffer();
    for (final sentence in sentences) {
      buffer.write((sentence as List<dynamic>)[0] as String);
    }

    String detectedLang = sourceLang;
    if (data.length > 2 && data[2] != null) {
      detectedLang = data[2] as String;
    }

    return TranslationResult(
      sourceText: text,
      translatedText: buffer.toString(),
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