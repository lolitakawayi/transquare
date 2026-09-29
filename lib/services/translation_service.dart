import '../models/translation_result.dart';
import '../models/settings.dart';
import 'cache_service.dart';
import 'text_processor.dart';
import 'translators/base_translator.dart';
import 'translators/google_translator.dart';
import 'translators/microsoft_translator.dart';
import 'translators/deepl_translator.dart';
import 'translators/baidu_translator.dart';
import 'translators/google_free_translator.dart';
import 'translators/mymemory_translator.dart';

class TranslationService {
  final CacheService cache;
  final TextProcessor textProcessor;
  BaseTranslator? _currentTranslator;
  TranslationEngine? _currentEngine;
  String? _apiKey;
  String? _proxyHost;
  int? _proxyPort;

  TranslationService({
    CacheService? cache,
    TextProcessor? textProcessor,
  })  : cache = cache ?? CacheService(),
        textProcessor = textProcessor ?? TextProcessor();

  void configure({
    required TranslationEngine engine,
    String? googleApiKey,
    String? microsoftApiKey,
    String? deeplApiKey,
    String? baiduAppId,
    String? baiduSecretKey,
    String? proxyHost,
    int? proxyPort,
  }) {
    if (_currentEngine != engine || _apiKey != _getKeyForEngine(engine, googleApiKey, microsoftApiKey, deeplApiKey, baiduAppId, baiduSecretKey)) {
      _currentTranslator = _createTranslator(
        engine,
        googleApiKey: googleApiKey,
        microsoftApiKey: microsoftApiKey,
        deeplApiKey: deeplApiKey,
        baiduAppId: baiduAppId,
        baiduSecretKey: baiduSecretKey,
      );
      _currentEngine = engine;
      _apiKey = _getKeyForEngine(engine, googleApiKey, microsoftApiKey, deeplApiKey, baiduAppId, baiduSecretKey);
    }
    _proxyHost = proxyHost;
    _proxyPort = proxyPort;
  }

  BaseTranslator _createTranslator(
    TranslationEngine engine, {
    String? googleApiKey,
    String? microsoftApiKey,
    String? deeplApiKey,
    String? baiduAppId,
    String? baiduSecretKey,
  }) {
    switch (engine) {
      case TranslationEngine.google:
        return GoogleTranslator(apiKey: googleApiKey);
      case TranslationEngine.microsoft:
        return MicrosoftTranslator(apiKey: microsoftApiKey);
      case TranslationEngine.deepl:
        return DeepLTranslator(apiKey: deeplApiKey);
      case TranslationEngine.baidu:
        return BaiduTranslator(appId: baiduAppId, secretKey: baiduSecretKey);
      case TranslationEngine.googleFree:
        return GoogleFreeTranslator();
      case TranslationEngine.mymemory:
        return MyMemoryTranslator();
    }
  }

  String? _getKeyForEngine(
    TranslationEngine engine,
    String? googleApiKey,
    String? microsoftApiKey,
    String? deeplApiKey,
    String? baiduAppId,
    String? baiduSecretKey,
  ) {
    switch (engine) {
      case TranslationEngine.google:
        return googleApiKey;
      case TranslationEngine.microsoft:
        return microsoftApiKey;
      case TranslationEngine.deepl:
        return deeplApiKey;
      case TranslationEngine.baidu:
        return '$baiduAppId:$baiduSecretKey';
      case TranslationEngine.googleFree:
      case TranslationEngine.mymemory:
        return null;
    }
  }

  Future<TranslationResult> translate(
    String text, {
    required String sourceLang,
    required String targetLang,
    bool protectFormulasFlag = true,
    bool protectCitationsFlag = true,
    Map<String, String>? glossary,
    bool useCache = true,
  }) async {
    if (_currentTranslator == null) {
      throw Exception('Translation service not configured. Please select an engine in settings.');
    }

    final cacheKey = cache.generateKey(
      text,
      _currentTranslator!.engineName,
      sourceLang,
      targetLang,
    );

    if (useCache) {
      final cached = cache.get(cacheKey);
      if (cached != null) {
        return cached.copyWith(fromCache: true);
      }
    }

    final processed = textProcessor.preprocessText(
      text,
      protectFormulasFlag: protectFormulasFlag,
      protectCitationsFlag: protectCitationsFlag,
      glossary: glossary,
    );

    final result = await _currentTranslator!.translate(
      processed,
      sourceLang: sourceLang,
      targetLang: targetLang,
      proxyHost: _proxyHost,
      proxyPort: _proxyPort,
    );

    final postProcessed = textProcessor.postprocessText(
      result.translatedText,
      glossary: glossary,
    );

    final finalResult = result.copyWith(translatedText: postProcessed);

    if (useCache) {
      cache.set(cacheKey, finalResult);
    }

    return finalResult;
  }

  String get currentEngineName =>
      _currentTranslator?.engineName ?? 'None';

  bool get isConfigured =>
      _currentTranslator != null &&
      (!_currentTranslator!.requiresApiKey || (_apiKey != null && _apiKey!.isNotEmpty));
}