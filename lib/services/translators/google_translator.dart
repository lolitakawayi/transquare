import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_translator.dart';
import 'http_client_factory.dart';
import '../../models/translation_result.dart';

class GoogleTranslator extends BaseTranslator {
  final String? _apiKey;

  GoogleTranslator({String? apiKey}) : _apiKey = apiKey;

  @override
  String get engineName => 'Google';

  @override
  bool get requiresApiKey => true;

  @override
  String get apiKeyUrl =>
      'https://console.cloud.google.com/apis/credentials';

  @override
  String get apiDocUrl =>
      'https://cloud.google.com/translate/docs/reference/rest';

  @override
  Future<TranslationResult> translate(
    String text, {
    String sourceLang = 'auto',
    String targetLang = 'zh',
    String? proxyHost,
    int? proxyPort,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('Google API Key is required. Please configure it in settings.');
    }

    final uri = Uri.parse(
      'https://translation.googleapis.com/language/translate/v2'
      '?key=$_apiKey'
      '&q=${Uri.encodeComponent(text)}'
      '&target=$targetLang'
      '&format=text',
    );

    final client = createHttpClient(
      proxyHost: proxyHost,
      proxyPort: proxyPort,
    );
    try {
      final response = await client.get(uri);
      return _parseResponse(response, text, sourceLang, targetLang);
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
      throw Exception('Google Translate error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final translations = data['data']['translations'] as List<dynamic>;
    final translatedText = translations.first['translatedText'] as String;
    final detectedLang =
        translations.first['detectedSourceLanguage'] as String? ?? sourceLang;

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
    try {
      final uri = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2'
        '?key=$key'
        '&q=test'
        '&target=en',
      );
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}