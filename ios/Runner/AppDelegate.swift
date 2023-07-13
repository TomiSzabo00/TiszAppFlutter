import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let notificationChannel = FlutterMethodChannel(name: "flutter/notifications",
                                                       binaryMessenger: controller.binaryMessenger)
        notificationChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // This method is invoked on the UI thread.
            guard call.method == "sendNotification" else {
                result(FlutterMethodNotImplemented)
                return
            }

            self?.receiveBatteryLevel(arguments: call.arguments, result: result)
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func receiveBatteryLevel(arguments: Any?, result: @escaping FlutterResult) {
        guard let arguments = arguments as? [String: Any]
        else {
            result(FlutterError(code: "arguments-error",
                                message: "Argumets are not correctly formatted.",
                                details: nil))
            return
        }
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        else {
            result(FlutterError(code: "url-error",
                                message: "Firebase URL error.",
                                details: nil))
            return
        }
        guard let serverKey = arguments["serverKey"] as? String
        else {
            result(FlutterError(code: "server-key-error",
                                message: "Notifications server key is incorrect or missing.",
                                details: nil))
            return
        }
        guard let list = arguments["to"] as? [String]
        else {
            result(FlutterError(code: "tokens-error",
                                message: "Destination tokens missing.",
                                details: nil))
            return
        }
        guard let title = arguments["title"] as? String
        else {
            result(FlutterError(code: "title-error",
                                message: "Notification title not found.",
                                details: nil))
            return
        }
        guard let body = arguments["body"] as? String
        else {
            result(FlutterError(code: "body-error",
                                message: "Notification body not found.",
                                details: nil))
            return
        }

        if list.count > 0 {
            for i in 0...list.count-1 {
                let json: [String: Any] = [
                    "to": list[i],
                    "notification": [
                        "title": title,
                        "body": body
                    ]
                ]

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])

                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")

                let session = URLSession(configuration: .default)

                session.dataTask(with: request, completionHandler: { _, _, err in
                    if let err = err {
                        result(FlutterError(code: "sending-error",
                                            message: err.localizedDescription,
                                            details: nil))
                        return
                    }

                    // sent all notifications
                    result(true)
                })
                .resume()
            }
        } else {
            result(false)
        }
    }
}
