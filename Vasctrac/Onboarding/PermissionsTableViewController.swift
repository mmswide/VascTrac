//
//  PermissionsTableViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/11/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreLocation

class PermissionsManager {
    static let sharedManager = PermissionsManager()
    
    func allowNotifications() {
        if UIApplication.sharedApplication().currentUserNotificationSettings()!.types == .None {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
    }
}

class PermissionsTableViewController: UITableViewController {
    
    enum permissionType : String {
        case Location = "Location"
        case Notification = "Notification"
    }
    
    let toRegisterSegueId = "toRegister"
    
    var fromUserProfile = false
    
    var doneButton : UIBarButtonItem!
    
    let kPersmissionCellIdentifier = "PermissionsCell"
    var permissions = [
        [
            "name" : NSLocalizedString("Location Services", comment: ""),
            "type" : "location",
            "detials" : NSLocalizedString("Enabling GPS enables the app to accurately determine distances while you walk. Your actual location will never be shared.", comment: ""),
        ],
        [
            "name" : NSLocalizedString("Notifications", comment: ""),
            "type" : "notification",
            "detials" : NSLocalizedString("Allowing notifications enables us to remind you about your walk tests and surveys.", comment: ""),
        ]
    ]

    let locationManager = CLLocationManager()
    
    lazy var permissionDeniedHandler: (type: permissionType) -> Void = {
        [unowned self] (type: permissionType) -> Void in
        
        let alertController = UIAlertController(title: "Permission Denied",
            message: type.rawValue + " permission was not authorized. Please enable it in Settings to continue.",
            preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (alertAction) in
            
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(appSettings)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PermissionsTableViewController.didRegisterUserNotificationSettings(_:)),
                                                         name: Constants.Notification.DidRegisterNotifications,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PermissionsTableViewController.appDidBecomeActive),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:Constants.Notification.DidRegisterNotifications,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name:UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        
        doneButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PermissionsTableViewController.done(_:)))
        if fromUserProfile {
            navigationItem.rightBarButtonItems = []
        } else {
            navigationItem.rightBarButtonItems = [doneButton]
            self.navigationItem.setHidesBackButton(true, animated:true)
        }
    }

    func appDidBecomeActive() {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.permissions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kPersmissionCellIdentifier, forIndexPath: indexPath) as! PermissionsTableViewCell
        cell.selectionStyle = .None
        
        let permission = self.permissions[indexPath.row]
        cell.titleLabel.text = permission["name"]
        cell.detailsLabel.text = permission["detials"]

        let type = toPremissionType(permission["type"])
        switch type {
        case .Location:
            if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
                cell.disableAllowButton()
            }
            cell.allowButton.addTarget(self, action: #selector(allowLocationServices(_:)), forControlEvents: .TouchUpInside)
        case .Notification:
            if (UIApplication.sharedApplication().currentUserNotificationSettings()!.types != .None) {
                cell.disableAllowButton()
            }
            cell.allowButton.addTarget(self, action: #selector(allowNotifications(_:)), forControlEvents: .TouchUpInside)
        }
        
        return cell
    }
    
    func allowLocationServices(sender: UIButton) {
       if CLLocationManager.authorizationStatus() == .NotDetermined {
            if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") != nil) {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    func allowNotifications(sender: AnyObject) {
        PermissionsManager.sharedManager.allowNotifications()
    }
    
    func didRegisterUserNotificationSettings(notification: NSNotification) {
        let settings = notification.object as! UIUserNotificationSettings
        if (settings.types == .None) {
            permissionDeniedHandler(type: .Notification)
        } else {
            // granted
            self.tableView.reloadData()
        }
    }
    
    func toPremissionType(typeName: String?) -> permissionType {
        var type: permissionType = .Location
        
        if (typeName == String(permissionType.Location).lowercaseString) {
            type = .Location
        }
        else if (typeName == String(permissionType.Notification).lowercaseString) {
            type = .Notification
        }
        return type
    }
    
    func done(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(toRegisterSegueId, sender: nil)
    }
    
}

extension PermissionsTableViewController : CLLocationManagerDelegate {
    
    //location authorization status changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            self.locationManager.startUpdatingLocation()
        case .Denied:
            permissionDeniedHandler(type: .Location)
        default:
            break
        }
    }
}
