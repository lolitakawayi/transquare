/// Lightweight localization support for Transquare.
/// Supports Chinese (default) and English.
///
/// Usage:
/// ```dart
/// final lang = context.watch<AppProvider>().settings.language;
/// Text(L10n.t(lang, 'app.home'))
/// ```
class L10n {
  /// Get translated string for [key] in the given [languageCode].
  /// [languageCode] can be 'zh' or 'en'.
  /// Falls back to Chinese if key is missing.
  static String t(String languageCode, String key) {
    final map = languageCode == 'en' ? _en : _zh;
    return map[key] ?? key;
  }

  /// Get all translation keys for a given language code.
  static Map<String, String> all(String languageCode) {
    return Map.from(languageCode == 'en' ? _en : _zh);
  }

  // ========== ZH (Chinese) ==========
  static const Map<String, String> _zh = {
    // App
    'app.title': 'Transquare',
    'app.subtitle': '学术翻译助手',
    'app.listening_enabled': '监听已开启',
    'app.listening_disabled': '监听已关闭',
    'app.home': '首页',
    'app.history': '历史',
    'app.vocabulary': '生词本',
    'app.settings': '设置',
    'app.quick_translate': '快速翻译',
    'app.hotkey_hint': '按',
    'app.engine': '翻译引擎：',
    'app.glossary_count': '术语表：',
    'app.vocab_count': '生词本：',

    // Floating window
    'floating.compact_view': '紧凑视图',
    'floating.side_by_side': '双栏对照',
    'floating.pin_window': '固定窗口',
    'floating.translating': '翻译中...',
    'floating.retry': '重试',
    'floating.input_hint': '输入文本或划词后按 Ctrl+Shift+T...',
    'floating.translate_btn': '翻译',

    // History
    'history.title': '翻译记录',
    'history.search_hint': '搜索翻译记录...',
    'history.empty': '暂无翻译记录',
    'history.clear_all': '清空全部',
    'history.confirm_clear': '确定清空全部历史记录？',
    'history.cancel': '取消',
    'history.confirm': '确定',
    'history.copy': '已复制',
    'history.engine': '引擎',
    'history.cached': '缓存',
    'history.live': '实时',

    // Vocabulary
    'vocab.title': '生词本',
    'vocab.all': '全部',
    'vocab.mastered': '已掌握',
    'vocab.unmastered': '未掌握',
    'vocab.empty': '暂无生词',
    'vocab.mark_learning': '标记为学习中',
    'vocab.mark_mastered': '标记为已掌握',
    'vocab.add_to_vocab': '加入生词本',
    'vocab.export_csv': '导出 CSV',
    'vocab.export_anki': '导出 Anki',
    'vocab.export_success': '导出成功',
    'vocab.search_hint': '搜索生词...',

    // Settings - General
    'settings.title': '设置',
    'settings.engine': '翻译引擎',
    'settings.shortcuts': '快捷键',
    'settings.glossary': '术语表',
    'settings.appearance': '外观',
    'settings.advanced': '高级',
    'settings.language': '系统语言',
    'settings.language_zh': '中文',
    'settings.language_en': 'English',

    // Settings - Engine
    'engine.title': '翻译引擎',
    'engine.google': 'Google 翻译',
    'engine.google_desc': '高质量翻译，需 Google Cloud API 密钥',
    'engine.microsoft': 'Microsoft Translator',
    'engine.microsoft_desc': '需 Azure 认知服务密钥',
    'engine.deepl': 'DeepL',
    'engine.deepl_desc': '最适合欧洲语言，提供免费版',
    'engine.baidu': '百度翻译',
    'engine.baidu_desc': '最适合中文，需标准版或高级版 API 密钥',
    'engine.api_key': 'API 密钥',
    'engine.api_key_hint': '输入 {name} API 密钥',
    'engine.app_id': 'App ID',
    'engine.secret_key': '密钥',
    'engine.source_lang': '源语言',
    'engine.target_lang': '目标语言',
    'engine.auto_detect': '自动检测',

    // Settings - Shortcuts
    'shortcut.trigger': '触发翻译',
    'shortcut.modifiers': '修饰键',
    'shortcut.key': '按键',
    'shortcut.middle_mouse': '启用鼠标中键触发',

    // Settings - Glossary
    'glossary.title': '术语表',
    'glossary.import': '导入 CSV',
    'glossary.export': '导出',
    'glossary.add': '添加',
    'glossary.source': '原文',
    'glossary.translation': '译文',
    'glossary.empty': '暂无术语条目',
    'glossary.import_success': '导入成功',

    // Settings - Appearance
    'appearance.theme': '主题',
    'appearance.system': '跟随系统',
    'appearance.light': '浅色',
    'appearance.dark': '深色',
    'appearance.font_size': '字体大小',
    'appearance.window_opacity': '窗口透明度',

    // Settings - Advanced
    'advanced.proxy': '代理设置',
    'advanced.proxy_host': '代理主机',
    'advanced.proxy_port': '代理端口',
    'advanced.cache': '启用翻译缓存',
    'advanced.text_protection': '文本保护',
    'advanced.protect_formulas': '保护公式（LaTeX）',
    'advanced.protect_citations': '保护引用格式',
    'advanced.history_size': '历史记录数量',

    // Translation card
    'card.cached': '缓存',
    'card.live': '实时',
    'card.copy_source': '复制原文',
    'card.copy_translation': '复制译文',
    'card.copy_success': '译文已复制到剪贴板',
    'card.add_to_vocabulary': '加入生词本',
    'card.vocab_success': '已添加到生词本',

    // Side by side
    'sbs.original': '原文',
    'sbs.translation': '译文',

    // Theme mode
    'theme.system': '跟随系统',
    'theme.light': '浅色',
    'theme.dark': '深色',

    // OCR
    'ocr.title': 'OCR 取词',
    'ocr.capture': '截屏识别',
    'ocr.processing': '识别中...',
    'ocr.no_text': '未识别到文字',

    // TTS
    'tts.play': '朗读',
    'tts.playing': '朗读中...',

    // Errors
    'error.unknown': '未知错误',
    'error.no_text': '没有可翻译的文本',
    'error.network': '网络连接失败，请检查网络',
    'error.api_key': '请先配置 API 密钥',
  };

  // ========== EN (English) ==========
  static const Map<String, String> _en = {
    // App
    'app.title': 'Transquare',
    'app.subtitle': 'Academic Translation Assistant',
    'app.listening_enabled': 'Listening enabled',
    'app.listening_disabled': 'Listening disabled',
    'app.home': 'Home',
    'app.history': 'History',
    'app.vocabulary': 'Vocabulary',
    'app.settings': 'Settings',
    'app.quick_translate': 'Quick Translate',
    'app.hotkey_hint': 'Press',
    'app.engine': 'Engine: ',
    'app.glossary_count': 'Glossary: ',
    'app.vocab_count': 'Vocabulary: ',

    // Floating window
    'floating.compact_view': 'Compact view',
    'floating.side_by_side': 'Side-by-side view',
    'floating.pin_window': 'Pin window',
    'floating.translating': 'Translating...',
    'floating.retry': 'Retry',
    'floating.input_hint': 'Type text or select text and press Ctrl+Shift+T...',
    'floating.translate_btn': 'Translate',

    // History
    'history.title': 'Translation History',
    'history.search_hint': 'Search history...',
    'history.empty': 'No translation history',
    'history.clear_all': 'Clear All',
    'history.confirm_clear': 'Clear all history?',
    'history.cancel': 'Cancel',
    'history.confirm': 'Confirm',
    'history.copy': 'Copied',
    'history.engine': 'Engine',
    'history.cached': 'cached',
    'history.live': 'live',

    // Vocabulary
    'vocab.title': 'Vocabulary',
    'vocab.all': 'All',
    'vocab.mastered': 'Mastered',
    'vocab.unmastered': 'Unmastered',
    'vocab.empty': 'No vocabulary entries',
    'vocab.mark_learning': 'Mark as learning',
    'vocab.mark_mastered': 'Mark as mastered',
    'vocab.add_to_vocab': 'Add to vocabulary',
    'vocab.export_csv': 'Export CSV',
    'vocab.export_anki': 'Export Anki',
    'vocab.export_success': 'Export successful',
    'vocab.search_hint': 'Search vocabulary...',

    // Settings - General
    'settings.title': 'Settings',
    'settings.engine': 'Engine',
    'settings.shortcuts': 'Shortcuts',
    'settings.glossary': 'Glossary',
    'settings.appearance': 'Appearance',
    'settings.advanced': 'Advanced',
    'settings.language': 'Language',
    'settings.language_zh': '中文',
    'settings.language_en': 'English',

    // Settings - Engine
    'engine.title': 'Translation Engine',
    'engine.google': 'Google Translate',
    'engine.google_desc': 'High quality, requires Google Cloud API key',
    'engine.microsoft': 'Microsoft Translator',
    'engine.microsoft_desc': 'Requires Azure Cognitive Services key',
    'engine.deepl': 'DeepL',
    'engine.deepl_desc': 'Best for European languages, free tier available',
    'engine.baidu': 'Baidu Translate',
    'engine.baidu_desc': 'Best for Chinese, requires API key',
    'engine.api_key': 'API Key',
    'engine.api_key_hint': 'Enter {name} API Key',
    'engine.app_id': 'App ID',
    'engine.secret_key': 'Secret Key',
    'engine.source_lang': 'Source Language',
    'engine.target_lang': 'Target Language',
    'engine.auto_detect': 'Auto Detect',

    // Settings - Shortcuts
    'shortcut.trigger': 'Trigger Translation',
    'shortcut.modifiers': 'Modifiers',
    'shortcut.key': 'Key',
    'shortcut.middle_mouse': 'Enable middle mouse button',

    // Settings - Glossary
    'glossary.title': 'Glossary',
    'glossary.import': 'Import CSV',
    'glossary.export': 'Export',
    'glossary.add': 'Add',
    'glossary.source': 'Source',
    'glossary.translation': 'Translation',
    'glossary.empty': 'No glossary entries',
    'glossary.import_success': 'Import successful',

    // Settings - Appearance
    'appearance.theme': 'Theme',
    'appearance.system': 'System',
    'appearance.light': 'Light',
    'appearance.dark': 'Dark',
    'appearance.font_size': 'Font Size',
    'appearance.window_opacity': 'Window Opacity',

    // Settings - Advanced
    'advanced.proxy': 'Proxy Settings',
    'advanced.proxy_host': 'Proxy Host',
    'advanced.proxy_port': 'Proxy Port',
    'advanced.cache': 'Enable translation cache',
    'advanced.text_protection': 'Text Protection',
    'advanced.protect_formulas': 'Protect formulas (LaTeX)',
    'advanced.protect_citations': 'Protect citation formats',
    'advanced.history_size': 'History size',

    // Translation card
    'card.cached': 'cached',
    'card.live': 'live',
    'card.copy_source': 'Copy source',
    'card.copy_translation': 'Copy translation',
    'card.copy_success': 'Translation copied',
    'card.add_to_vocabulary': 'Add to vocabulary',
    'card.vocab_success': 'Added to vocabulary',

    // Side by side
    'sbs.original': 'Original',
    'sbs.translation': 'Translation',

    // Theme mode
    'theme.system': 'System',
    'theme.light': 'Light',
    'theme.dark': 'Dark',

    // OCR
    'ocr.title': 'OCR Capture',
    'ocr.capture': 'Screen Capture',
    'ocr.processing': 'Processing...',
    'ocr.no_text': 'No text recognized',

    // TTS
    'tts.play': 'Play',
    'tts.playing': 'Playing...',

    // Errors
    'error.unknown': 'Unknown error',
    'error.no_text': 'No text to translate',
    'error.network': 'Network connection failed',
    'error.api_key': 'Please configure API key first',
  };
}