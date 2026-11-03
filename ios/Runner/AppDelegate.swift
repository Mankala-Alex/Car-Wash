import Flutter
import UIKit
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // The Google Maps SDK for iOS aborts the process (GMSServices
    // checkServicePreconditions -> NSException -> SIGABRT) if no API key has been
    // provided before the first map view is created. Android gets its key from
    // AndroidManifest, iOS has to supply it here.
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    } else {
      NSLog("⚠️ GMSApiKey missing from Info.plist – Google Maps will abort on first use.")
    }

    // Required by flutter_local_notifications: FlutterAppDelegate forwards the
    // UNUserNotificationCenterDelegate callbacks to the registered plugins,
    // which is what makes a notification visible (and tappable) while the app
    // is in the foreground — the same behaviour Android has by default.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
