import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_translator.dart';
import 'http_client_factory.dart';
import '../../models/translation_result.dart';

class DeepLTranslator extends BaseTranslator {
  final String? _apiKey;
  final bool _isFree;

  DeepLTranslator({String? apiKey, bool isFree = true})
      : _apiKey = apiKey,
        _isFree = isFree;

  @override
  String get engineName => 'DeepL';

  @override
  bool get requiresApiKey => true;

  @override
  String get apiKeyUrl => 'https://www.deepl.com/pro-api';

  @override
  String get apiDocUrl => 'https://www.deepl.com/docs-api';

  String get _baseUrl =>
      _isFree
          ? 'https://api-free.deepl.com/v2/translate'
          : 'https://api.deepl.com/v2/translate';

  @override
  Future<TranslationResult> translate(
    String text, {
    String sourceLang = 'auto',
    String targetLang = 'zh',
    String? proxyHost,
    int? proxyPort,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('DeepL API Key is required.');
    }

    final targetLangUpper = targetLang.toUpperCase();

    final uri = Uri.parse(_baseUrl);
    final headers = {
      'Authorization': 'DeepL-Auth-Key $_apiKey',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final body = {
      'text': text,
      'target_lang': targetLangUpper,
    };

    if (sourceLang != 'auto' && sourceLang.isNotEmpty) {
      body['source_lang'] = sourceLang.toUpperCase();
    }

    final client = createHttpClient(
      proxyHost: proxyHost,
      proxyPort: proxyPort,
    );
    try {
      final response = await client.post(uri, headers: headers, body: body);
      return _parseResponse(response, text, sourceLang, targetLang);
    } catch (e) {
      throw Exception('DeepL error: $e');
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
        'DeepL error (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final translations = data['translations'] as List<dynamic>;
    final item = translations.first as Map<String, dynamic>;
    final translatedText = item['text'] as String;
    final detectedLang =
        (item['detected_source_language'] as String?)?.toLowerCase() ??
            sourceLang;

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
          'https://api-free.deepl.com/v2/usage');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'DeepL-Auth-Key $key'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}