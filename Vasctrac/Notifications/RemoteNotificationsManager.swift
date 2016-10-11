//
//  RemoteNotificationsManager.swift
//  Vasctrac
//
//  Created by Developer on 4/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Whisper

class RemoteNotificationsManager {
    
    // singleton
    static let sharedInstance = RemoteNotificationsManager()
    
    func didReceiveRemoteNotification(userInfo: [String: AnyObject]) {
        self.manageRemoteNotification(userInfo)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func manageRemoteNotification(notification: [String: AnyObject]) {
        print(notification)
        
        if let aps = notification["aps"] as? [String:AnyObject],
            let alert = aps["alert"] as? [String:AnyObject],
            let messageType = alert["action-loc-key"] as? String {
            
            // post notification to reload messages
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.MessageArrivedNotification,
                                                                      object: nil, userInfo: notification)
            
            switch MessageType(rawValue: messageType)! {
            case .WalkTest:
                let message = alert["body"] != nil ? alert["body"] as! String : "Walking Test Needs to be conducted."

                if let topVC = UIApplication.topViewController() {
                    let announcement = Announcement(title: "Walking Test", subtitle: message, image: UIImage(named: "icon-notification"))
                    Shout(announcement, to: topVC)
                }
                
            case .QuarterlySurvey:
                let message = alert["body"] != nil ? alert["body"] as! String : "Quarterly Survey Needs to be conducted."
                
                if let topVC = UIApplication.topViewController() {
                    let announcement = Announcement(title: "Quarterly Survey", subtitle: message, image: UIImage(named: "icon-notification"))
                    Shout(announcement, to: topVC)
                }
                
            }
        }
    }
    
}
