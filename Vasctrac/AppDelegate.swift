//
//  AppDelegate.swift
//  Vasctrac
//
//  Created by Developer on 2/29/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import RealmSwift
import ResearchKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // MARK: Error reporting
        Fabric.with([Crashlytics.self])
        
        //  MARK : - Realm Schema Migration
        let config = Realm.Configuration(
            schemaVersion: 35,
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        do {
            let _ = try Realm()
        } catch {
            ErrorManager.sharedManager.addFatalError("There is an issue with the app db, a migration might be needed, please contact the developers team")
            
            // don't make any other load
            return true
        }
        
        // MARK: Reinstallation/Unistallation
        SessionManager.sharedManager.checkFirstRun()
        
        // Start listening for errors
        ErrorManager.sharedManager
        
        // Start sending health data
        DailyHealthManager.sharedManager
        
        //  MARK : - Apparence
        UIView.appearanceWhenContainedInInstancesOfClasses([ORKTaskViewController.self]).tintColor = UIColor.vasctracTintColor()
        UINavigationBar.appearance().tintColor = UIColor.vasctracTintColor()
        UITabBar.appearance().tintColor = UIColor.vasctracTintColor()
        UIView.appearanceWhenContainedInInstancesOfClasses([UIAlertController.self]).tintColor = UIColor.vasctracTintColor()
        
        
        // MARK: - Remote Notifications
        // Check if launched from notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
            RemoteNotificationsManager.sharedInstance.manageRemoteNotification(notification)
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication,
                     didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.DidRegisterNotifications, object: notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("DEVICE TOKEN = \(tokenString)")
        
        SessionManager.sharedManager.deviceToken = tokenString
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let userInfo = userInfo as? [String: AnyObject] {
            RemoteNotificationsManager.sharedInstance.didReceiveRemoteNotification(userInfo)
        }
    }
}

