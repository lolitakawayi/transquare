import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';
import '../models/translation_result.dart';
import '../services/translation_service.dart';
import '../services/cache_service.dart';
import '../services/glossary_service.dart';
import '../services/vocabulary_service.dart';
import '../services/history_service.dart';
import '../services/text_processor.dart';
import '../l10n/strings.dart';

class AppProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();
  TranslationResult? _currentResult;
  String? _currentText;
  bool _isTranslating = false;
  String? _errorMessage;
  bool _isListening = true;

  final TranslationService translationService;
  final GlossaryService glossaryService;
  final VocabularyService vocabularyService;
  final HistoryService historyService;
  final TextProcessor textProcessor;

  AppProvider({
    TranslationService? translationService,
    GlossaryService? glossaryService,
    VocabularyService? vocabularyService,
    HistoryService? historyService,
    TextProcessor? textProcessor,
  })  : translationService = translationService ?? TranslationService(),
        glossaryService = glossaryService ?? GlossaryService(),
        vocabularyService = vocabularyService ?? VocabularyService(),
        historyService = historyService ?? HistoryService(),
        textProcessor = textProcessor ?? TextProcessor();

  AppSettings get settings => _settings;
  TranslationResult? get currentResult => _currentResult;
  String? get currentText => _currentText;
  bool get isTranslating => _isTranslating;
  String? get errorMessage => _errorMessage;
  bool get isListening => _isListening;

  Future<void> initialize() async {
    await glossaryService.load();
    await vocabularyService.load();
    await historyService.load();
    await _loadSettings();
    _applySettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('app_settings');
      if (json != null) {
        _settings =
            AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (_) {}
  }

  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', jsonEncode(_settings.toJson()));
      await _saveCache();
    } catch (_) {}
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'translation_cache', jsonEncode(translationService.cache.toJson()));
    } catch (_) {}
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('translation_cache');
      if (json != null) {
        translationService.cache
            .fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (_) {}
  }

  void _applySettings() {
    translationService.configure(
      engine: _settings.engine,
      googleApiKey: _settings.apiKeys.googleApiKey,
      microsoftApiKey: _settings.apiKeys.microsoftApiKey,
      deeplApiKey: _settings.apiKeys.deeplApiKey,
      baiduAppId: _settings.apiKeys.baiduAppId,
      baiduSecretKey: _settings.apiKeys.baiduSecretKey,
      proxyHost: _settings.proxyHost,
      proxyPort: _settings.proxyPort,
    );
    historyService.maxSize = _settings.maxHistorySize;
  }

  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    _applySettings();
    saveSettings();
    glossaryService.save();
    vocabularyService.save();
    historyService.save();
    notifyListeners();
  }

  void setEngine(TranslationEngine engine) {
    _settings = _settings.copyWith(engine: engine);
    _applySettings();
    saveSettings();
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    _settings = _settings.copyWith(language: language);
    saveSettings();
    notifyListeners();
  }

  void setApiKeys(ApiKeys keys) {
    _settings = _settings.copyWith(apiKeys: keys);
    _applySettings();
    saveSettings();
    notifyListeners();
  }

  void setFontSize(double size) {
    _settings = _settings.copyWith(fontSize: size);
    saveSettings();
    notifyListeners();
  }

  void togglePinned() {
    _settings = _settings.copyWith(windowPinned: !_settings.windowPinned);
    saveSettings();
    notifyListeners();
  }

  void toggleListening() {
    _isListening = !_isListening;
    notifyListeners();
  }

  Future<void> translate(String text) async {
    if (text.trim().isEmpty) return;

    _currentText = text;
    _isTranslating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final glossary = glossaryService.glossaryMap;

      final result = await translationService.translate(
        text,
        sourceLang: _settings.sourceLang,
        targetLang: _settings.targetLang,
        protectFormulasFlag: _settings.protectFormulas,
        protectCitationsFlag: _settings.protectCitations,
        glossary: glossary.isNotEmpty ? glossary : null,
        useCache: _settings.enableCache,
      );

      _currentResult = result;
      historyService.addEntry(result);
      historyService.save();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _currentResult = null;
    }

    _isTranslating = false;
    notifyListeners();
  }

  void addToVocabulary(TranslationResult result) {
    vocabularyService.addEntry(
      word: result.sourceText,
      translation: result.translatedText,
      sourceApp: 'Transquare',
    );
    vocabularyService.save();
    notifyListeners();
  }

  void clearCurrent() {
    _currentResult = null;
    _currentText = null;
    _errorMessage = null;
    notifyListeners();
  }

  void toggleVocabularyMastered(String id) {
    vocabularyService.toggleMastered(id);
    vocabularyService.save();
    notifyListeners();
  }

  void removeVocabularyEntry(String id) {
    vocabularyService.removeEntry(id);
    vocabularyService.save();
    notifyListeners();
  }

  @override
  void dispose() {
    glossaryService.save();
    vocabularyService.save();
    historyService.save();
    saveSettings();
    super.dispose();
  }
}