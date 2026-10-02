import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'services/translation_service.dart';
import 'services/cache_service.dart';
import 'services/glossary_service.dart';
import 'services/vocabulary_service.dart';
import 'services/history_service.dart';
import 'services/text_processor.dart';
import 'services/tts_service.dart';
import 'platform/platform_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

AppProvider? _globalAppProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  final translationService = TranslationService(
    cache: CacheService(maxEntries: 500),
    textProcessor: TextProcessor(),
  );

  final glossaryService = GlossaryService();
  final vocabularyService = VocabularyService();
  final historyService = HistoryService();

  final ttsService = TtsService();

  _globalAppProvider = AppProvider(
    translationService: translationService,
    glossaryService: glossaryService,
    vocabularyService: vocabularyService,
    historyService: historyService,
    ttsService: ttsService,
  );

  await _globalAppProvider!.initialize();

  PlatformService.setWindowOpacity(_globalAppProvider!.settings.windowOpacity);

  _setupNativeHotkeyListener();

  await _initializeSystemTray();

  runApp(
    ChangeNotifierProvider.value(
      value: _globalAppProvider!,
      child: const TransquareApp(),
    ),
  );

  await _registerHotKeys(_globalAppProvider!);
}

void _setupNativeHotkeyListener() {
  const hotkeyChannel = MethodChannel('com.transquare/hotkey');
  hotkeyChannel.setMethodCallHandler((call) async {
    if (call.method == 'onHotkeyTranslate') {
      _handleHotkeyTrigger();
    }
  });
}

Future<void> _handleHotkeyTrigger() async {
  if (_globalAppProvider == null) return;
  if (!_globalAppProvider!.isListening) return;

  final text = await PlatformService.copySelectionAndRead();
  if (text.isNotEmpty) {
    await _globalAppProvider!.translate(text);
    return;
  }

  final clipboardText = await PlatformService.getClipboardText();
  if (clipboardText.isNotEmpty) {
    await _globalAppProvider!.translate(clipboardText);
  }
}

SystemTray? _systemTray;

Future<void> _initializeSystemTray() async {
  _systemTray = SystemTray();
  await _systemTray!.initSystemTray(
    title: 'Transquare',
    iconPath: 'assets/icons/app_icon.ico',
    toolTip: 'Transquare - Academic Translation Assistant',
  );

  final menus = [
    MenuItem(
      label: 'Show Window',
      onClicked: () async {
        await windowManager.setSize(const Size(800, 600));
        await windowManager.setMinimumSize(const Size(600, 400));
        await windowManager.center();
        await windowManager.setAlwaysOnTop(false);
        await windowManager.show();
        await windowManager.focus();
      },
    ),
    MenuItem(
      label: 'Toggle Listening',
      onClicked: () {
        _globalAppProvider?.toggleListening();
      },
    ),
    MenuSeparator(),
    MenuItem(
      label: 'Exit',
      onClicked: () async {
        await hotKeyManager.unregisterAll();
        await windowManager.destroy();
      },
    ),
  ];
  await _systemTray!.setContextMenu(menus);
}

Future<void> _registerHotKeys(AppProvider appProvider) async {
  final settings = appProvider.settings;

  final modifiersStr = settings.hotkeyModifiers;
  final keyStr = settings.hotkeyKey;

  List<HotKeyModifier>? modifiers;
  if (modifiersStr == 'Control+Shift') {
    modifiers = [HotKeyModifier.control, HotKeyModifier.shift];
  } else if (modifiersStr == 'Alt+Shift') {
    modifiers = [HotKeyModifier.alt, HotKeyModifier.shift];
  } else if (modifiersStr == 'Control+Alt') {
    modifiers = [HotKeyModifier.control, HotKeyModifier.alt];
  }

  final LogicalKeyboardKey key;
  switch (keyStr.toUpperCase()) {
    case 'T':
      key = LogicalKeyboardKey.keyT;
    case 'Q':
      key = LogicalKeyboardKey.keyQ;
    case 'W':
      key = LogicalKeyboardKey.keyW;
    case 'E':
      key = LogicalKeyboardKey.keyE;
    case 'D':
      key = LogicalKeyboardKey.keyD;
    case 'F':
      key = LogicalKeyboardKey.keyF;
    case 'G':
      key = LogicalKeyboardKey.keyG;
    default:
      key = LogicalKeyboardKey.keyT;
  }

  if (modifiers != null) {
    await hotKeyManager.register(
      HotKey(
        key: key,
        modifiers: modifiers,
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (_) => _handleHotkeyTrigger(),
    );
  }

  _syncMiddleMouseSetting(appProvider);
}

void _syncMiddleMouseSetting(AppProvider appProvider) {
  final enabled = appProvider.settings.enableMiddleMouse;
  PlatformService.setMiddleMouseEnabled(enabled);

  // 缓存当前设置值，变更时同步到平台层
  String _lastModifiers = appProvider.settings.hotkeyModifiers;
  String _lastKey = appProvider.settings.hotkeyKey;
  double _lastOpacity = appProvider.settings.windowOpacity;

  appProvider.addListener(() {
    final newEnabled = appProvider.settings.enableMiddleMouse;
    if (newEnabled != enabled) {
      PlatformService.setMiddleMouseEnabled(newEnabled);
    }

    final newModifiers = appProvider.settings.hotkeyModifiers;
    final newKey = appProvider.settings.hotkeyKey;
    if (newModifiers != _lastModifiers || newKey != _lastKey) {
      _lastModifiers = newModifiers;
      _lastKey = newKey;
      _registerHotKeys(appProvider);
    }

    final newOpacity = appProvider.settings.windowOpacity;
    if (newOpacity != _lastOpacity) {
      _lastOpacity = newOpacity;
      PlatformService.setWindowOpacity(newOpacity);
    }
  });
}