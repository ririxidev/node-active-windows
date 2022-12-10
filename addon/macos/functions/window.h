#include <napi.h>

Napi::Array getWindows(const Napi::CallbackInfo& info);
Napi::Object getWindowInfo(const Napi::CallbackInfo& info);
Napi::Object getActiveWindow(const Napi::CallbackInfo& info);
Napi::Boolean isWindowActive(const Napi::CallbackInfo& info);
Napi::String getWindowTitle(const Napi::CallbackInfo& info);
Napi::Buffer<char> getAppIcon(const Napi::CallbackInfo &info);
