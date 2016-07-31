//
//  AppDelegate.swift
//  ApplicationExtensionsPractice
//
//  Created by zhangke on 16/7/19.
//
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.registerNotifications(application)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [String : AnyObject] = [:]) -> Bool {
        print(url)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
    
        //corespotlight
        if userActivity.activityType == "com.apple.corespotlightitem" {
            let dic: NSDictionary = userActivity.userInfo!
            let indentifier: String = dic.object(forKey: "kCSSearchableItemActivityIdentifier") as! String
          
            //取到跳转类型和id，跳转动作
            print("com.apple.corespotlightitem",indentifier)
        }
        return true
    }
    
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("device token = " + deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: ""))
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        print("If want test remote push, please use device");
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    }
    
    func registerNotifications(_ application: UIApplication) -> Void {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.sound, UNAuthorizationOptions.badge]) { (done, error) in
            if done == true {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    //  Notification will present call back
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    //  Notification interaction response call back
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: () -> Void) {
        
        let responseNotificationRequestIdentifier = response.notification.request.identifier
        
        if responseNotificationRequestIdentifier == String.UNNotificationRequest.LocalPushNormal.rawValue ||
            responseNotificationRequestIdentifier == String.UNNotificationRequest.LocalPushWithImage.rawValue ||
            responseNotificationRequestIdentifier == String.UNNotificationRequest.LocalPushWithGif.rawValue ||
            responseNotificationRequestIdentifier == String.UNNotificationRequest.LocalPushWithTrigger.rawValue {
            
            let actionIdentifier = response.actionIdentifier
            switch actionIdentifier {
            case String.UNNotificationAction.Accept.rawValue:
                
                break
            case String.UNNotificationAction.Reject.rawValue:
                
                break
            case String.UNNotificationAction.Input.rawValue:
                
                break
            case UNNotificationDismissActionIdentifier:
                
                break
            case UNNotificationDefaultActionIdentifier:
                
                break
            default:
                break
            }
        }
        completionHandler();
    }

}

