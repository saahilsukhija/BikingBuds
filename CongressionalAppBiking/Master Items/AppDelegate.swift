//
//  AppDelegate.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/8/21.
//

import UIKit
import GoogleSignIn
import Firebase
import CoreLocation
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, CLLocationManagerDelegate {
    
    var lastLocation: CLLocation?
    var locationManager = CLLocationManager()
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if error != nil {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                          accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("oops error")
                print(error.localizedDescription)
            } else {
                Authentication.user = authResult!.user
                print("\(Authentication.user!.email!) just signed in, App Delegate")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .signInGoogleCompleted, object: nil)
                }
                
            }
        }
        
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        print("signed out App Delegate")
        Authentication.user = nil
        do {
            try Auth.auth().signOut()
        } catch {
            print("error signing out App Delegate")
        }
        // ...
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        
        // Check if launched from notification
//        let notificationOption = launchOptions?[.remoteNotification]
//
//        if
//          let notification = notificationOption as? [String: AnyObject],
//          let aps = notification["aps"] as? [String: AnyObject] {
//          // 2
//          //NewsItem.makeNewsItem(aps)
//
//          // 3
//          //(window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//        }
        
        
        let locationOption = launchOptions?[.location]
        
        if locationOption != nil {
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.activityType = .fitness
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        
        return true
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("app did terminate")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("app did enter background")
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0].coordinate.roundTo(places: Preferences.coordinateRoundTo)
        let (latitude, longitude) = (location.latitude, location.longitude)
        
        if lastLocation?.coordinate.latitude != latitude || lastLocation?.coordinate.longitude != longitude {
            uploadUserLocation(location)
        } else {
            //Same Location, not uploading to cloud
        }
        
        lastLocation = locations[0]
    }
    
    func uploadUserLocation(_ location: CLLocationCoordinate2D) {
        print("uploading location APP DELEGATE")
        if Authentication.riderType == .rider, let groupID = UserDefaults.standard.string(forKey: "recent_group") {
            UserLocationsUpload.uploadCurrentLocation(group: groupID, location: location) { completed, message in
                if !completed {
                    print(message!)
                }
            }
        }
    }
    
    func registerForPushNotifications() {
      //1
      UNUserNotificationCenter.current()
        //2
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
          //3
          print("Permission granted: \(granted)")
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Authentication.deviceToken = token
        NotificationCenter.default.post(name: .deviceTokenLoaded, object: nil)
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    // Receive displayed notifications for iOS 10 devices.
//      func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                  willPresent notification: UNNotification,
//                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
//                                  -> Void) {
//        let userInfo = notification.request.content.userInfo
//
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//        // ...
//
//        // Print full message.
//        print(userInfo)
//
//        // Change this to your preferred presentation option
//        completionHandler([[.alert, .sound]])
//      }
//
//      func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                  didReceive response: UNNotificationResponse,
//                                  withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//
//        // ...
//
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//        // Print full message.
//        print(userInfo)
//
//        completionHandler()
//      }
    
}

