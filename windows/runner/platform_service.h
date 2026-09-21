#ifndef RUNNER_PLATFORM_SERVICE_H_
#define RUNNER_PLATFORM_SERVICE_H_

#include <flutter/flutter_engine.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <string>

class PlatformService {
 public:
  explicit PlatformService(flutter::FlutterEngine* engine);
  ~PlatformService();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void GetClipboardText(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void SetClipboardText(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
      const std::string& text);
  void CopySelectionAndRead(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void SetWindowOnTop(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
      bool onTop);
  void SetWindowOpacity(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
      double opacity);

  std::string ReadClipboardText();
  void SimulateCopy();

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  flutter::FlutterEngine* engine_;
};

#endif  // RUNNER_PLATFORM_SERVICE_H_