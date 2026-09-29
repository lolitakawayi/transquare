import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/settings.dart' as models;
import '../../providers/app_provider.dart';
import '../../l10n/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final lang = appProvider.settings.language.code;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t(lang, 'settings.title')),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              isDark ? Colors.white38 : Colors.black38,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: L10n.t(lang, 'settings.engine')),
            Tab(text: L10n.t(lang, 'settings.shortcuts')),
            Tab(text: L10n.t(lang, 'settings.glossary')),
            Tab(text: L10n.t(lang, 'settings.appearance')),
            Tab(text: L10n.t(lang, 'settings.advanced')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EngineSettingsTab(key: ValueKey(lang)),
          ShortcutSettingsTab(key: ValueKey(lang)),
          GlossarySettingsTab(key: ValueKey(lang)),
          AppearanceSettingsTab(key: ValueKey(lang)),
          AdvancedSettingsTab(key: ValueKey(lang)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Engine Settings Tab
// ──────────────────────────────────────────────
class EngineSettingsTab extends StatelessWidget {
  const EngineSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final settings = appProvider.settings;
    final lang = settings.language.code;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        _sectionHeader(L10n.t(lang, 'engine.title')),
        const SizedBox(height: 12),
        _engineOption(
          context,
          title: L10n.t(lang, 'engine.google'),
          subtitle: L10n.t(lang, 'engine.google_desc'),
          value: models.TranslationEngine.google,
          groupValue: settings.engine,
          onChanged: (v) => appProvider.setEngine(v!),
        ),
        _engineOption(
          context,
          title: L10n.t(lang, 'engine.microsoft'),
          subtitle: L10n.t(lang, 'engine.microsoft_desc'),
          value: models.TranslationEngine.microsoft,
          groupValue: settings.engine,
          onChanged: (v) => appProvider.setEngine(v!),
        ),
        _engineOption(
          context,
          title: L10n.t(lang, 'engine.deepl'),
          subtitle: L10n.t(lang, 'engine.deepl_desc'),
          value: models.TranslationEngine.deepl,
          groupValue: settings.engine,
          onChanged: (v) => appProvider.setEngine(v!),
        ),
        _engineOption(
          context,
          title: L10n.t(lang, 'engine.baidu'),
          subtitle: L10n.t(lang, 'engine.baidu_desc'),
          value: models.TranslationEngine.baidu,
          groupValue: settings.engine,
          onChanged: (v) => appProvider.setEngine(v!),
        ),
        const SizedBox(height: 16),
        _sectionHeader(
          lang == 'zh' ? '免费引擎 ' : 'Free Engines '),
        const SizedBox(height: 12),
        _engineOption(
          context,
          title: L10n.t(lang, 'engine.google_free'),
          subtitle: L10n.t(lang, 'engine.google_free_desc'),
          value: models.TranslationEngine.googleFree,
          groupValue: settings.engine,
          onChanged: (v) => appProvider.setEngine(v!),
        ),
        _engineOption(
          context,
          title: L10n.t(lang, 'engine.mymemory'),
          subtitle: L10n.t(lang, 'engine.mymemory_desc'),
          value: models.TranslationEngine.mymemory,
          groupValue: settings.engine,
          onChanged: (v) => appProvider.setEngine(v!),
        ),
        const SizedBox(height: 24),
        _sectionHeader(L10n.t(lang, 'engine.api_key')),
        const SizedBox(height: 12),
        if (settings.engine == models.TranslationEngine.google) ...[
          _apiKeyField(
            context,
            label: 'Google API Key',
            initialValue: settings.apiKeys.googleApiKey ?? '',
            onChanged: (v) => appProvider.setApiKeys(
              settings.apiKeys.copyWith(googleApiKey: v),
            ),
            hint: L10n.t(lang, 'engine.api_key_hint').replaceAll('{name}', 'Google'),
          ),
        ],
        if (settings.engine == models.TranslationEngine.microsoft) ...[
          _apiKeyField(
            context,
            label: 'Microsoft Translator Key',
            initialValue: settings.apiKeys.microsoftApiKey ?? '',
            onChanged: (v) => appProvider.setApiKeys(
              settings.apiKeys.copyWith(microsoftApiKey: v),
            ),
            hint: L10n.t(lang, 'engine.api_key_hint').replaceAll('{name}', 'Microsoft'),
          ),
        ],
        if (settings.engine == models.TranslationEngine.deepl) ...[
          _apiKeyField(
            context,
            label: 'DeepL API Key',
            initialValue: settings.apiKeys.deeplApiKey ?? '',
            onChanged: (v) => appProvider.setApiKeys(
              settings.apiKeys.copyWith(deeplApiKey: v),
            ),
            hint: L10n.t(lang, 'engine.api_key_hint').replaceAll('{name}', 'DeepL'),
          ),
        ],
        if (settings.engine == models.TranslationEngine.baidu) ...[
          _apiKeyField(
            context,
            label: L10n.t(lang, 'engine.app_id'),
            initialValue: settings.apiKeys.baiduAppId ?? '',
            onChanged: (v) => appProvider.setApiKeys(
              settings.apiKeys.copyWith(baiduAppId: v),
            ),
            hint: 'Enter your Baidu App ID',
          ),
          const SizedBox(height: 12),
          _apiKeyField(
            context,
            label: L10n.t(lang, 'engine.secret_key'),
            initialValue: settings.apiKeys.baiduSecretKey ?? '',
            onChanged: (v) => appProvider.setApiKeys(
              settings.apiKeys.copyWith(baiduSecretKey: v),
            ),
            hint: 'Enter your Baidu Secret Key',
            obscure: true,
          ),
        ],
        const SizedBox(height: 24),
        _sectionHeader(L10n.t(lang, 'engine.source_lang')),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _dropdownField(
                context,
                label: L10n.t(lang, 'engine.source_lang'),
                value: settings.sourceLang,
                items: {
                  'auto': L10n.t(lang, 'engine.auto_detect'),
                  'en': 'English',
                  'zh': 'Chinese',
                  'ja': 'Japanese',
                  'ko': 'Korean',
                  'fr': 'French',
                  'de': 'German',
                  'es': 'Spanish',
                  'ru': 'Russian',
                },
                onChanged: (v) {
                  appProvider.updateSettings(
                    settings.copyWith(sourceLang: v),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _dropdownField(
                context,
                label: L10n.t(lang, 'engine.target_lang'),
                value: settings.targetLang,
                items: {
                  'zh': 'Chinese',
                  'en': 'English',
                  'ja': 'Japanese',
                  'ko': 'Korean',
                  'fr': 'French',
                  'de': 'German',
                  'es': 'Spanish',
                  'ru': 'Russian',
                },
                onChanged: (v) {
                  appProvider.updateSettings(
                    settings.copyWith(targetLang: v),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Shortcut Settings Tab
// ──────────────────────────────────────────────
class ShortcutSettingsTab extends StatelessWidget {
  const ShortcutSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final settings = appProvider.settings;
    final lang = settings.language.code;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        _sectionHeader(L10n.t(lang, 'shortcut.trigger')),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'zh'
                      ? '在任何应用中选中文本后，按快捷键即可翻译。'
                      : 'Select text in any application, then press the shortcut to translate.',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _dropdownField(
                        context,
                        label: L10n.t(lang, 'shortcut.modifiers'),
                        value: settings.hotkeyModifiers,
                        items: {
                          'Control+Shift': 'Ctrl + Shift',
                          'Alt+Shift': 'Alt + Shift',
                          'Control+Alt': 'Ctrl + Alt',
                        },
                        onChanged: (v) {
                          appProvider.updateSettings(
                            settings.copyWith(hotkeyModifiers: v),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child: _dropdownField(
                        context,
                        label: L10n.t(lang, 'shortcut.key'),
                        value: settings.hotkeyKey,
                        items: const {
                          'T': 'T',
                          'Q': 'Q',
                          'W': 'W',
                          'E': 'E',
                          'D': 'D',
                          'F': 'F',
                          'G': 'G',
                        },
                        onChanged: (v) {
                          appProvider.updateSettings(
                            settings.copyWith(hotkeyKey: v),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(L10n.t(lang, 'shortcut.middle_mouse'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
              lang == 'zh' ? '在选中文本上点击鼠标中键触发翻译' : 'Click middle mouse button on selected text'),
          value: settings.enableMiddleMouse,
          onChanged: (v) {
            appProvider.updateSettings(
                settings.copyWith(enableMiddleMouse: v));
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Glossary Settings Tab
// ──────────────────────────────────────────────
class GlossarySettingsTab extends StatefulWidget {
  const GlossarySettingsTab({super.key});

  @override
  State<GlossarySettingsTab> createState() => _GlossarySettingsTabState();
}

class _GlossarySettingsTabState extends State<GlossarySettingsTab> {
  final _sourceController = TextEditingController();
  final _targetController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _newestFirst = true;

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final lang = appProvider.settings.language.code;
    final rawEntries = _searchQuery.isEmpty
        ? appProvider.glossaryService.entries
        : appProvider.glossaryService.search(_searchQuery);
    final entries = _newestFirst
        ? rawEntries.reversed.toList()
        : rawEntries;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sourceController,
                  decoration: InputDecoration(
                    labelText: L10n.t(lang, 'glossary.source'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _targetController,
                  decoration: InputDecoration(
                    labelText: L10n.t(lang, 'glossary.translation'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_sourceController.text.isNotEmpty &&
                      _targetController.text.isNotEmpty) {
                    appProvider.glossaryService.addEntry(
                      sourceTerm: _sourceController.text,
                      targetTerm: _targetController.text,
                    );
                    appProvider.glossaryService.save();
                    _sourceController.clear();
                    _targetController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                ),
                child: Text(L10n.t(lang, 'glossary.add')),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: L10n.t(lang, 'vocab.search_hint'),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _newestFirst
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  size: 18,
                ),
                tooltip: _newestFirst
                    ? '最新优先 (Latest first)'
                    : '最早优先 (Oldest first)',
                onPressed: () =>
                    setState(() => _newestFirst = !_newestFirst),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload, size: 18),
                label: Text(L10n.t(lang, 'glossary.import')),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 18),
                label: Text(L10n.t(lang, 'glossary.export')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.book_outlined,
                          size: 48,
                          color: Theme.of(context).disabledColor),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? L10n.t(lang, 'glossary.empty')
                            : 'No matches found.',
                        style:
                            TextStyle(color: Theme.of(context).disabledColor),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      leading: const Icon(Icons.double_arrow),
                      title: Text(entry.sourceTerm,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(entry.targetTerm),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          appProvider.glossaryService
                              .removeEntry(entry.id);
                          appProvider.glossaryService.save();
                          appProvider.notifyListeners();
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Appearance Settings Tab
// ──────────────────────────────────────────────
class AppearanceSettingsTab extends StatelessWidget {
  const AppearanceSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final settings = appProvider.settings;
    final lang = settings.language.code;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        // ── Language ──
        _sectionHeader(L10n.t(lang, 'settings.language')),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              RadioListTile<models.AppLanguage>(
                title: Text(L10n.t(lang, 'settings.language_zh')),
                subtitle: const Text('简体中文'),
                value: models.AppLanguage.chinese,
                groupValue: settings.language,
                onChanged: (v) {
                  if (v != null) appProvider.setLanguage(v);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              RadioListTile<models.AppLanguage>(
                title: Text(L10n.t(lang, 'settings.language_en')),
                subtitle: const Text('English'),
                value: models.AppLanguage.english,
                groupValue: settings.language,
                onChanged: (v) {
                  if (v != null) appProvider.setLanguage(v);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Theme ──
        _sectionHeader(L10n.t(lang, 'appearance.theme')),
        const SizedBox(height: 12),
        _radioTile(
          context,
          title: L10n.t(lang, 'theme.system'),
          value: models.AppThemeMode.system,
          groupValue: settings.themeMode,
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(themeMode: v!)),
        ),
        _radioTile(
          context,
          title: L10n.t(lang, 'theme.light'),
          value: models.AppThemeMode.light,
          groupValue: settings.themeMode,
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(themeMode: v!)),
        ),
        _radioTile(
          context,
          title: L10n.t(lang, 'theme.dark'),
          value: models.AppThemeMode.dark,
          groupValue: settings.themeMode,
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(themeMode: v!)),
        ),
        const SizedBox(height: 24),

        // ── Font Size ──
        _sectionHeader(L10n.t(lang, 'appearance.font_size')),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: settings.fontSize,
                    min: 10,
                    max: 24,
                    divisions: 14,
                    label: '${settings.fontSize.round()}px',
                    onChanged: (v) => appProvider.setFontSize(v),
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Window ──
        _sectionHeader(L10n.t(lang, 'appearance.window_opacity')),
        const SizedBox(height: 12),
        Slider(
          value: settings.windowOpacity,
          min: 0.3,
          max: 1.0,
          divisions: 14,
          label: '${(settings.windowOpacity * 100).round()}%',
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(windowOpacity: v)),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(lang == 'zh' ? '窗口置顶' : 'Always on top (Pin)',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lang == 'zh'
              ? '保持浮动窗口在其他窗口之上'
              : 'Keep the floating window above other windows'),
          value: settings.windowPinned,
          onChanged: (v) => appProvider.togglePinned(),
        ),
        SwitchListTile(
          title: Text(lang == 'zh' ? '透明背景' : 'Transparent background',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lang == 'zh'
              ? '使浮动窗口半透明'
              : 'Make the floating window semi-transparent'),
          value: settings.windowTransparent,
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(windowTransparent: v)),
        ),
        SwitchListTile(
          title: Text(lang == 'zh' ? '自动朗读' : 'Auto-speak',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lang == 'zh'
              ? '翻译后自动朗读译文'
              : 'Automatically read translation aloud'),
          value: settings.autoSpeak,
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(autoSpeak: v)),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Advanced Settings Tab
// ──────────────────────────────────────────────
class AdvancedSettingsTab extends StatelessWidget {
  const AdvancedSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final settings = appProvider.settings;
    final lang = settings.language.code;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        _sectionHeader(L10n.t(lang, 'advanced.cache')),
        const SizedBox(height: 12),
        SwitchListTile(
          title: Text(L10n.t(lang, 'advanced.cache'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lang == 'zh'
              ? '缓存翻译结果，避免重复 API 调用'
              : 'Cache translation results to avoid repeated API calls'),
          value: settings.enableCache,
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(enableCache: v)),
        ),
        const SizedBox(height: 24),
        _sectionHeader(L10n.t(lang, 'advanced.text_protection')),
        const SizedBox(height: 12),
        SwitchListTile(
          title: Text(L10n.t(lang, 'advanced.protect_formulas'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lang == 'zh'
              ? '跳过数学公式和 LaTeX 表达式'
              : 'Skip mathematical formulas and LaTeX expressions'),
          value: settings.protectFormulas,
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(protectFormulas: v)),
        ),
        SwitchListTile(
          title: Text(L10n.t(lang, 'advanced.protect_citations'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lang == 'zh'
              ? '保持引用格式如 [1], (Author, 2024) 不变'
              : 'Keep citation formats like [1], (Author, 2024) unchanged'),
          value: settings.protectCitations,
          onChanged: (v) => appProvider.updateSettings(
              settings.copyWith(protectCitations: v)),
        ),
        const SizedBox(height: 24),
        _sectionHeader(L10n.t(lang, 'advanced.history_size')),
        const SizedBox(height: 12),
        ListTile(
          title: Text(L10n.t(lang, 'advanced.history_size'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${settings.maxHistorySize} entries',
              style: const TextStyle(fontSize: 12)),
          trailing: SizedBox(
            width: 120,
            child: DropdownButtonFormField<int>(
              value: settings.maxHistorySize,
              isDense: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
              ),
              items: [50, 100, 200, 500, 1000].map((v) {
                return DropdownMenuItem(value: v, child: Text('$v'));
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  appProvider.updateSettings(
                      settings.copyWith(maxHistorySize: v));
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        _sectionHeader(L10n.t(lang, 'advanced.proxy')),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: TextEditingController(
                    text: settings.proxyHost ?? ''),
                onChanged: (v) => appProvider.updateSettings(
                    settings.copyWith(proxyHost: v)),
                decoration: InputDecoration(
                  labelText: L10n.t(lang, 'advanced.proxy_host'),
                  hintText: '127.0.0.1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextField(
                controller: TextEditingController(
                    text: settings.proxyPort?.toString() ?? ''),
                onChanged: (v) => appProvider.updateSettings(settings
                    .copyWith(proxyPort: int.tryParse(v))),
                decoration: InputDecoration(
                  labelText: L10n.t(lang, 'advanced.proxy_port'),
                  hintText: '8080',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// Shared Widgets
// ══════════════════════════════════════════════

Widget _engineOption(
  BuildContext context, {
  required String title,
  required String subtitle,
  required models.TranslationEngine value,
  required models.TranslationEngine groupValue,
  required ValueChanged<models.TranslationEngine?> onChanged,
}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: value == groupValue
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        width: 1.5,
      ),
    ),
    child: RadioListTile<models.TranslationEngine>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

Widget _apiKeyField(
  BuildContext context, {
  required String label,
  required String initialValue,
  required ValueChanged<String> onChanged,
  String hint = '',
  bool obscure = false,
}) {
  return TextField(
    controller: TextEditingController(text: initialValue),
    onChanged: onChanged,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

Widget _sectionHeader(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );
}

Widget _dropdownField(
  BuildContext context, {
  required String label,
  required String value,
  required Map<String, String> items,
  required ValueChanged<String> onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: items.containsKey(value) ? value : null,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    items: items.entries.map((e) {
      return DropdownMenuItem(value: e.key, child: Text(e.value));
    }).toList(),
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}

Widget _radioTile(
  BuildContext context, {
  required String title,
  required models.AppThemeMode value,
  required models.AppThemeMode groupValue,
  required ValueChanged<models.AppThemeMode?> onChanged,
}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: RadioListTile<models.AppThemeMode>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}