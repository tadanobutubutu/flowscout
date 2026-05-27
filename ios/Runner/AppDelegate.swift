import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let nativeChannel = FlutterMethodChannel(name: "com.example.flowscout/native",
                                              binaryMessenger: controller.binaryMessenger)
    
    nativeChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "getNativeDeviceInfo":
        let deviceName = UIDevice.current.name
        let osVersion = UIDevice.current.systemVersion
        result(["deviceName": deviceName, "osVersion": osVersion])
        
      case "performHeavyNativeTask":
        // iOS依存のセキュア処理や重い最適化ロジックなどをここに記述
        let args = call.arguments as? [String: Any]
        let data = args?["data"] as? String
        let processed = self.performHeavyNativeJob(data: data)
        result(processed)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func performHeavyNativeJob(data: String?) -> String {
    // iOS特有の重い処理やSwift固有の最適化ロジックプレースホルダー
    return "Processed iOS native Swift data: \(String(data?.reversed() ?? ""))"
  }
}
