import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'models/settings.dart';
import 'providers/app_provider.dart';
import 'ui/settings/settings_screen.dart';
import 'ui/vocabulary/vocabulary_screen.dart';
import 'ui/history/history_screen.dart';
import 'ui/floating_window.dart';
import 'l10n/strings.dart';

class TransquareApp extends StatefulWidget {
  const TransquareApp({super.key});

  @override
  State<TransquareApp> createState() => _TransquareAppState();
}

class _TransquareAppState extends State<TransquareApp>
    with WindowListener, WidgetsBindingObserver {
  int _currentIndex = 0;
  String? _translationText;
  bool _showFloating = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addObserver(this);
    _initializeMainWindow();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeMainWindow() async {
    await windowManager.ensureInitialized();

    final options = WindowOptions(
      size: const Size(800, 600),
      minimumSize: const Size(600, 400),
      center: true,
      title: 'Transquare',
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  void showFloatingWindow([String? text]) async {
    await windowManager.setMinimumSize(const Size(300, 200));
    await windowManager.setSize(const Size(520, 360));
    await windowManager.center();
    await windowManager.setAlwaysOnTop(true);

    setState(() {
      _translationText = text;
      _showFloating = true;
    });

    if (text != null && text.isNotEmpty) {
      final appProvider = context.read<AppProvider>();
      appProvider.translate(text);
    }
  }

  void _closeFloatingWindow() async {
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setMinimumSize(const Size(600, 400));
    await windowManager.setSize(const Size(800, 600));
    await windowManager.center();
    setState(() {
      _showFloating = false;
      _translationText = null;
    });
    context.read<AppProvider>().clearCurrent();
  }

  @override
  void onWindowClose() async {
    final appProvider = context.read<AppProvider>();
    appProvider.historyService.save();
    appProvider.glossaryService.save();
    appProvider.vocabularyService.save();
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Transquare',
          themeMode: _mapThemeMode(appProvider.settings.themeMode),
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xFF6C63FF),
            useMaterial3: true,
            cardTheme: CardThemeData(elevation: 0),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 1,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF6C63FF),
            useMaterial3: true,
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E2E),
              elevation: 0,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 1,
            ),
          ),
          home: _showFloating
                ? FloatingWindow(
                    initialText: _translationText,
                    onClose: _closeFloatingWindow,
                  )
                : _buildMainWindow(appProvider),
        );
      },
    );
  }

  ThemeMode _mapThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Widget _buildMainWindow(AppProvider appProvider) {
    final lang = appProvider.settings.language.code;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(
                    Icons.translate,
                    size: 28,
                    color:
                        Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Transquare',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color:
                          Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Tooltip(
                      message: L10n.t(lang, appProvider.isListening
                          ? 'app.listening_enabled'
                          : 'app.listening_disabled'),
                      child: IconButton(
                        icon: Icon(
                          appProvider.isListening
                              ? Icons.mic
                              : Icons.mic_off,
                          color: appProvider.isListening
                              ? Colors.green
                              : Colors.red.shade300,
                        ),
                        onPressed: () =>
                            appProvider.toggleListening(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: Text(L10n.t(lang, 'app.home')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.history_outlined),
                selectedIcon: const Icon(Icons.history),
                label: Text(L10n.t(lang, 'app.history')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: Text(L10n.t(lang, 'app.vocabulary')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(L10n.t(lang, 'app.settings')),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFloatingWindow(),
        icon: const Icon(Icons.translate),
        label: Text(L10n.t(lang, 'app.quick_translate')),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const HistoryScreen();
      case 2:
        return const VocabularyScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Center(
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final lang = appProvider.settings.language.code;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.translate,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha:0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Transquare',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L10n.t(lang, 'app.subtitle'),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.keyboard,
                        '${L10n.t(lang, 'app.hotkey_hint')} ${appProvider.settings.hotkeyModifiers}+${appProvider.settings.hotkeyKey}'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.language, 
                        '${L10n.t(lang, 'app.engine')} ${appProvider.translationService.currentEngineName}'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.book, 
                        '${L10n.t(lang, 'app.glossary_count')} ${appProvider.glossaryService.count}'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.menu_book, 
                        '${L10n.t(lang, 'app.vocab_count')} ${appProvider.vocabularyService.count}'),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _quickAction(
                    context,
                    icon: Icons.translate,
                    label: L10n.t(lang, 'app.quick_translate'),
                    onTap: () => showFloatingWindow(),
                  ),
                  const SizedBox(width: 16),
                  _quickAction(
                    context,
                    icon: Icons.settings,
                    label: L10n.t(lang, 'app.settings'),
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  const SizedBox(width: 16),
                  _quickAction(
                    context,
                    icon: Icons.history,
                    label: L10n.t(lang, 'app.history'),
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}