//
//  ActivitiesTableViewController.swift
//  Vasctrac
//
//  Created by Developer on 2/29/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class ActivitiesTableViewController: LoadingTableViewController {
    
    let toQuarterlySurveySegueId = "toQuarterlySurvey"
    let headerViewIdentifier  = "ActivitiesSectionHeaderView"
    let activitiesCellIdentifier = "ActivitiesCellIdentifier"
    let recentWalkTestCellIdentifier = "RecentWalkTestCellIdentifier"
    
    var messages = [Message]()
    lazy var quarterlySurveys =  ActivitiesListRow.quarterlySurveys
    
    var recentWalkTestResult : WalkTestResult? = nil
    
    enum SectionType : Int {
        case Activities = 0
        case Results
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Observers
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(userMessages),
                                                         name: Constants.Notification.MessageArrivedNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(userMessages),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.Notification.MessageArrivedNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Activities", comment:"")
        
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: headerViewIdentifier, bundle: bundle)
        self.tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: headerViewIdentifier)
        
        // do not show empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // request user messages
        self.userMessages()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if recentWalkTestResult == nil {
            SessionManager.sharedManager.userLastWalkTestResult { lastWalkTestResult in
                if lastWalkTestResult != nil {
                    self.recentWalkTestResult = lastWalkTestResult
                    self.reloadData()
                }
            }
        }
        
        if self.messages.count > 0 || self.recentWalkTestResult != nil {
            self.stopLoading()
        }
    }
    
    func userMessages() {
        SessionManager.sharedManager.userMessages() { messages, error in
            if let messages = messages {
                self.messages = messages
                self.reloadData()
            }
        }
    }
    
    func setMessageAsRead(messageId: Int) {
        SessionManager.sharedManager.didReadMessage(withId: String(messageId)) { success in
            
            // reload the messages
            self.userMessages()
        }
    }
    
}

// MARK: - Table view data source and delegate
extension ActivitiesTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SectionType(rawValue: section)! {
        case .Activities:
            return self.messages.count
        case .Results:
            return self.recentWalkTestResult != nil ? 1 : 0
        }
        
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch SectionType(rawValue: indexPath.section)! {
        case .Activities:
            let activitiesCell = tableView.dequeueReusableCellWithIdentifier(activitiesCellIdentifier,
                                                                             forIndexPath: indexPath) as! ActivitiesTableViewCell
            
            let message = messages[indexPath.row]
            activitiesCell.titleLabel.text = message.title
            return activitiesCell
        
        case .Results:
            let walkTestResultCell = tableView.dequeueReusableCellWithIdentifier(recentWalkTestCellIdentifier,
                                                                                 forIndexPath: indexPath) as! RecentWalkTestResultCell
            walkTestResultCell.selectionStyle = .None
            if let recentWalkTestResult = recentWalkTestResult {
                walkTestResultCell.distanceWalked(recentWalkTestResult.distance.metersToFeetString())
                walkTestResultCell.steps(String(recentWalkTestResult.steps_without_stopping))
                walkTestResultCell.takenOn(String(recentWalkTestResult.date))
            }
            return walkTestResultCell
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch SectionType(rawValue: section)! {
        case .Activities:
            return 90
        case .Results:
            return 20
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch SectionType(rawValue: indexPath.section)! {
        case .Activities:
            return 65
        case .Results:
            return 300
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch SectionType(rawValue: section)! {
        case .Activities:
            let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerViewIdentifier) as! ActivitiesSectionHeaderView
            headerView.titleLabel.text = NSDate().fullFormattedString()
            return headerView
        default :
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == SectionType.Activities.rawValue {
            
            let message = self.messages[indexPath.row]
            switch message.type {
            case .WalkTest:
                toWalkTest()
            case .QuarterlySurvey:
                toQuarterlySurvey()
            }
        }
    }
}


// MARK: - Navigation
extension ActivitiesTableViewController {
    
    func toWalkTest() {
        UIApplication.sharedApplication().idleTimerDisabled = true
        let taskViewController = ORKTaskViewController(task: ActivitiesListRow.WalkTest.representedTask, taskRunUUID: nil)
        taskViewController.delegate = self
        taskViewController.outputDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        self.presentViewController(taskViewController, animated: true, completion: nil)
    }
    
    func toQuarterlySurvey() {
        self.performSegueWithIdentifier(toQuarterlySurveySegueId, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == toQuarterlySurveySegueId {
            if let surveysVC = segue.destinationViewController as? SurveysViewController {
                surveysVC.surveysType = .Quarterly
                surveysVC.onCompletion = { reason in
                    
                    self.navigationController?.popToViewController(self, animated: true)
                    
//                    self.activities[ActivityType.QuarterlySurvey.rawValue].complete = true // finished completing both surveys
                    
                    // remove the activity if it was completed
                    if reason == .Completed {
                        if let index = self.messages.indexOf({$0.type == MessageType.QuarterlySurvey}) {
                            let message = self.messages[index]
                            self.messages.removeAtIndex(index)
                            self.setMessageAsRead(message.id)
                        }
                    }
                    
                    self.reloadData()
                }
            }
        }
    }
}

extension ActivitiesTableViewController : ORKTaskViewControllerDelegate {
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        if reason == .Completed {
            switch ActivitiesListRow.identifier(rawValue: taskViewController.task!.identifier)! {
            case ActivitiesListRow.identifier.WalkTest:
                
                // remove the activity
                if let index = self.messages.indexOf({$0.type == MessageType.WalkTest}) {
                    let message = self.messages[index]
                    self.messages.removeAtIndex(index)
                    self.setMessageAsRead(message.id)
                }
            
                handleWalkTestCompletion(taskViewController.result)
            
            default: break
            }
        }
        
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
        
        self.reloadData()
    }
    
    func handleWalkTestCompletion(taskResult: ORKTaskResult) {
        UIApplication.sharedApplication().idleTimerDisabled = true
        let walkData = DataCollector.walkTestCollectorHandler(taskResult)
        if let walkData = walkData {
            SessionManager.sharedManager.sendWalkTestResult(walkData) { testResult in
                
                if let testResult = testResult {
                    // update daily steps data in server
                    DailyHealthManager.sharedManager.sendDailyDataSinceLastDate()
                    
                    self.recentWalkTestResult = testResult
                    
                    self.reloadData()
                }
            }
        }
    }
    
    func taskViewController(taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        if stepViewController.step?.identifier == ActivitiesListRow.WalkTestIdentifier.GetReady.rawValue {
            AudioManager.sharedManager.playSound(withName: "get_ready", withExtension: "m4a")
        }
        
        if stepViewController.step?.identifier == ActivitiesListRow.WalkTestIdentifier.WalkActiveStep.rawValue {
            AudioManager.sharedManager.playSound(withName: "go", withExtension: "m4a")
        }
    }

}
