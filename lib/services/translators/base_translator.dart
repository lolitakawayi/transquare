import '../../models/translation_result.dart';

abstract class BaseTranslator {
  String get engineName;
  bool get requiresApiKey;

  Future<TranslationResult> translate(
    String text, {
    String sourceLang = 'auto',
    String targetLang = 'zh',
    String? proxyHost,
    int? proxyPort,
  });

  Future<bool> validateApiKey(String key);

  String get apiKeyUrl;
  String get apiDocUrl;
}