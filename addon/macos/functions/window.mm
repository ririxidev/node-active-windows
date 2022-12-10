#import "../main.h"

#include <napi.h>

// Apple APIs
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NSDictionary* getWindow(int windowid) {
  CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
  CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);

  for (NSDictionary *info in (NSArray *)windowList) {
    NSNumber *wID = info[(id)kCGWindowNumber];

    if ([wID intValue] == windowid) {
        CFRetain(info);
        CFRelease(windowList);
        return info;
    }
  }

  CFRelease(windowList);
  return NULL;
}

Napi::Object getWindowInfo(const Napi::CallbackInfo &info) {
  Napi::Env env{info.Env()};

  if (!_checkScreenCaptureAccess()) {
    Napi::Error::New(env, "Screen Capture permission is required").ThrowAsJavaScriptException();
    return Napi::Object::New(env);
  }

  int windowid = info[0].As<Napi::Number>().Int32Value();

  NSDictionary *window = getWindow(windowid);

  if (!window) {
    return Napi::Object::New(env);
  }

  NSNumber *appPid = window[(id)kCGWindowOwnerPID];

  NSRunningApplication *application = [NSRunningApplication runningApplicationWithProcessIdentifier: [appPid intValue]];

  Napi::Object windowObj = Napi::Object::New(env);
  windowObj.Set("pid", [appPid intValue]);
  windowObj.Set("bundlePath", [application.bundleURL.path UTF8String]);

  return windowObj;
}

Napi::Buffer<char> getAppIcon(const Napi::CallbackInfo &info) {
  Napi::Env env{info.Env()};

  std::string bundlePath = info[0].As<Napi::String>().Utf8Value();
  int size = info[1].As<Napi::Number>().Int32Value();

  NSImage *appImage = [[NSWorkspace sharedWorkspace] iconForFile: [NSString stringWithUTF8String: bundlePath.c_str()]];

  [appImage setSize: NSMakeSize(size, size)];

  NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData: [appImage TIFFRepresentation]];

  NSData *img = [imageRep representationUsingType: NSBitmapImageFileTypePNG properties: @{}];

  return Napi::Buffer<char>::Copy(env, (char *)[img bytes], [img length]);
}

Napi::String getWindowTitle(const Napi::CallbackInfo &info) {
  Napi::Env env{info.Env()};

  if (!_checkScreenCaptureAccess()) {
    Napi::Error::New(env, "Screen Capture permission is required").ThrowAsJavaScriptException();
    return Napi::String::New(env, "");
  }

  int windowid = info[0].As<Napi::Number>().Int32Value();

  NSDictionary *window = getWindow(windowid);

  if (!window) {
    return Napi::String::New(env, "");
  }

  NSString *windowTitle = window[(id)kCGWindowName];

  return Napi::String::New(env, [windowTitle UTF8String]);
}

Napi::Object getActiveWindow(const Napi::CallbackInfo &info) {
  Napi::Env env{info.Env()};

  if (!_checkScreenCaptureAccess()) {
    Napi::Error::New(env, "Screen Capture permission is required").ThrowAsJavaScriptException();
    return Napi::Object::New(env);
  }

  CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
  CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);

  Napi::Object windowObj = Napi::Object::New(env);

  for (NSDictionary *window in (NSArray *)windowList) {
    NSNumber *appPid = window[(id)kCGWindowOwnerPID];
    NSNumber *windowID = window[(id)kCGWindowNumber];
    NSString *windowTitle = window[(id)kCGWindowName];

    NSRunningApplication *application = [NSRunningApplication runningApplicationWithProcessIdentifier: [appPid intValue]];

    if ([application isActive]) {
      windowObj.Set("windowID", Napi::Number::New(env, [windowID intValue]));
      windowObj.Set("title", Napi::String::New(env, [windowTitle UTF8String]));
      windowObj.Set("pid", Napi::Number::New(env, [appPid intValue]));

      break;
    }
  }

  CFRelease(windowList);

  return windowObj;
}

Napi::Boolean isWindowActive(const Napi::CallbackInfo &info) {
  Napi::Env env{info.Env()};

  if (!_checkScreenCaptureAccess()) {
    Napi::Error::New(env, "Screen Capture permission is required").ThrowAsJavaScriptException();
    return Napi::Boolean::New(env, false);
  }

  int windowid = info[0].As<Napi::Number>().Int32Value();

  NSDictionary *window = getWindow(windowid);

  if (!window) {
    return Napi::Boolean::New(env, false);
  }

  NSNumber *appPid = window[(id)kCGWindowOwnerPID];

  NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier: [appPid intValue]];

  return Napi::Boolean::New(env, [app isActive]);
}

Napi::Array getWindows(const Napi::CallbackInfo &info) {
  Napi::Env env{info.Env()};

  if (!_checkScreenCaptureAccess()) {
    Napi::Error::New(env, "Screen Capture permission is required").ThrowAsJavaScriptException();
    return Napi::Array::New(env);
  }

  CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
  CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);

  Napi::Array windows = Napi::Array::New(env);

  for (NSDictionary *window in (NSArray *)windowList) {
    NSNumber *appPid = window[(id)kCGWindowOwnerPID];
    NSNumber *windowID = window[(id)kCGWindowNumber];
    NSString *windowTitle = window[(id)kCGWindowName];

    Napi::Object windowObj = Napi::Object::New(env);

    NSRunningApplication *application = [NSRunningApplication runningApplicationWithProcessIdentifier: [appPid intValue]];
    auto bundlePath = application ? [application.bundleURL.path UTF8String] : NULL;

    if (application && bundlePath != NULL) {
      windowObj.Set("windowID", Napi::Number::New(env, [windowID intValue]));
      windowObj.Set("title", Napi::String::New(env, [windowTitle UTF8String]));
      windowObj.Set("pid", Napi::Number::New(env, [appPid intValue]));

      windows.Set([windowID intValue], windowObj);
    }
  }

  CFRelease(windowList);

  return windows;
}