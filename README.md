# Transquare/译方

> 一款面向学术阅读的 Windows 翻译工具 · A Powerful Translation Tool for Academic Reading on Windows

[中文](#中文) | [English](#english)

---

## 中文

### 简介

Transquare 是一款专为 Windows 平台设计的翻译工具，旨在帮助用户在阅读学术文献、外文资料时快速获取翻译结果。它支持**全局快捷键取词翻译**、**剪贴板监听自动翻译**，并提供**术语表**、**生词本**、**翻译历史**、**收藏夹**等辅助学习功能。

### 核心特性

| 特性 | 说明 |
|------|------|
| 🔤 **多引擎翻译** | 内置 6 种翻译引擎：Google、Microsoft、DeepL、百度、Google Free（免 Key 直连）、MyMemory（免费免注册） |
| 🪟 **双窗口设计** | 主窗口管理词库和学习数据，悬浮窗快速显示翻译结果 |
| ⌨️ **全局热键** | 选中文本后按 `Ctrl+Shift+T`（可自定义）或者点击鼠标中键即刻翻译 |
| 📋 **剪贴板监听** | 开启后自动翻译复制到剪贴板的文本 |
| 📖 **术语表** | 自定义翻译术语对，支持 XLSX 批量导入/导出 |
| 📝 **生词本** | 保存生词，随时复习 |
| ⭐ **收藏夹** | 收藏重要翻译记录 |
| 📜 **翻译历史** | 自动记录翻译历史，支持搜索 |
| 🔊 **语音朗读** | 基于 Windows SAPI 引擎的原文/译文朗读 |
| 🎨 **外观自定义** | 明暗主题、窗口透明度、中英双语界面 |
| 🔗 **代理支持** | 支持 HTTP 代理，方便内网或受限网络环境使用 |
| 📌 **窗口置顶** | 悬浮窗口可置顶，随时参考翻译结果 |

### 翻译引擎

| 引擎 | 需要 API Key | 说明 |
|------|:---:|------|
| **Google** | ✅ | Google Cloud Translation API |
| **Microsoft** | ✅ | Azure Translator Text API |
| **DeepL** | ✅ | DeepL API（高质量翻译） |
| **百度** | ✅ | 百度翻译开放平台 |
| **Google Free** | ❌ | 免 Key 直连，适合急需翻译的用户 |
| **MyMemory** | ❌ | 免费免注册，基于翻译记忆库 |

### 系统要求

- **操作系统**：Windows 10/11 (x64)
- **运行时**：无需额外依赖，Flutter 编译为原生 Windows 应用

### 安装与运行

#### 下载发行版

1. 前往 [Releases](https://github.com/lolitakawayi/transquare/releases) 页面
2. 下载最新的 `Transquare-Windows.zip` 压缩包
3. 解压后，双击 `transquare.exe` 即可运行

#### 从源码构建

```bash
# 1. 克隆仓库
git clone https://github.com/lolitakawayi/transquare.git
cd transquare

# 2. 安装依赖
flutter pub get

# 3. 运行
flutter run -d windows

# 4. 构建发布版本
flutter build windows
```

构建产物位于 `build/windows/x64/runner/Release/` 目录。

### 使用指南

#### 快速翻译

1. **全局快捷键**：在任意应用中选中文本 → 按 `Ctrl+Shift+T` → 弹出翻译悬浮窗
2. **剪贴板监听**：开启后，复制文本即自动翻译
3. **主窗口输入**：在主界面右上角输入文本，点击翻译按钮

#### 术语表

- 在「设置 → 术语表」中手动添加术语对（原文 + 译文）
- 支持 XLSX 批量导入/导出
- 翻译时自动替换匹配的术语，确保专业词汇翻译准确

#### 生词本

- 翻译卡片底部点击「添加」按钮保存生词
- 支持搜索和正序/倒序排列

#### 收藏夹

- 在翻译历史中点击星标收藏
- 收藏的条目会从历史列表移到收藏夹
- 取消收藏后回到历史顶部

#### 快捷键自定义

在「设置 → 常规」中可修改翻译快捷键，修改后即时生效。

### 项目结构

```
lib/
├── main.dart              # 应用入口，初始化服务
├── app.dart                # 主窗口与悬浮窗管理
├── models/                 # 数据模型
├── providers/              # Provider 状态管理
├── services/               # 业务逻辑层
│   ├── translation_service.dart
│   ├── translators/        # 各翻译引擎实现
│   ├── glossary_service.dart
│   ├── history_service.dart
│   ├── vocabulary_service.dart
│   ├── tts_service.dart    # 语音朗读服务
│   ├── cache_service.dart
│   └── text_processor.dart
├── platform/               # 平台相关服务
├── l10n/                   # 国际化字符串
└── ui/                     # 界面组件
    ├── settings/           # 设置界面
    ├── history/            # 翻译历史
    ├── vocabulary/         # 生词本
    ├── favorites/          # 收藏夹
    ├── floating_window.dart
    └── components/         # 可复用组件
```

### 技术栈

- **框架**：Flutter 3.x + Dart
- **状态管理**：Provider
- **窗口管理**：window_manager（无边框窗口、置顶、系统托盘）
- **热键**：hotkey_manager（全局快捷键注册）
- **本地存储**：SharedPreferences + JSON 文件
- **网络请求**：HTTP 包 + 代理支持
- **XLSX 处理**：Excel 包（导出）+ Archive/XML 手工解析（导入）
- **TTS**：PowerShell 调用 Windows SAPI 引擎

---

## English

### Overview

Transquare is a translation tool designed for Windows, built to help users quickly obtain translations while reading academic papers and foreign-language materials. It features **global hotkey translation**, **clipboard monitoring**, and auxiliary learning tools including a **glossary**, **vocabulary book**, **translation history**, and **favorites**.

### Key Features

| Feature | Description |
|---------|-------------|
| 🔤 **Multi-Engine Translation** | 6 built-in engines: Google, Microsoft, DeepL, Baidu, Google Free (no key), MyMemory (free, no registration) |
| 🪟 **Dual-Window Design** | Main window for vocabulary management; floating window for instant translation results |
| ⌨️ **Global Hotkey** | Select text anywhere and press `Ctrl+Shift+T` (customizable) or click the middle mouse button to translate |
| 📋 **Clipboard Monitoring** | Automatically translates copied text when enabled |
| 📖 **Glossary** | Custom term pairs with XLSX batch import/export |
| 📝 **Vocabulary Book** | Save and review new words |
| ⭐ **Favorites** | Bookmark important translations |
| 📜 **Translation History** | Auto-saved history with search support |
| 🔊 **Text-to-Speech** | Read source/target text via Windows SAPI engine |
| 🎨 **Appearance** | Light/dark themes, window opacity, bilingual UI (Chinese/English) |
| 🔗 **Proxy Support** | HTTP proxy for restricted network environments |
| 📌 **Always on Top** | Keep the floating window above other windows |

### Translation Engines

| Engine | API Key Required | Notes |
|--------|:---:|-------|
| **Google** | ✅ (Cloud) | Google Cloud Translation API |
| **Microsoft** | ✅ (Azure) | Azure Translator Text API |
| **DeepL** | ✅ (DeepL) | DeepL API — high-quality translations |
| **Baidu** | ✅ (Baidu) | Baidu Translate Open Platform |
| **Google Free** | ❌ | Direct connection, no key needed |
| **MyMemory** | ❌ | Free, no registration; translation memory-based |

### System Requirements

- **OS**: Windows 10/11 (x64)
- **Runtime**: None — compiled as a native Windows application via Flutter

### Installation & Running

#### Download Release 

1. Go to the [Releases](https://github.com/lolitakawayi/transquare/releases) page
2. Download the latest `Transquare-Windows.zip`
3. Extract and double-click `transquare.exe` to run

#### Build from Source

```bash
# 1. Clone the repository
git clone https://github.com/lolitakawayi/transquare.git
cd transquare

# 2. Install dependencies
flutter pub get

# 3. Run
flutter run -d windows

# 4. Build release
flutter build windows
```

The release build is located in `build/windows/x64/runner/Release/`.

### Usage

#### Quick Translation

1. **Global Hotkey**: Select text in any application → press `Ctrl+Shift+T` → translation floating window appears
2. **Clipboard Monitoring**: Enable it to auto-translate text on copy
3. **Main Window Input**: Type or paste text in the main window and click the translate button

#### Glossary

- Add term pairs (source + target) manually in **Settings → Glossary**
- XLSX batch import/export supported
- Matching terms are automatically applied during translation

#### Vocabulary Book

- Click the "Add" button at the bottom of translation cards to save words
- Search and sort (newest/oldest first) supported

#### Favorites

- Star a translation in the history list to move it to Favorites
- Un-favoriting returns it to the top of History

#### Customize Shortcuts

Change the translation hotkey in **Settings → General**. Takes effect immediately.

### Project Structure

```
lib/
├── main.dart              # Entry point, service initialization
├── app.dart                # Main window & floating window management
├── models/                 # Data models
├── providers/              # Provider state management
├── services/               # Business logic layer
│   ├── translation_service.dart
│   ├── translators/        # Translation engine implementations
│   ├── glossary_service.dart
│   ├── history_service.dart
│   ├── vocabulary_service.dart
│   ├── tts_service.dart    # Text-to-speech service
│   ├── cache_service.dart
│   └── text_processor.dart
├── platform/               # Platform-specific services
├── l10n/                   # Internationalization strings
└── ui/                     # UI components
    ├── settings/           # Settings screen
    ├── history/            # Translation history
    ├── vocabulary/         # Vocabulary book
    ├── favorites/          # Favorites
    ├── floating_window.dart
    └── components/         # Reusable widgets
```

### Tech Stack

- **Framework**: Flutter 3.x + Dart
- **State Management**: Provider
- **Window Control**: window_manager (frameless windows, always-on-top, system tray)
- **Hotkeys**: hotkey_manager (global shortcut registration)
- **Storage**: SharedPreferences + JSON files
- **Networking**: HTTP package with proxy support
- **XLSX Handling**: Excel package (export) + Archive/XML manual parsing (import)
- **TTS**: PowerShell invoking Windows SAPI engine

---

## License

MIT
