import UIKit
import Flutter
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private let universalLinkChannelName = "com.bunyamin.kasa/universal_link"
  private var initialUrl: String? // Initial URL'i saklamak için

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    UNUserNotificationCenter.current().delegate = self

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // EventChannel (mevcut kodun)
    let eventChannel = FlutterEventChannel(name: universalLinkChannelName, binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(self)
    
    // MethodChannel - Deep link için
    let deepLinkChannel = FlutterMethodChannel(name: "com.bunyamin.kasa/deep_link", binaryMessenger: controller.binaryMessenger)
    deepLinkChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getInitialLink" {
        print("🔹 iOS: getInitialLink çağrıldı - returning: \(String(describing: self?.initialUrl))")
        result(self?.initialUrl)
      }
    })
    
    // iOS UserActivity channel
    let activityChannel = FlutterMethodChannel(name: "com.bunyamin.kasa/ios_activity", binaryMessenger: controller.binaryMessenger)
    activityChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getUserActivityUrl" {
        print("🔹 iOS: getUserActivityUrl çağrıldı - returning: \(String(describing: self?.initialUrl))")
        result(self?.initialUrl)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Bildirim geldiğinde uygulama ön plandaysa gösterimi ayarla
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  // Universal Link geldiğinde çağrılır
  override func application(_ application: UIApplication,
                          continue userActivity: NSUserActivity,
                          restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let incomingURL = userActivity.webpageURL {
      
      let urlString = incomingURL.absoluteString
      print("🔹 iOS: Universal Link geldi: \(urlString)")
      
      // Initial URL'i sakla
      initialUrl = urlString
      
      // EventChannel'e gönder (runtime links için)
      eventSink?(urlString)
      
      return true
    }
    return false
  }

  // FlutterStreamHandler protokolü için
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    print("🔹 iOS: EventChannel listener başlatıldı")
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    print("🔹 iOS: EventChannel listener durduruldu")
    return nil
  }
}