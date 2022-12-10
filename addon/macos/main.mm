#import "functions/window.h"

#include <napi.h>

// Apple APIs
#import "CoreGraphics/CoreGraphics.h"

void _askForScreenCaptureAccess(const Napi::CallbackInfo &info) {
    if (@available(macOS 10.16, *)) {
        CGRequestScreenCaptureAccess();
    }
}

bool _checkScreenCaptureAccess() {
    bool hasPerms;
    if (@available(macOS 10.16, *)) {
        hasPerms = CGPreflightScreenCaptureAccess();
    } else {
        hasPerms = true;
    }

    return hasPerms;
}

// Node

Napi::Boolean checkScreenCaptureAccess(const Napi::CallbackInfo &info) {
    Napi::Env env{info.Env()};
    return Napi::Boolean::New(env, _checkScreenCaptureAccess());
}


Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set("askForScreenCaptureAccess", Napi::Function::New(env, _askForScreenCaptureAccess));
  exports.Set("checkScreenCaptureAccess", Napi::Function::New(env, checkScreenCaptureAccess));
  exports.Set("getWindowTitle", Napi::Function::New(env, getWindowTitle));
  exports.Set("getWindowInfo", Napi::Function::New(env, getWindowInfo));
  exports.Set("isWindowActive", Napi::Function::New(env, isWindowActive));
  exports.Set("getActiveWindow", Napi::Function::New(env, getActiveWindow));
  exports.Set("getWindows", Napi::Function::New(env, getWindows));
  exports.Set("getAppIcon", Napi::Function::New(env, getAppIcon));
  return exports;
}

NODE_API_MODULE(addon, Init)