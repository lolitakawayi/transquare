import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_translator.dart';
import 'http_client_factory.dart';
import '../../models/translation_result.dart';

class MicrosoftTranslator extends BaseTranslator {
  final String? _apiKey;
  final String _region;

  MicrosoftTranslator({String? apiKey, String? region})
      : _apiKey = apiKey,
        _region = region ?? 'global';

  @override
  String get engineName => 'Microsoft';

  @override
  bool get requiresApiKey => true;

  @override
  String get apiKeyUrl =>
      'https://portal.azure.com/#create/Microsoft.CognitiveServicesTextTranslation';

  @override
  String get apiDocUrl =>
      'https://learn.microsoft.com/en-us/azure/cognitive-services/translator/reference/v3-0-translate';

  @override
  Future<TranslationResult> translate(
    String text, {
    String sourceLang = 'auto',
    String targetLang = 'zh',
    String? proxyHost,
    int? proxyPort,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('Microsoft Translator API Key is required.');
    }

    final uri = Uri.parse(
      'https://api.cognitive.microsofttranslator.com/translate'
      '?api-version=3.0'
      '&to=$targetLang',
    );

    final headers = {
      'Ocp-Apim-Subscription-Key': _apiKey,
      'Ocp-Apim-Subscription-Region': _region,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode([
      {'Text': text}
    ]);

    final client = createHttpClient(
      proxyHost: proxyHost,
      proxyPort: proxyPort,
    );
    try {
      final response = await client.post(uri, headers: headers, body: body);
      return _parseResponse(response, text, sourceLang, targetLang);
    } catch (e) {
      throw Exception('Microsoft Translator error: $e');
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
        'Microsoft Translator error (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    final item = data.first as Map<String, dynamic>;
    final translations =
        item['translations'] as List<dynamic>;
    final translatedText =
        translations.first['text'] as String;
    final detectedLang =
        item['detectedLanguage']?['language'] as String? ?? sourceLang;

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
        'https://api.cognitive.microsofttranslator.com/translate'
        '?api-version=3.0&to=en',
      );
      final response = await http.post(
        uri,
        headers: {
          'Ocp-Apim-Subscription-Key': key,
          'Content-Type': 'application/json',
        },
        body: jsonEncode([{'Text': 'test'}]),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}