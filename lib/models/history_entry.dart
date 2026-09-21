import 'translation_result.dart';

class HistoryEntry {
  final String id;
  final TranslationResult result;
  final bool isFavorite;
  final List<String> tags;

  const HistoryEntry({
    required this.id,
    required this.result,
    this.isFavorite = false,
    this.tags = const [],
  });

  HistoryEntry copyWith({
    String? id,
    TranslationResult? result,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      result: result ?? this.result,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'result': result.toJson(),
        'isFavorite': isFavorite,
        'tags': tags,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        result: TranslationResult.fromJson(
            json['result'] as Map<String, dynamic>),
        isFavorite: json['isFavorite'] as bool? ?? false,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      );
}