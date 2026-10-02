import 'dart:async';
import 'package:flutter/services.dart';

class PlatformService {
  static const _channel = MethodChannel('com.transquare/platform');

  static Future<String> getClipboardText() async {
    try {
      final result = await _channel.invokeMethod<String>('getClipboardText');
      return result ?? '';
    } catch (e) {
      return '';
    }
  }

  static Future<void> setClipboardText(String text) async {
    try {
      await _channel.invokeMethod('setClipboardText', {'text': text});
    } catch (_) {}
  }

  static Future<String> copySelectionAndRead() async {
    try {
      final result =
          await _channel.invokeMethod<String>('copySelectionAndRead');
      return result ?? '';
    } catch (e) {
      return '';
    }
  }

  static Future<void> setWindowOpacity(double opacity) async {
    try {
      await _channel
          .invokeMethod('setWindowOpacity', {'opacity': opacity});
    } catch (_) {}
  }

  static Future<void> setMiddleMouseEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setMiddleMouseEnabled', {'enabled': enabled});
    } catch (_) {}
  }
}