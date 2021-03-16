import UIKit
import Flutter
import OneSignal
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    //Remove this method to stop OneSignal Debugging
    OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

    //START OneSignal initialization code
    let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: false]

    // Replace 'YOUR_ONESIGNAL_APP_ID' with your OneSignal App ID.
    OneSignal.initWithLaunchOptions(launchOptions,
      appId: "b17d34fb-2e52-4e4c-994b-4897421a590d",
      handleNotificationAction: nil,
      settings: onesignalInitSettings)

    OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;

    // promptForPushNotifications will show the native iOS notification permission prompt.
    // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
    OneSignal.promptForPushNotifications(userResponse: { accepted in
      print("User accepted notifications: \(accepted)")
    })
    //END OneSignal initializataion code

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
