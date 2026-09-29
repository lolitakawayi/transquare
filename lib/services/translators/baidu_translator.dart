import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_translator.dart';
import 'http_client_factory.dart';
import '../../models/translation_result.dart';

class BaiduTranslator extends BaseTranslator {
  String? _appId;
  String? _secretKey;

  BaiduTranslator({String? appId, String? secretKey})
      : _appId = appId,
        _secretKey = secretKey;

  @override
  String get engineName => 'Baidu';

  @override
  bool get requiresApiKey => true;

  @override
  String get apiKeyUrl => 'https://fanyi-api.baidu.com/api/trans/product/index';

  @override
  String get apiDocUrl =>
      'https://fanyi-api.baidu.com/doc/21';

  @override
  Future<TranslationResult> translate(
    String text, {
    String sourceLang = 'auto',
    String targetLang = 'zh',
    String? proxyHost,
    int? proxyPort,
  }) async {
    if (_appId == null || _secretKey == null ||
        _appId!.isEmpty || _secretKey!.isEmpty) {
      throw Exception(
        'Baidu Translator requires App ID and Secret Key. Please configure them in settings.',
      );
    }

    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final sign = _generateSign(text, salt);

    final uri = Uri.parse(
      'https://fanyi-api.baidu.com/api/trans/vip/translate',
    );

    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};

    final body = {
      'q': text,
      'from': sourceLang == 'auto' ? 'auto' : sourceLang,
      'to': targetLang,
      'appid': _appId!,
      'salt': salt,
      'sign': sign,
    };

    final client = createHttpClient(
      proxyHost: proxyHost,
      proxyPort: proxyPort,
    );
    try {
      final response = await client.post(uri, headers: headers, body: body);
      return _parseResponse(response, text, sourceLang, targetLang);
    } catch (e) {
      throw Exception('Baidu Translator error: $e');
    } finally {
      client.close();
    }
  }

  String _generateSign(String query, String salt) {
    final raw = '${_appId}$query$salt$_secretKey';
    final bytes = utf8.encode(raw);
    final digest = _md5(bytes);
    return digest;
  }

  String _md5(List<int> bytes) {
    int a = 0x67452301,
        b = 0xEFCDAB89,
        c = 0x98BADCFE,
        d = 0x10325476;

    final padded = List<int>.from(bytes);
    final origLen = padded.length * 8;
    padded.add(0x80);
    while ((padded.length * 8) % 512 != 448) {
      padded.add(0);
    }

    for (int i = 0; i < 8; i++) {
      padded.add((origLen >> (i * 8)) & 0xFF);
    }

    for (int i = 0; i < padded.length; i += 64) {
      final chunk = padded.sublist(i, i + 64);
      final m = <int>[];
      for (int j = 0; j < 64; j += 4) {
        m.add(chunk[j] |
            (chunk[j + 1] << 8) |
            (chunk[j + 2] << 16) |
            (chunk[j + 3] << 24));
      }

      int aa = a, bb = b, cc = c, dd = d;

      for (int j = 0; j < 64; j++) {
        int f, g;
        if (j < 16) {
          f = (b & c) | ((~b) & d);
          g = j;
        } else if (j < 32) {
          f = (d & b) | ((~d) & c);
          g = (5 * j + 1) % 16;
        } else if (j < 48) {
          f = b ^ c ^ d;
          g = (3 * j + 5) % 16;
        } else {
          f = c ^ (b | (~d));
          g = (7 * j) % 16;
        }

        int temp = d;
        d = c;
        c = b;
        b = _add32(
            b,
            _rotateLeft32(
                _add32(
                    a, _add32(f, _add32(m[g], _kValues[j]))),
                _sValues[j]));
        a = temp;
      }

      a = _add32(a, aa);
      b = _add32(b, bb);
      c = _add32(c, cc);
      d = _add32(d, dd);
    }

    return _toHexStr(a) + _toHexStr(b) + _toHexStr(c) + _toHexStr(d);
  }

  int _add32(int x, int y) => (x + y) & 0xFFFFFFFF;
  int _rotateLeft32(int x, int n) =>
      ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF;

  String _toHexStr(int value) {
    return (value & 0xFF).toRadixString(16).padLeft(2, '0') +
        ((value >> 8) & 0xFF).toRadixString(16).padLeft(2, '0') +
        ((value >> 16) & 0xFF).toRadixString(16).padLeft(2, '0') +
        ((value >> 24) & 0xFF).toRadixString(16).padLeft(2, '0');
  }

  static const _kValues = [
    0xD76AA478, 0xE8C7B756, 0x242070DB, 0xC1BDCEEE,
    0xF57C0FAF, 0x4787C62A, 0xA8304613, 0xFD469501,
    0x698098D8, 0x8B44F7AF, 0xFFFF5BB1, 0x895CD7BE,
    0x6B901122, 0xFD987193, 0xA679438E, 0x49B40821,
    0xF61E2562, 0xC040B340, 0x265E5A51, 0xE9B6C7AA,
    0xD62F105D, 0x02441453, 0xD8A1E681, 0xE7D3FBC8,
    0x21E1CDE6, 0xC33707D6, 0xF4D50D87, 0x455A14ED,
    0xA9E3E905, 0xFCEFA3F8, 0x676F02D9, 0x8D2A4C8A,
    0xFFFA3942, 0x8771F681, 0x6D9D6122, 0xFDE5380C,
    0xA4BEEA44, 0x4BDECFA9, 0xF6BB4B60, 0xBEBFBC70,
    0x289B7EC6, 0xEAA127FA, 0xD4EF3085, 0x04881D05,
    0xD9D4D039, 0xE6DB99E5, 0x1FA27CF8, 0xC4AC5665,
    0xF4292244, 0x432AFF97, 0xAB9423A7, 0xFC93A039,
    0x655B59C3, 0x8F0CCC92, 0xFFEFF47D, 0x85845DD1,
    0x6FA87E4F, 0xFE2CE6E0, 0xA3014314, 0x4E0811A1,
    0xF7537E82, 0xBD3AF235, 0x2AD7D2BB, 0xEB86D391,
  ];

  static const _sValues = [
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
  ];

  TranslationResult _parseResponse(
    http.Response response,
    String text,
    String sourceLang,
    String targetLang,
  ) {
    if (response.statusCode != 200) {
      throw Exception(
        'Baidu Translator error (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['error_code'] != null) {
      final errorMsg = data['error_msg'] ?? 'Unknown error';
      throw Exception('Baidu Translator error: $errorMsg');
    }

    final results = data['trans_result'] as List<dynamic>;
    final translatedParts = results
        .map((r) => (r as Map<String, dynamic>)['dst'] as String)
        .toList();
    final translatedText = translatedParts.join('\n');
    final sourceLangFromResult =
        (data['from'] as String?) ?? sourceLang;
    final targetLangFromResult =
        (data['to'] as String?) ?? targetLang;

    return TranslationResult(
      sourceText: text,
      translatedText: translatedText,
      sourceLang: sourceLangFromResult,
      targetLang: targetLangFromResult,
      engine: engineName,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<bool> validateApiKey(String key) {
    return Future.value(true);
  }
}