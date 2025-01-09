//import UIKit
//import Flutter
//import GoogleMaps
//import Firebase
//
//@UIApplicationMain
//@objc class AppDelegate: FlutterAppDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//
//
//     GMSServices.provideAPIKey("AIzaSyCGkz3XsDJbMPCL7T-I8WM6QVEn_Gij8yc")
//    GeneratedPluginRegistrant.register(with: self)
//      if FirebaseApp.app() == nil {
//        FirebaseApp.configure()
//      }
//      if #available(iOS 10.0, *) {
//        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//      }
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//}
import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCGkz3XsDJbMPCL7T-I8WM6QVEn_Gij8yc")
      GeneratedPluginRegistrant.register(with: self)
//      UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    UIApplication.shared.beginReceivingRemoteControlEvents()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
}
