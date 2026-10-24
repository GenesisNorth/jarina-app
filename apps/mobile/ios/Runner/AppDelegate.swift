import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "JarinaDevice") {
      DeviceIntegrity.register(with: registrar)
    }
  }
}

/// Best-effort jailbreak check over `jarina/device`. The server treats it as a
/// risk signal, not proof.
final class DeviceIntegrity: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "jarina/device", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(DeviceIntegrity(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isCompromised": result(Self.isJailbroken())
    default: result(FlutterMethodNotImplemented)
    }
  }

  private static func isJailbroken() -> Bool {
    #if targetEnvironment(simulator)
      return false
    #else
      let paths = [
        "/Applications/Cydia.app", "/Applications/Sileo.app", "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/bin/bash", "/usr/sbin/sshd", "/etc/apt", "/private/var/lib/apt/", "/var/jb",
      ]
      if paths.contains(where: { FileManager.default.fileExists(atPath: $0) }) { return true }
      // A sandboxed app can't write outside its container.
      let probe = "/private/jarina-jb-check.txt"
      do {
        try "x".write(toFile: probe, atomically: true, encoding: .utf8)
        try? FileManager.default.removeItem(atPath: probe)
        return true
      } catch {
        return false
      }
    #endif
  }
}
