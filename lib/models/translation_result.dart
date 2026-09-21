class TranslationResult {
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String engine;
  final DateTime timestamp;
  final List<String> glossaryMatches;
  final bool fromCache;

  const TranslationResult({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.engine,
    required this.timestamp,
    this.glossaryMatches = const [],
    this.fromCache = false,
  });

  TranslationResult copyWith({
    String? sourceText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    String? engine,
    DateTime? timestamp,
    List<String>? glossaryMatches,
    bool? fromCache,
  }) {
    return TranslationResult(
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      engine: engine ?? this.engine,
      timestamp: timestamp ?? this.timestamp,
      glossaryMatches: glossaryMatches ?? this.glossaryMatches,
      fromCache: fromCache ?? this.fromCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'sourceText': sourceText,
        'translatedText': translatedText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'engine': engine,
        'timestamp': timestamp.toIso8601String(),
        'glossaryMatches': glossaryMatches,
        'fromCache': fromCache,
      };

  factory TranslationResult.fromJson(Map<String, dynamic> json) =>
      TranslationResult(
        sourceText: json['sourceText'] as String,
        translatedText: json['translatedText'] as String,
        sourceLang: json['sourceLang'] as String,
        targetLang: json['targetLang'] as String,
        engine: json['engine'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        glossaryMatches: (json['glossaryMatches'] as List<dynamic>?)
                ?.cast<String>() ??
            const [],
        fromCache: json['fromCache'] as bool? ?? false,
      );
}