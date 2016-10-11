//
//  Constants.swift
//  Vasctrac
//
//  Created by Developer on 3/16/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class Constants {
    
    struct UserDefaults {
        static let FirstRun = "edu.stanford.vasctrac.firstRun"
        static let HKDataShare = "edu.stanford.vasctrac.healthKitShare"
        static let LastDateStepsDataSent = "edu.stanford.vasctrac.lastDateStepsDataSent"
        static let DeviceToken = "edu.stanford.vasctrac.deviceToken"
    }
    
    struct Network {
        // MARK: Environments URLs
        static let prductionUrl = "https://vasctracdev.azurewebsites.net"
        static let mockServerUrl = "https://private-anon-3979eb702-vasctrac.apiary-mock.com"
        static let currentServerUrl = prductionUrl
        static let SuccessRange = 200..<300
        static let NotFound = 404
        static let ServerError = 500
    }
    
    struct Keychain {
        static let AppIdentifier = "edu.stanford.vasctrac"
        static let TokenIdentifier = "edu.stanford.vasctrac.token"
    }
    
    struct Notification {
        static let MessageArrivedNotification = "MessageArrivedNotification"
        static let APIUserErrorNotification = "APIUserErrorNotification"
        static let OnboardingCompleteNotification = "OnboardingCompleteNotification"
        static let SessionExpired = "UserSessionExpired"
        static let DidRegisterNotifications = "DidRegisterUserNotificationSettings"
    }

}
