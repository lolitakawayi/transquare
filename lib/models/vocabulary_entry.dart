class VocabularyEntry {
  final String id;
  final String word;
  final String? translation;
  final String? context;
  final String? sourceApp;
  final DateTime addedAt;
  final DateTime reviewedAt;
  final int reviewCount;
  final bool mastered;

  const VocabularyEntry({
    required this.id,
    required this.word,
    this.translation,
    this.context,
    this.sourceApp,
    required this.addedAt,
    required this.reviewedAt,
    this.reviewCount = 0,
    this.mastered = false,
  });

  VocabularyEntry copyWith({
    String? id,
    String? word,
    String? translation,
    String? context,
    String? sourceApp,
    DateTime? addedAt,
    DateTime? reviewedAt,
    int? reviewCount,
    bool? mastered,
  }) {
    return VocabularyEntry(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      context: context ?? this.context,
      sourceApp: sourceApp ?? this.sourceApp,
      addedAt: addedAt ?? this.addedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      mastered: mastered ?? this.mastered,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'translation': translation,
        'context': context,
        'sourceApp': sourceApp,
        'addedAt': addedAt.toIso8601String(),
        'reviewedAt': reviewedAt.toIso8601String(),
        'reviewCount': reviewCount,
        'mastered': mastered,
      };

  factory VocabularyEntry.fromJson(Map<String, dynamic> json) =>
      VocabularyEntry(
        id: json['id'] as String,
        word: json['word'] as String,
        translation: json['translation'] as String?,
        context: json['context'] as String?,
        sourceApp: json['sourceApp'] as String?,
        addedAt: DateTime.parse(json['addedAt'] as String),
        reviewedAt: DateTime.parse(json['reviewedAt'] as String),
        reviewCount: json['reviewCount'] as int? ?? 0,
        mastered: json['mastered'] as bool? ?? false,
      );

  List<String> toCsvRow() => [
        word,
        translation ?? '',
        context ?? '',
        sourceApp ?? '',
        addedAt.toIso8601String(),
        mastered ? '1' : '0',
      ];

  String toAnkiLine() {
    final buffer = StringBuffer();
    buffer.writeln(word);
    if (translation != null) buffer.writeln(translation);
    if (context != null) buffer.writeln('Context: $context');
    return buffer.toString().trim();
  }
}