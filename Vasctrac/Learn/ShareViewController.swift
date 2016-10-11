//
//  ShareViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Social
import MessageUI

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let kShareCellIdentifier = "ShareTableViewCellIdentifier"
    @IBOutlet weak var tableView: UITableView!
    
    let shareMessage = NSLocalizedString("Check out VascTrac, an Apple ResearchKit study focused on Peripheral Arterial Disease (PAD). Download it for iPhone at http://itunes.apple.com/app/id1121791155", comment: "")
    
    enum ShareTypes : Int {
        case Twitter = 0
        case Facebook
        case Email
        case Sms
    }

    var shareContent = [
        [
            "name" : "Twitter",
            "on" : "Share on Twitter",
            "image": "twitter_icon"
        ],
        [
            "name" : "Facebook",
            "on" : "Share on Facebook",
            "image": "facebook_icon"
        ],
        [
            "name" : "Email",
            "on" : "Share via Email",
            "image": "email_icon"
        ],
        [
            "name" : "SMS",
            "on" : "Share via SMS",
            "image": "sms_icon"
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareContent.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(kShareCellIdentifier, forIndexPath: indexPath) as! ShareTableViewCell
        
        let content = shareContent[indexPath.row]
        cell.shareImageView.image = UIImage(named:content["image"]!)
        cell.shareLabel.text = content["on"]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let content = shareContent[indexPath.row]
        switch ShareTypes(rawValue: indexPath.row)! {
        case .Twitter:
            self.shareOn(SLServiceTypeTwitter, serviceName: content["name"]!)
        case .Facebook:
            self.shareOn(SLServiceTypeFacebook, serviceName: content["name"]!)
        case .Email:
            self.sendEmail()
        case .Sms:
            self.sendSms()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func shareOn(serviceType: String, serviceName: String) {
        if SLComposeViewController.isAvailableForServiceType(serviceType) {
            let composeViewController : SLComposeViewController = SLComposeViewController(forServiceType: serviceType)
            composeViewController.setInitialText(shareMessage)
            self.presentViewController(composeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a \(serviceName) account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension ShareViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.mailComposeDelegate = nil
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendEmail() {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setMessageBody(shareMessage, isHTML: false)

        if MFMailComposeViewController.canSendMail() {
            presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Could Not Send Email", message: "Looks like you don't have Mail app setup. Please configure to share via email.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension ShareViewController : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.messageComposeDelegate = nil
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendSms() {
        if MFMessageComposeViewController.canSendText() {
            let messageComposerViewController = MFMessageComposeViewController()
            messageComposerViewController.body = shareMessage
            messageComposerViewController.messageComposeDelegate = self
            self.presentViewController(messageComposerViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Could Not Send SMS", message: "Looks like you don't have Messages app setup. Please configure to share via SMS.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
    }
}
