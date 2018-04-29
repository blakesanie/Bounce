import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pause"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if !gameStarted {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resume"), object: nil)
        }
    }
    
}

