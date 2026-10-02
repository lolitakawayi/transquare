class TextProcessor {
  static final _formulaPatterns = [
    RegExp(r'\$[^$]+\$'),
    RegExp(r'\$\$[^$]+\$\$'),
    RegExp(r'\\\([^)]+\\\)'),
    RegExp(r'\\\[[^\]]+\\\]'),
    RegExp(r'\\begin\{[^}]*\}[\s\S]*?\\end\{[^}]*\}'),
    RegExp(r'\\[a-zA-Z]+\{[^}]*\}'),
    RegExp(r'\\[a-zA-Z]+'),
    RegExp(r'[=≈≠≤≥±×÷∑∏∫∞∂∇√]'),
    RegExp(r'[α-ωΑ-Ω]'),
  ];

  static final _citationPatterns = [
    RegExp(r'\[\d+(?:[,;\s]*\d+)*\]'),
    RegExp(r'\([A-Z][a-z]+(?:\s+(?:&|and)\s+[A-Z][a-z]+)?,\s*\d{4}[a-z]?\)'),
    RegExp(r'\([A-Z][a-z]+\s+et\s+al\.,\s*\d{4}\)'),
    RegExp(r'\[[A-Z][a-z]+\s+\d{4}\]'),
    RegExp(r'<ref[^>]*>[\s\S]*?</ref>'),
    RegExp(r'\{\\{cite[^}]*\}\}'),
    RegExp(r'\{\\{sfn\|[^}]*\}\}'),
  ];

  List<String> detectFormulas(String text) {
    final formulas = <String>[];
    for (final pattern in _formulaPatterns) {
      for (final match in pattern.allMatches(text)) {
        formulas.add(match.group(0)!);
      }
    }
    return formulas;
  }

  List<String> detectCitations(String text) {
    final citations = <String>[];
    for (final pattern in _citationPatterns) {
      for (final match in pattern.allMatches(text)) {
        citations.add(match.group(0)!);
      }
    }
    return citations;
  }

  String protectFormulas(String text) {
    String result = text;
    for (final pattern in _formulaPatterns) {
      result = result.replaceAllMapped(pattern, (match) {
        final prefix = result.substring(0, match.start);
        final formulaOpens = '<FORMULA>'.allMatches(prefix).length;
        final formulaCloses = '</FORMULA>'.allMatches(prefix).length;
        final citeOpens = '<CITE>'.allMatches(prefix).length;
        final citeCloses = '</CITE>'.allMatches(prefix).length;
        if (formulaOpens > formulaCloses || citeOpens > citeCloses) {
          return match.group(0)!;
        }
        return '<FORMULA>${match.group(0)}</FORMULA>';
      });
    }
    return result;
  }

  String unprotectFormulas(String text) {
    return text.replaceAllMapped(
      RegExp(r'<FORMULA>(.*?)</FORMULA>'),
      (match) => match.group(1) ?? '',
    );
  }

  String protectCitations(String text) {
    String result = text;
    for (final pattern in _citationPatterns) {
      result = result.replaceAllMapped(pattern, (match) {
        final prefix = result.substring(0, match.start);
        final formulaOpens = '<FORMULA>'.allMatches(prefix).length;
        final formulaCloses = '</FORMULA>'.allMatches(prefix).length;
        final citeOpens = '<CITE>'.allMatches(prefix).length;
        final citeCloses = '</CITE>'.allMatches(prefix).length;
        if (formulaOpens > formulaCloses || citeOpens > citeCloses) {
          return match.group(0)!;
        }
        return '<CITE>${match.group(0)}</CITE>';
      });
    }
    return result;
  }

  String unprotectCitations(String text) {
    return text.replaceAllMapped(
      RegExp(r'<CITE>(.*?)</CITE>'),
      (match) => match.group(1) ?? '',
    );
  }

  String preprocessText(
    String text, {
    bool protectFormulasFlag = true,
    bool protectCitationsFlag = true,
    Map<String, String>? glossary,
  }) {
    String processed = text.trim();
    if (protectFormulasFlag) {
      processed = protectFormulas(processed);
    }
    if (protectCitationsFlag) {
      processed = protectCitations(processed);
    }
    if (glossary != null && glossary.isNotEmpty) {
      final sortedEntries = glossary.entries.toList()
        ..sort((a, b) => b.key.length.compareTo(a.key.length));
      var idx = 0;
      for (final entry in sortedEntries) {
        final token = 'ZGLSTOKEN${idx}Z';
        processed = processed.replaceAll(entry.key, token);
        idx++;
      }
    }
    return processed;
  }

  String postprocessText(
    String text, {
    Map<String, String>? glossary,
  }) {
    String result = text;
    result = unprotectFormulas(result);
    result = unprotectCitations(result);
    if (glossary != null && glossary.isNotEmpty) {
      final sortedEntries = glossary.entries.toList()
        ..sort((a, b) => b.key.length.compareTo(a.key.length));
      var idx = 0;
      for (final entry in sortedEntries) {
        final expected = entry.value;
        final token = 'ZGLSTOKEN${idx}Z';
        result = result.replaceAll(token, expected);
        idx++;
      }
    }
    return result;
  }
}