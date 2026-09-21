class GlossaryEntry {
  final String id;
  final String sourceTerm;
  final String targetTerm;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GlossaryEntry({
    required this.id,
    required this.sourceTerm,
    required this.targetTerm,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  GlossaryEntry copyWith({
    String? id,
    String? sourceTerm,
    String? targetTerm,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GlossaryEntry(
      id: id ?? this.id,
      sourceTerm: sourceTerm ?? this.sourceTerm,
      targetTerm: targetTerm ?? this.targetTerm,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceTerm': sourceTerm,
        'targetTerm': targetTerm,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory GlossaryEntry.fromJson(Map<String, dynamic> json) => GlossaryEntry(
        id: json['id'] as String,
        sourceTerm: json['sourceTerm'] as String,
        targetTerm: json['targetTerm'] as String,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  List<String> toCsvRow() => [sourceTerm, targetTerm, notes ?? ''];

  factory GlossaryEntry.fromCsvRow(List<String> row, String id) {
    final now = DateTime.now();
    return GlossaryEntry(
      id: id,
      sourceTerm: row.isNotEmpty ? row[0].trim() : '',
      targetTerm: row.length > 1 ? row[1].trim() : '',
      notes: row.length > 2 ? row[2].trim() : null,
      createdAt: now,
      updatedAt: now,
    );
  }
}