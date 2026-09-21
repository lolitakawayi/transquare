#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"
#include "platform_service.h"

class FlutterWindow : public Win32Window {
 public:
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

  // Controls middle-mouse-based translation trigger
  static void SetMiddleMouseEnabled(bool enabled);

 protected:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  flutter::DartProject project_;

  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  std::unique_ptr<PlatformService> platform_service_;

  static constexpr int kHotkeyIdTranslate = 1;
  static constexpr int kHotkeyModCtrlShift = MOD_CONTROL | MOD_SHIFT;
  static constexpr UINT kMsgMiddleMouseTranslate = WM_APP + 1;
  
  void RegisterGlobalHotkey();
  void UnregisterGlobalHotkey();
  void HandleHotkey(int id);
  
  static FlutterWindow* instance_;
  static LRESULT CALLBACK LowLevelMouseProc(int nCode, WPARAM wParam,
                                             LPARAM lParam);
  HHOOK mouse_hook_ = nullptr;
  static bool middle_mouse_enabled_;  
};

#endif  // RUNNER_FLUTTER_WINDOW_H_