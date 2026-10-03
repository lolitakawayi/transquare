import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'base_translator.dart';
import 'http_client_factory.dart';
import '../../models/translation_result.dart';

class GoogleFreeTranslator extends BaseTranslator {
  static const int _maxRetries = 3;
  static const Duration _minRequestInterval = Duration(milliseconds: 800);

  static const _headers = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        ' (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Accept-Language': 'en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7',
  };

  final Random _random = Random();
  DateTime? _lastRequestTime;

  @override
  String get engineName => 'Google (Free)';

  @override
  bool get requiresApiKey => false;

  @override
  String get apiKeyUrl => '';

  @override
  String get apiDocUrl => '';

  @override
  Future<TranslationResult> translate(
    String text, {
    String sourceLang = 'auto',
    String targetLang = 'zh',
    String? proxyHost,
    int? proxyPort,
  }) async {
    await _enforceRateLimit();

    final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx'
      '&sl=$sourceLang'
      '&tl=$targetLang'
      '&dt=t'
      '&q=${Uri.encodeComponent(text)}',
    );

    Exception? lastError;
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      final client = createHttpClient(
        proxyHost: proxyHost,
        proxyPort: proxyPort,
      );
      try {
        _lastRequestTime = DateTime.now();
        final response = await client.get(uri, headers: _headers);

        final statusCode = response.statusCode;
        if (statusCode == 429 || statusCode >= 500) {
          lastError = Exception(
              'Google Free error ($statusCode): ${response.body}');
          if (attempt < _maxRetries) {
            await _waitBeforeRetry(attempt);
            continue;
          }
          throw lastError;
        }

        return _parseResponse(response, text, sourceLang, targetLang);
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (attempt < _maxRetries) {
          await _waitBeforeRetry(attempt);
          continue;
        }
        rethrow;
      } finally {
        client.close();
      }
    }

    throw lastError ?? Exception('Google Free translate error: unknown');
  }

  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime == null) return;
    final elapsed = DateTime.now().difference(_lastRequestTime!);
    if (elapsed < _minRequestInterval) {
      await Future.delayed(_minRequestInterval - elapsed);
    }
  }

  Future<void> _waitBeforeRetry(int attempt) async {
    final baseDelay = Duration(seconds: 2 * (1 << attempt));
    final jitter = Duration(milliseconds: _random.nextInt(1000));
    await Future.delayed(baseDelay + jitter);
  }

  TranslationResult _parseResponse(
    http.Response response,
    String text,
    String sourceLang,
    String targetLang,
  ) {
    if (response.statusCode != 200) {
      throw Exception(
          'Google Free error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    final sentences = data[0] as List<dynamic>;

    final buffer = StringBuffer();
    for (final sentence in sentences) {
      buffer.write((sentence as List<dynamic>)[0] as String);
    }

    String detectedLang = sourceLang;
    if (data.length > 2 && data[2] != null) {
      detectedLang = data[2] as String;
    }

    return TranslationResult(
      sourceText: text,
      translatedText: buffer.toString(),
      sourceLang: detectedLang,
      targetLang: targetLang,
      engine: engineName,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<bool> validateApiKey(String key) async {
    return true;
  }
}