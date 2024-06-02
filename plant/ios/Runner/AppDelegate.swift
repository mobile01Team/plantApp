import UIKit
import Flutter
import GoogleMaps  // Add this import

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    GMSServices.provideAPIKey("AIzaSyBqkIZjpT3NMzdDLmsDkqLZW8SMFh_UUKM")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
