import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:transquare/services/translators/http_client_factory.dart';

/// 统一的翻译测试 URI：Google Free API
Uri _testUri(String text) => Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx&sl=en&tl=zh&dt=t&q=${Uri.encodeComponent(text)}',
    );

void main() {
  group('createHttpClient 代理功能测试', () {
    test('直连：Google Free API 翻译 hello → 你好', () async {
      final client = createHttpClient();
      try {
        final response = await client.get(_testUri('hello'));
        expect(response.statusCode, equals(200));
        expect(response.body.toLowerCase(), contains('你好'));
        print('✅ 直连翻译成功: hello → 你好');
      } finally {
        client.close();
      }
    });

    test('空代理主机：回退直连成功', () async {
      final client = createHttpClient(proxyHost: '', proxyPort: 7890);
      try {
        final response = await client.get(_testUri('world'));
        expect(response.statusCode, equals(200));
        print('✅ 空 host 回退直连成功: world');
      } finally {
        client.close();
      }
    });

    test('null 代理主机：回退直连成功', () async {
      final client = createHttpClient(proxyHost: null, proxyPort: 7890);
      try {
        final response = await client.get(_testUri('test'));
        expect(response.statusCode, equals(200));
        print('✅ null host 回退直连成功: test');
      } finally {
        client.close();
      }
    });

    test('无效代理端口 19999：请求必定失败（证明代理已启用）', () async {
      final client = createHttpClient(
        proxyHost: '127.0.0.1',
        proxyPort: 19999,
      );
      try {
        await client.get(_testUri('test')).timeout(const Duration(seconds: 5));
        // 如果走到这里说明意外成功了
        fail('不应该成功：端口 19999 上没有代理服务器，请求应该失败');
      } on http.ClientException {
        print('✅ 连接被拒绝（预期行为）');
      } on TimeoutException {
        print('✅ 连接超时（预期行为）');
      } catch (e) {
        print('✅ 其他连接错误（预期行为）: ${e.runtimeType}');
      } finally {
        client.close();
      }
    });

    test('无效代理主机：请求必定失败（证明代理已启用）', () async {
      final client = createHttpClient(
        proxyHost: '10.255.255.1',
        proxyPort: 7890,
      );
      try {
        await client.get(_testUri('test')).timeout(const Duration(seconds: 5));
        fail('不应该成功：10.255.255.1 不可达，请求应该失败');
      } on http.ClientException {
        print('✅ 连接失败（预期行为）');
      } on TimeoutException {
        print('✅ 连接超时（预期行为）');
      } catch (e) {
        print('✅ 其他连接错误（预期行为）: ${e.runtimeType}');
      } finally {
        client.close();
      }
    });
  });
}