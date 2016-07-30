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
class AppDelegate: UIResponder, UIApplicationDelegate {

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
        
        if userActivity.activityType == "com.apple.corespotlightitem" {
            let dic: NSDictionary = userActivity.userInfo!
            let indentifier: String = dic.object(forKey: "kCSSearchableItemActivityIdentifier") as! String
          
            //取到跳转类型和id，跳转动作
            print("com.apple.corespotlightitem",indentifier)
        }
        return true
    }
    
    func registerNotifications(_ application: UIApplication) -> Void {
        let center = UNUserNotificationCenter.current()
//        center.delegate = self
        
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.sound, UNAuthorizationOptions.badge]) { (done, error) in
            if done == true {
                application.registerForRemoteNotifications()
            }
        }
    }
    

}

