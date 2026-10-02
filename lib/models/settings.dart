enum TranslationEngine {
  google,
  microsoft,
  deepl,
  baidu,
  googleFree,
  mymemory,
}

enum AppThemeMode {
  system,
  light,
  dark,
}

/// UI language selection
enum AppLanguage {
  chinese,
  english;

  String get code {
    switch (this) {
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.english:
        return 'en';
    }
  }

  static AppLanguage fromCode(String code) {
    switch (code) {
      case 'en':
        return AppLanguage.english;
      case 'zh':
      default:
        return AppLanguage.chinese;
    }
  }
}

class ApiKeys {
  final String? googleApiKey;
  final String? microsoftApiKey;
  final String? deeplApiKey;
  final String? baiduAppId;
  final String? baiduSecretKey;

  const ApiKeys({
    this.googleApiKey,
    this.microsoftApiKey,
    this.deeplApiKey,
    this.baiduAppId,
    this.baiduSecretKey,
  });

  ApiKeys copyWith({
    String? googleApiKey,
    String? microsoftApiKey,
    String? deeplApiKey,
    String? baiduAppId,
    String? baiduSecretKey,
  }) {
    return ApiKeys(
      googleApiKey: googleApiKey ?? this.googleApiKey,
      microsoftApiKey: microsoftApiKey ?? this.microsoftApiKey,
      deeplApiKey: deeplApiKey ?? this.deeplApiKey,
      baiduAppId: baiduAppId ?? this.baiduAppId,
      baiduSecretKey: baiduSecretKey ?? this.baiduSecretKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'googleApiKey': googleApiKey,
        'microsoftApiKey': microsoftApiKey,
        'deeplApiKey': deeplApiKey,
        'baiduAppId': baiduAppId,
        'baiduSecretKey': baiduSecretKey,
      };

  factory ApiKeys.fromJson(Map<String, dynamic> json) => ApiKeys(
        googleApiKey: json['googleApiKey'] as String?,
        microsoftApiKey: json['microsoftApiKey'] as String?,
        deeplApiKey: json['deeplApiKey'] as String?,
        baiduAppId: json['baiduAppId'] as String?,
        baiduSecretKey: json['baiduSecretKey'] as String?,
      );
}

class AppSettings {
  final TranslationEngine engine;
  final AppThemeMode themeMode;
  final AppLanguage language;
  final double fontSize;
  final bool windowPinned;
  final double windowOpacity;
  final bool autoSpeak;
  final bool enableCache;
  final int maxHistorySize;
  final bool protectFormulas;
  final bool protectCitations;
  final String sourceLang;
  final String targetLang;
  final String hotkeyModifiers;
  final String hotkeyKey;
  final bool enableMiddleMouse;
  final String? proxyHost;
  final int? proxyPort;
  final ApiKeys apiKeys;

  const AppSettings({
    this.engine = TranslationEngine.googleFree,
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.chinese,
    this.fontSize = 14.0,
    this.windowPinned = false,
    this.windowOpacity = 0.95,
    this.autoSpeak = false,
    this.enableCache = true,
    this.maxHistorySize = 100,
    this.protectFormulas = true,
    this.protectCitations = true,
    this.sourceLang = 'auto',
    this.targetLang = 'zh',
    this.hotkeyModifiers = 'Control+Shift',
    this.hotkeyKey = 'T',
    this.enableMiddleMouse = false,
    this.proxyHost,
    this.proxyPort,
    this.apiKeys = const ApiKeys(),
  });

  AppSettings copyWith({
    TranslationEngine? engine,
    AppThemeMode? themeMode,
    AppLanguage? language,
    double? fontSize,
    bool? windowPinned,
    double? windowOpacity,
    bool? autoSpeak,
    bool? enableCache,
    int? maxHistorySize,
    bool? protectFormulas,
    bool? protectCitations,
    String? sourceLang,
    String? targetLang,
    String? hotkeyModifiers,
    String? hotkeyKey,
    bool? enableMiddleMouse,
    String? proxyHost,
    int? proxyPort,
    ApiKeys? apiKeys,
  }) {
    return AppSettings(
      engine: engine ?? this.engine,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      windowPinned: windowPinned ?? this.windowPinned,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      enableCache: enableCache ?? this.enableCache,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
      protectFormulas: protectFormulas ?? this.protectFormulas,
      protectCitations: protectCitations ?? this.protectCitations,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      hotkeyModifiers: hotkeyModifiers ?? this.hotkeyModifiers,
      hotkeyKey: hotkeyKey ?? this.hotkeyKey,
      enableMiddleMouse: enableMiddleMouse ?? this.enableMiddleMouse,
      proxyHost: proxyHost ?? this.proxyHost,
      proxyPort: proxyPort ?? this.proxyPort,
      apiKeys: apiKeys ?? this.apiKeys,
    );
  }

  Map<String, dynamic> toJson() => {
        'engine': engine.name,
        'themeMode': themeMode.name,
        'language': language.code,
        'fontSize': fontSize,
        'windowPinned': windowPinned,
        'windowOpacity': windowOpacity,
        'autoSpeak': autoSpeak,
        'enableCache': enableCache,
        'maxHistorySize': maxHistorySize,
        'protectFormulas': protectFormulas,
        'protectCitations': protectCitations,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'hotkeyModifiers': hotkeyModifiers,
        'hotkeyKey': hotkeyKey,
        'enableMiddleMouse': enableMiddleMouse,
        'proxyHost': proxyHost,
        'proxyPort': proxyPort,
        'apiKeys': apiKeys.toJson(),
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        engine: TranslationEngine.values.firstWhere(
          (e) => e.name == json['engine'],
          orElse: () => TranslationEngine.googleFree,
        ),
        themeMode: AppThemeMode.values.firstWhere(
          (e) => e.name == json['themeMode'],
          orElse: () => AppThemeMode.system,
        ),
        language: AppLanguage.fromCode(json['language'] as String? ?? 'zh'),
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
        windowPinned: json['windowPinned'] as bool? ?? false,
        windowOpacity: (json['windowOpacity'] as num?)?.toDouble() ?? 0.95,
        autoSpeak: json['autoSpeak'] as bool? ?? false,
        enableCache: json['enableCache'] as bool? ?? true,
        maxHistorySize: json['maxHistorySize'] as int? ?? 100,
        protectFormulas: json['protectFormulas'] as bool? ?? true,
        protectCitations: json['protectCitations'] as bool? ?? true,
        sourceLang: json['sourceLang'] as String? ?? 'auto',
        targetLang: json['targetLang'] as String? ?? 'zh',
        hotkeyModifiers: json['hotkeyModifiers'] as String? ?? 'Control+Shift',
        hotkeyKey: json['hotkeyKey'] as String? ?? 'T',
        enableMiddleMouse: json['enableMiddleMouse'] as bool? ?? false,
        proxyHost: json['proxyHost'] as String?,
        proxyPort: json['proxyPort'] as int?,
        apiKeys: json['apiKeys'] != null
            ? ApiKeys.fromJson(json['apiKeys'] as Map<String, dynamic>)
            : const ApiKeys(),
      );
}