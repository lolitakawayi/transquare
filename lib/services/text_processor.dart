import '../models/glossary_entry.dart';

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

  static final _urlPattern = RegExp(
    r'https?://[^\s]+|www\.[^\s]+|[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
  );

  static final _emailPattern = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  static final _codePattern = RegExp(r'```[\s\S]*?```|`[^`]+`');

  static final _numberPattern = RegExp(r'\b\d+(?:\.\d+)?\b');

  List<String> detectFormulas(String text) {
    final formulas = <String>[];
    for (final pattern in _formulaPatterns) {
      for (final match in pattern.allMatches(text)) {
        if (match.group(0) != null) {
          formulas.add(match.group(0)!);
        }
      }
    }
    return formulas.toSet().toList();
  }

  String protectFormulas(String text) {
    String result = text;
    for (final pattern in _formulaPatterns) {
      result = result.replaceAllMapped(pattern, (match) {
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

  List<String> detectCitations(String text) {
    final citations = <String>[];
    for (final pattern in _citationPatterns) {
      for (final match in pattern.allMatches(text)) {
        if (match.group(0) != null) {
          citations.add(match.group(0)!);
        }
      }
    }
    return citations.toSet().toList();
  }

  String protectCitations(String text) {
    String result = text;
    for (final pattern in _citationPatterns) {
      result = result.replaceAllMapped(pattern, (match) {
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
      var idx = 0;
      for (final entry in glossary.entries) {
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
      var idx = 0;
      for (final entry in glossary.entries) {
        final expected = entry.value;
        final token = 'ZGLSTOKEN${idx}Z';
        result = result.replaceAll(token, expected);
        idx++;
      }
    }
    return result;
  }

  String replaceGlossaryTerms(
      String text, List<GlossaryEntry> glossaryEntries) {
    String result = text;
    for (final entry in glossaryEntries) {
      result = result.replaceAll(entry.sourceTerm, entry.targetTerm);
    }
    return result;
  }

  bool isSingleWord(String text) {
    return text.trim().split(RegExp(r'\s+')).length == 1;
  }

  bool isSentence(String text) {
    final trimmed = text.trim();
    return trimmed.contains(RegExp(r'[.!?。！？]$')) &&
        trimmed.split(RegExp(r'\s+')).length > 1;
  }

  bool isParagraph(String text) {
    final trimmed = text.trim();
    return trimmed.split(RegExp(r'\s+')).length > 10 ||
        trimmed.contains('\n');
  }

  static bool isLikelyCode(String text) {
    return _codePattern.hasMatch(text);
  }

  static bool containsUrl(String text) {
    return _urlPattern.hasMatch(text) || _emailPattern.hasMatch(text);
  }

  static int wordCount(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }
}