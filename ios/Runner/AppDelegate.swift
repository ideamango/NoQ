import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    FirebaseApp.configure()

    // FirebaseApp.app()?.delete({ (success) in

    // })

    // let filePath = Bundle.main.path(forResource: "GoogleService-Info-Test", ofType: "plist")
    // guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
    //   else { assert(false, "Couldn't load config file") }
    // FirebaseApp.configure(name: "SecondaryFirebaseApp", options: fileopts)
    // // [END default_configure_file   
  

    // guard let defapp = FirebaseApp.app(name: "SecondaryFirebaseApp")
    //   else { assert(false, "Could not retrieve default app") }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self 
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){
      guard let url = dynamicLink.url else{
          print("Thats wierd!!")
          return
      }
      print("Your url param is \(url.absoluteString)")
  }
    
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    if let incomingURL = userActivity.webpageURL{
        print("Incoming URL is \(incomingURL)")
        let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL ) {(dynamicLink, error) in guard error == nil else {
            print("Found an error ! \(error!.localizedDescription)")
            return
            }
            if let dynamicLink = dynamicLink{
                self.handleIncomingDynamicLink(dynamicLink)
            }
                        }
        if linkHandled {
            return true
        }
        else{
            return false
        }
    }
    return false
  } 

  // override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  //   let firebaseAuth = Auth.auth()
  //   if (firebaseAuth.canHandleNotification(userInfo)){
  //       print(userInfo)
  //       return
  //   }
  // }

}
