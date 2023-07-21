import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        readDataFromFirebase { apiKey in
            GMSServices.provideAPIKey(apiKey)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func readDataFromFirebase(callback: @escaping (String) -> Void) -> Void {
        let ref = Database.database().reference()  // Root reference to your Firebase Database

        // Assuming your API key is stored under "api_key" node
        ref.child("api_key").observeSingleEvent(of: .value) { snapshot in
            if let apiKey = snapshot.value as? String {
                callback(apiKey)
            } else {
                callback("")
            }
        }
    }
}
