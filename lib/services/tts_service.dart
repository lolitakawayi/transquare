import 'dart:async';
import 'dart:io';

/// TTS 语音朗读服务
///
/// 通过 PowerShell 调用 Windows 内置的 SAPI (Speech API) 引擎实现文本转语音。
/// 无需额外安装任何依赖，无需 nuget，所有 Windows 系统开箱即用。
class TtsService {
  /// 当前正在执行的朗读进程
  Process? _currentProcess;

  /// 朗读指定文本
  ///
  /// [text] 要朗读的文本内容（会自动转义单引号）
  /// [language] 朗读使用的语言代码，用于选择对应的语音包
  Future<void> speak(String text, {String language = 'en-US'}) async {
    if (text.isEmpty) return;

    // 停止当前正在播放的语音
    await stop();

    // 转义单引号，防止 PowerShell 命令注入
    final escapedText = text.replaceAll("'", "''");

    // 根据语言代码获取对应的语音名称
    final voiceName = _getVoiceName(language);

    // 通过 PowerShell 调用 Windows SAPI 引擎朗读文本
    _currentProcess = await Process.start('powershell', [
      '-NoProfile',
      '-Command',
      [
        'Add-Type -AssemblyName System.Speech;',
        '\$speech = New-Object System.Speech.Synthesis.SpeechSynthesizer;',
        if (voiceName != null) "\$speech.SelectVoice('$voiceName');",
        "\$speech.Speak('$escapedText');",
      ].join(' '),
    ]);

    // 监听进程结束，自动清理引用
    unawaited(_currentProcess!.exitCode.then((_) {
      _currentProcess = null;
    }));
  }

  /// 停止朗读
  Future<void> stop() async {
    if (_currentProcess != null) {
      _currentProcess!.kill();
      _currentProcess = null;
    }
  }

  /// 根据语言代码获取 Windows SAPI 语音名称
  ///
  /// Windows 10/11 默认内置的语音包：
  /// - en-US: Microsoft David / Microsoft Zira
  /// - zh-CN: Microsoft Huihui
  /// - ja-JP: Microsoft Haruka
  /// 返回 null 表示使用系统默认语音
  String? _getVoiceName(String langCode) {
    switch (langCode) {
      case 'zh-CN':
        return 'Microsoft Huihui';
      case 'en-US':
        return 'Microsoft Zira';
      case 'ja-JP':
        return 'Microsoft Haruka';
      case 'ko-KR':
        return 'Microsoft Heami';
      case 'fr-FR':
        return 'Microsoft Hortense';
      case 'de-DE':
        return 'Microsoft Hedda';
      case 'es-ES':
        return 'Microsoft Helena';
      case 'pt-BR':
        return 'Microsoft Maria';
      case 'ru-RU':
        return 'Microsoft Irina';
      default:
        return null; // 使用系统默认语音
    }
  }

  /// 释放资源
  void dispose() {
    stop();
  }

  /// 将翻译引擎返回的短语言代码转为 TTS 语音引擎需要的长格式
  ///
  /// 例如 'zh' → 'zh-CN', 'en' → 'en-US', 'ja' → 'ja-JP'
  static String normalizeTtsLang(String langCode) {
    switch (langCode) {
      case 'zh':
        return 'zh-CN';
      case 'en':
        return 'en-US';
      case 'ja':
        return 'ja-JP';
      case 'ko':
        return 'ko-KR';
      case 'fr':
        return 'fr-FR';
      case 'de':
        return 'de-DE';
      case 'es':
        return 'es-ES';
      case 'pt':
        return 'pt-BR';
      case 'ru':
        return 'ru-RU';
      case 'ar':
        return 'ar-SA';
      default:
        return 'en-US';
    }
  }
}