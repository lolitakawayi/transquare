#include "flutter_window.h"

#include <optional>
#include <atomic>

#include "flutter/generated_plugin_registrant.h"
bool FlutterWindow::middle_mouse_enabled_ = false;

FlutterWindow* FlutterWindow::instance_ = nullptr;

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {
  UnregisterGlobalHotkey();
  if (mouse_hook_) {
    UnhookWindowsHookEx(mouse_hook_);
  }
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);

  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  platform_service_ =
      std::make_unique<PlatformService>(flutter_controller_->engine());

  instance_ = this;

  RegisterGlobalHotkey();

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  flutter_controller_->ForceRedraw();

  return true;
}

LRESULT CALLBACK FlutterWindow::LowLevelMouseProc(int nCode, WPARAM wParam, LPARAM lParam) {
  if (nCode == HC_ACTION && middle_mouse_enabled_) {
    if (wParam == WM_MBUTTONDOWN) {
      if (instance_ && instance_->flutter_controller_) {
        PostMessage(instance_->GetHandle(),
                    kMsgMiddleMouseTranslate, 0, 0);
      }
      return 1;
    }
  }
  return CallNextHookEx(nullptr, nCode, wParam, lParam);
}

void FlutterWindow::OnDestroy() {
  UnregisterGlobalHotkey();
  if (mouse_hook_) {
    UnhookWindowsHookEx(mouse_hook_);
  }

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;

    case kMsgMiddleMouseTranslate:
      HandleHotkey(kHotkeyIdTranslate);
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::RegisterGlobalHotkey() {
  // Hotkey registration is now managed by the Dart side via hotkey_manager
}

void FlutterWindow::UnregisterGlobalHotkey() {
  // Hotkey unregistration is now managed by the Dart side
}

void FlutterWindow::HandleHotkey(int id) {
  if (id == kHotkeyIdTranslate && flutter_controller_) {
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        flutter_controller_->engine()->messenger(),
        "com.transquare/hotkey",
        &flutter::StandardMethodCodec::GetInstance());

    channel->InvokeMethod("onHotkeyTranslate", nullptr);
  }
}

void FlutterWindow::SetMiddleMouseEnabled(bool enabled) {
  if (!instance_) return;
  
  middle_mouse_enabled_ = enabled;
  
  if (enabled && !instance_->mouse_hook_) {
    instance_->mouse_hook_ = SetWindowsHookEx(
        WH_MOUSE_LL,
        LowLevelMouseProc,
        GetModuleHandle(nullptr),
        0);
    if (instance_->mouse_hook_) {
      OutputDebugStringW(L"Transquare: Middle mouse hook installed\n");
    }
  } else if (!enabled && instance_->mouse_hook_) {
    UnhookWindowsHookEx(instance_->mouse_hook_);
    instance_->mouse_hook_ = nullptr;
    OutputDebugStringW(L"Transquare: Middle mouse hook removed\n");
  }
}