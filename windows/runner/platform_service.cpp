#include "platform_service.h"
#include "flutter_window.h"
#include <flutter/encodable_value.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

PlatformService::PlatformService(flutter::FlutterEngine* engine)
    : engine_(engine) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine_->messenger(), "com.transquare/platform",
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) { HandleMethodCall(call, std::move(result)); });
}

PlatformService::~PlatformService() = default;

void PlatformService::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto& method_name = method_call.method_name();

  if (method_name == "getClipboardText") {
    GetClipboardText(std::move(result));
  } else if (method_name == "setClipboardText") {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (args) {
      auto it = args->find(flutter::EncodableValue("text"));
      if (it != args->end()) {
        const auto* text = std::get_if<std::string>(&it->second);
        if (text) {
          SetClipboardText(std::move(result), *text);
          return;
        }
      }
    }
    result->Error("INVALID_ARGUMENT", "text argument required");
  } else if (method_name == "copySelectionAndRead") {
    CopySelectionAndRead(std::move(result));
  } else if (method_name == "isListening") {
    result->Success(flutter::EncodableValue(true));
  } else if (method_name == "setWindowOnTop") {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    bool onTop = true;
    if (args) {
      auto it = args->find(flutter::EncodableValue("onTop"));
      if (it != args->end()) {
        onTop = std::get<bool>(it->second);
      }
    }
    SetWindowOnTop(std::move(result), onTop);
  } else if (method_name == "setWindowOpacity") {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    double opacity = 0.95;
    if (args) {
      auto it = args->find(flutter::EncodableValue("opacity"));
      if (it != args->end()) {
        opacity = std::get<double>(it->second);
      }
    }
    SetWindowOpacity(std::move(result), opacity);
  } else if (method_name == "setMiddleMouseEnabled") {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    bool enabled = false;
    if (args) {
      auto it = args->find(flutter::EncodableValue("enabled"));
      if (it != args->end()) {
        enabled = std::get<bool>(it->second);
      }
    }
    // Call FlutterWindow's static method
    FlutterWindow::SetMiddleMouseEnabled(enabled);
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

void PlatformService::GetClipboardText(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::string text = ReadClipboardText();
  result->Success(flutter::EncodableValue(text));
}

void PlatformService::SetClipboardText(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
    const std::string& text) {
  if (!OpenClipboard(nullptr)) {
    result->Error("CLIPBOARD_ERROR", "Cannot open clipboard");
    return;
  }

  EmptyClipboard();

  int wideLen = MultiByteToWideChar(CP_UTF8, 0, text.c_str(), -1, nullptr, 0);
  HANDLE hMem = GlobalAlloc(GMEM_MOVEABLE, wideLen * sizeof(wchar_t));
  if (hMem) {
    wchar_t* pMem = static_cast<wchar_t*>(GlobalLock(hMem));
    MultiByteToWideChar(CP_UTF8, 0, text.c_str(), -1, pMem, wideLen);
    GlobalUnlock(hMem);
    SetClipboardData(CF_UNICODETEXT, hMem);
  }

  CloseClipboard();
  result->Success(flutter::EncodableValue(true));
}

void PlatformService::CopySelectionAndRead(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::string oldClipboard = ReadClipboardText();

  SimulateCopy();

  Sleep(200);

  std::string newText = ReadClipboardText();

  if (!oldClipboard.empty() && oldClipboard != newText) {
    if (OpenClipboard(nullptr)) {
      EmptyClipboard();
      int wideLen = MultiByteToWideChar(CP_UTF8, 0, oldClipboard.c_str(), -1, nullptr, 0);
      HANDLE hMem = GlobalAlloc(GMEM_MOVEABLE, wideLen * sizeof(wchar_t));
      if (hMem) {
        wchar_t* pMem = static_cast<wchar_t*>(GlobalLock(hMem));
        MultiByteToWideChar(CP_UTF8, 0, oldClipboard.c_str(), -1, pMem, wideLen);
        GlobalUnlock(hMem);
        SetClipboardData(CF_UNICODETEXT, hMem);
      }
      CloseClipboard();
    }
  }

  result->Success(flutter::EncodableValue(newText));
}

void PlatformService::SetWindowOnTop(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
    bool onTop) {
  HWND hwnd = GetActiveWindow();
  if (hwnd) {
    if (onTop) {
      SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0,
                   SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    } else {
      SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0,
                   SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    }
  }
  result->Success(flutter::EncodableValue(true));
}

void PlatformService::SetWindowOpacity(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
    double opacity) {
  HWND hwnd = GetActiveWindow();
  if (hwnd) {
    SetWindowLong(hwnd, GWL_EXSTYLE,
                  GetWindowLong(hwnd, GWL_EXSTYLE) | WS_EX_LAYERED);
    SetLayeredWindowAttributes(hwnd, 0,
                               static_cast<BYTE>(opacity * 255), LWA_ALPHA);
  }
  result->Success(flutter::EncodableValue(true));
}

std::string PlatformService::ReadClipboardText() {
  std::string result;

  if (!IsClipboardFormatAvailable(CF_UNICODETEXT)) {
    return result;
  }

  if (!OpenClipboard(nullptr)) {
    return result;
  }

  HANDLE hData = GetClipboardData(CF_UNICODETEXT);
  if (hData) {
    wchar_t* pText = static_cast<wchar_t*>(GlobalLock(hData));
    if (pText) {
      int utf8Len = WideCharToMultiByte(CP_UTF8, 0, pText, -1, nullptr, 0,
                                        nullptr, nullptr);
      if (utf8Len > 0) {
        std::string utf8Str(utf8Len - 1, '\0');
        WideCharToMultiByte(CP_UTF8, 0, pText, -1, &utf8Str[0], utf8Len,
                            nullptr, nullptr);
        result = utf8Str;
      }
      GlobalUnlock(hData);
    }
  }

  CloseClipboard();
  return result;
}

void PlatformService::SimulateCopy() {
  // Check modifier keys physically held by the user.
  // If we send Ctrl+C while Shift/Alt are also held, the target
  // application may interpret it as Ctrl+Shift+C (e.g. Edge DevTools).
  // Solution: temporarily release Shift/Alt, send Ctrl+C, then restore.
  bool ctrlHeld = (GetAsyncKeyState(VK_CONTROL) & 0x8000) != 0;
  bool shiftHeld = (GetAsyncKeyState(VK_SHIFT) & 0x8000) != 0;
  bool altHeld = (GetAsyncKeyState(VK_MENU) & 0x8000) != 0;

  INPUT inputs[8] = {};
  ZeroMemory(inputs, sizeof(INPUT));
  int count = 0;

  // Release Shift/Alt so only Ctrl+C reaches the target
  if (shiftHeld) {
    inputs[count].type = INPUT_KEYBOARD;
    inputs[count].ki.wVk = VK_SHIFT;
    inputs[count].ki.dwFlags = KEYEVENTF_KEYUP;
    count++;
  }
  if (altHeld) {
    inputs[count].type = INPUT_KEYBOARD;
    inputs[count].ki.wVk = VK_MENU;
    inputs[count].ki.dwFlags = KEYEVENTF_KEYUP;
    count++;
  }
  // Only send Ctrl DOWN if not already held by user
  if (!ctrlHeld) {
    inputs[count].type = INPUT_KEYBOARD;
    inputs[count].ki.wVk = VK_CONTROL;
    count++;
  }

  // C key DOWN
  inputs[count].type = INPUT_KEYBOARD;
  inputs[count].ki.wVk = 'C';
  count++;

  // C key UP
  inputs[count].type = INPUT_KEYBOARD;
  inputs[count].ki.wVk = 'C';
  inputs[count].ki.dwFlags = KEYEVENTF_KEYUP;
  count++;

  // Only send Ctrl UP if we sent Ctrl DOWN
  if (!ctrlHeld) {
    inputs[count].type = INPUT_KEYBOARD;
    inputs[count].ki.wVk = VK_CONTROL;
    inputs[count].ki.dwFlags = KEYEVENTF_KEYUP;
    count++;
  }

  // Restore modifiers that were temporarily released
  if (altHeld) {
    inputs[count].type = INPUT_KEYBOARD;
    inputs[count].ki.wVk = VK_MENU;
    count++;
  }
  if (shiftHeld) {
    inputs[count].type = INPUT_KEYBOARD;
    inputs[count].ki.wVk = VK_SHIFT;
    count++;
  }

  SendInput(count, inputs, sizeof(INPUT));
  Sleep(150);
}