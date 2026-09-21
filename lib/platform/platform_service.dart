import 'dart:async';
import 'package:flutter/services.dart';

class PlatformService {
  static const _channel = MethodChannel('com.transquare/platform');

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

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

  static Future<bool> isListening() async {
    try {
      final result = await _channel.invokeMethod<bool>('isListening');
      return result ?? true;
    } catch (e) {
      return true;
    }
  }

  static Future<void> setWindowOnTop(bool onTop) async {
    try {
      await _channel.invokeMethod('setWindowOnTop', {'onTop': onTop});
    } catch (_) {}
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