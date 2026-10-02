import 'translation_result.dart';

class HistoryEntry {
  final String id;
  final TranslationResult result;
  final bool isFavorite;

  const HistoryEntry({
    required this.id,
    required this.result,
    this.isFavorite = false,
  });

  HistoryEntry copyWith({
    String? id,
    TranslationResult? result,
    bool? isFavorite,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      result: result ?? this.result,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'result': result.toJson(),
        'isFavorite': isFavorite,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        result: TranslationResult.fromJson(
            json['result'] as Map<String, dynamic>),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}