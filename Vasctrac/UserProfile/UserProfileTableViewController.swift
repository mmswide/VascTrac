//
//  UserProfileTableViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/11/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class UserProfileTableViewController: UITableViewController {

    let kSections = 4
    let kSettingCell = "settingCell"
    let kUserInfoCell = "userInfoCell"
    let kPickerCellIdentifier = "pickerTableViewCell"
    
    enum ProfileSection : Int {
        case UserInfo = 0
        case Passcode
        case Permissions
        case Privacy
    }
    
    enum UserInfoRow : Int {
        case Birthday = 0
        case Gender
        case Height
        case Weight
        case SleepTime
        case WakeupTime
    }
    
    enum SettingRow {
        case AutoLock
        case ChangePasscode
        case SharingOptions
        case Permissions
        case ReviewConsent
        case PrivacyPolicy
        case LicenseInformation
    }
    
    let settingsRowContent = [
        // User Info
        [
            "Date of Birth",
            "Biological Sex",
            "Height (ft)",
            "Weight (lb)",
            NSLocalizedString("What time do you generally go to sleep?", comment: ""),
            NSLocalizedString("What time do you generally wake up?", comment: "")
        ],
        
        // Passcode
        [   "Auto-Lock",
            "Change Passcode",
            "Sharing Options"
        ],
        
        // Permissions
        [
            "Permissions",
            "Review Consent"
        ],
        
        // Privacy
        [
            "Privacy Policy",
            "License Information"
        ]
    ]
    
    var isEditingMode : Bool = false
    var updatedUserInfo = [String: AnyObject]()
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    lazy var user : User? = {
        return SessionManager.sharedManager.currentUser
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 65.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if let currentUser = self.user {
            self.userNameTextField.text = currentUser.first_name + " " + currentUser.last_name
            self.userEmailLabel.text = currentUser.email
        }
        
        self.setEditableUI()
    }
    
    
    // MARK: - Edit user profile
    
    func setEditableUI() {
        self.userNameTextField.delegate = self
        
        if isEditingMode {
            self.userNameTextField.becomeFirstResponder()
            
            self.userNameTextField.enabled = true
            self.userNameTextField.userInteractionEnabled = true
            
            
        } else {
            self.userNameTextField.enabled = false
            self.userNameTextField.userInteractionEnabled = false
        }
    }

    @IBAction func edit(sender: AnyObject) {
        if !isEditingMode {
            isEditingMode = true
            editButton.title = "Done"
            
        } else { // finished editing
            if pickerShowing {
                hidePicker()
            }
            isEditingMode = false
            editButton.title = "Edit"
            
            updateUserInfo()
        }
        setEditableUI()
    }
    
    func updateUserInfo() {
        if validInput() {
            SessionManager.sharedManager.updateUser(updatedUserInfo, onCompletion: nil)
        }
    }
    
    func validInput() -> Bool {
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch ProfileSection(rawValue: section)! {
        case .UserInfo:
            var rows = 6
            if (self.pickerIndexPath != nil && self.pickerShowing) {
                rows += 1
            }
            return rows
        case .Passcode:
            return 3
        case .Permissions, .Privacy:
            return 2
        }
        
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let section = settingsRowContent[indexPath.section]
        switch ProfileSection(rawValue: indexPath.section)! {
        case .UserInfo:
            
            if self.pickerShowing && self.pickerIndexPath != nil && indexPath == self.pickerIndexPath {
                let cell = tableView.dequeueReusableCellWithIdentifier(kPickerCellIdentifier, forIndexPath: indexPath) as! PickerTableViewCell
                cell.type = self.pickerType
                cell.delegate = self // set as delegate of the picker selections
                return cell
            }
            
            // update the index path if the picker is displayed
            let indexPath = self.isEditingMode && self.pickerShowing ? self.actualSelectedIndexPath(indexPath) : indexPath
            
            let cell = tableView.dequeueReusableCellWithIdentifier(kUserInfoCell, forIndexPath: indexPath) as! UserInfoTableViewCell
            cell.selectionStyle = .None
            
            let key = section[indexPath.row]
            cell.infoLabel?.text = key
            
            if let user = user {
                var detail = ""
                switch UserInfoRow(rawValue: indexPath.row)! {
                case .Birthday:
                    if let date = NSDate.dateFromISOString(user.date_of_birth) {
                        detail = date.toFormattedString()
                    }
                case .Gender:
                    detail = String(user.gender)
                case .Height:
                    detail = user.height.description
                case .Weight:
                    detail = user.weight.description
                    cell.detailTextField.delegate = self
                case .SleepTime:
                    if let date = NSDate.dateFromISOString(user.sleep_time) {
                        detail = date.timeToString()
                    }
                case .WakeupTime:
                    if let date = NSDate.dateFromISOString(user.wakeup_time) {
                        detail = date.timeToString()
                    }
                }
                cell.detailTextField?.text = detail
            }
            return cell
            
        case .Passcode, .Permissions, .Privacy:
            let cell = tableView.dequeueReusableCellWithIdentifier(kSettingCell, forIndexPath: indexPath) as! SettingTableViewCell
            cell.settingLabel.text = section[indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 { // user info section
            if isEditingMode {
                
                if self.pickerShowing && self.pickerIndexPath == indexPath {
                    return
                }
                
                // update the index path if the picker is displayed
                let indexPath = self.pickerShowing ? self.actualSelectedIndexPath(indexPath) : indexPath
                tableView.endEditing(true)

                switch UserInfoRow(rawValue: indexPath.row)! {
                case .Birthday, .Gender:
                    break
                
                case .Height:
                    handlePickerForIndexPath(PickerType.Height, indexPath: indexPath)
                    
                case .Weight:
                    if pickerShowing {
                        hidePicker()
                    }
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserInfoTableViewCell
                    cell.setEnableEditing()
                
                case .SleepTime, .WakeupTime:
                    handlePickerForIndexPath(PickerType.Date, indexPath: indexPath)
                    
                }
            } else {
                return
            }
            
        } else { // settings section
        
            let section = settingsRowContent[indexPath.section]
            let settingRow = getSettingRowType(section[indexPath.row])
            
            switch settingRow {
            case .AutoLock:
                self.changeAutoLock()
            case .ChangePasscode:
                self.editPasscode()
            case .SharingOptions:
                self.sharingOptions()
            case .Permissions:
                self.toPermissions()
            case .ReviewConsent:
                self.reviewConsent()
            case .PrivacyPolicy:
                self.toPrivacyPolicy()
            case .LicenseInformation:
                self.toLicenseInformation()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.pickerShowing && indexPath == self.pickerIndexPath) {
            return 164
        }
        return 65
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { //first section
            return 0
        }
        return 25
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == kSections-1 { //last section
            return 25
        }
        return 0
    }
    
    
    func getSettingRowType(settingName:String) -> SettingRow {
        
        var settingRowType: SettingRow = .AutoLock
        
        if (settingName == settingsRowContent[1][0]) {
            settingRowType = .AutoLock
        }
        else if (settingName == settingsRowContent[1][1]) {
            settingRowType = .ChangePasscode
        }
        else if (settingName == settingsRowContent[1][2]) {
            settingRowType = .SharingOptions
        }
        else if (settingName == settingsRowContent[2][0]) {
            settingRowType = .Permissions
        }
        else if (settingName == settingsRowContent[2][1]) {
            settingRowType = .ReviewConsent
        }
        else if (settingName == settingsRowContent[3][0]) {
            settingRowType = .PrivacyPolicy
        }
        else if (settingName == settingsRowContent[3][1]) {
            settingRowType = .LicenseInformation
        }
        return settingRowType
    }
    
    
    func changeAutoLock() {
        performSegueWithIdentifier("toAutoLock", sender: nil)
    }
    
    func toPrivacyPolicy() {
        performSegueWithIdentifier("toWebView", sender: nil)
    }
    
    func toLicenseInformation() {
        performSegueWithIdentifier("toWebView", sender: nil)
    }
    
    func toPermissions() {
        performSegueWithIdentifier("toPermissions", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPermissions" {
            if let permissionsTVC = segue.destinationViewController as? PermissionsTableViewController {
                permissionsTVC.fromUserProfile = true
            }
        }
    }
    
    @IBAction func toLeaveStudy(sender: AnyObject) {
        self.toWithdrawl()
    }
    
    var pickerIndexPath : NSIndexPath? = nil
    var pickerShowing : Bool = false
    var pickerType : PickerType = .Date
    
    // MARK: Picker handling
    func handlePickerForIndexPath(type: PickerType, indexPath : NSIndexPath) {
        if pickerShowing && (self.pickerIndexPath!.row - 1 == indexPath.row) && (indexPath.section == self.pickerIndexPath!.section) {
            hidePicker()
        } else {
            if pickerShowing {
                hidePicker()
            }
            showPicker(type, indexPath: indexPath)
        }
    }
    
    func showPicker(type: PickerType, indexPath: NSIndexPath) {
        self.pickerShowing = true
        self.pickerIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        self.pickerType = type
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([self.pickerIndexPath!], withRowAnimation: .Fade)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRowAtIndexPath(self.pickerIndexPath!, atScrollPosition: .Bottom, animated: true)
    }
    
    func hidePicker() {
        self.pickerShowing = false
        self.tableView.beginUpdates()
        if self.pickerIndexPath != nil {
            self.tableView.deleteRowsAtIndexPaths([self.pickerIndexPath!], withRowAnimation: .Fade)
            self.pickerIndexPath = nil
        }
        self.tableView.endUpdates()
    }
    
    func actualSelectedIndexPath(selectedIndexPath: NSIndexPath) -> NSIndexPath {
        var newIndexPath = NSIndexPath()
        if self.pickerShowing && (self.pickerIndexPath!.row <= selectedIndexPath.row) && (self.pickerIndexPath!.section == selectedIndexPath.section) {
            newIndexPath = NSIndexPath(forRow: selectedIndexPath.row - 1, inSection: selectedIndexPath.section)
        }
        else {
            newIndexPath = NSIndexPath(forRow: selectedIndexPath.row, inSection: selectedIndexPath.section)
        }
        return newIndexPath
    }
}

extension UserProfileTableViewController : PickerViewDelegate {
    
    func datePickerValueChanged(cell: PickerTableViewCell,  date: NSDate) {
        let indexPath = self.tableView.indexPathForCell(cell)
        if self.pickerShowing && indexPath != nil {
            let actualIndexPath = NSIndexPath(forRow: indexPath!.row - 1, inSection: indexPath!.section)
            let actualCell = self.tableView.cellForRowAtIndexPath(actualIndexPath) as! UserInfoTableViewCell
            actualCell.detailTextField?.text = date.timeToString()
            
            // save to data update dictionary
            switch UserInfoRow(rawValue: actualIndexPath.row)! {
            case .WakeupTime:
                self.updatedUserInfo["wakeupTime"] = date
            case .SleepTime:
                self.updatedUserInfo["sleepTime"] = date
            default:
                break
            }
        }
    }
    
    func pickerViewDidSelectIndices(cell: PickerTableViewCell, selectedValue: String) {
        
        let indexPath = self.tableView.indexPathForCell(cell)
        if self.pickerShowing && indexPath != nil {
            let actualIndexPath = NSIndexPath(forRow: indexPath!.row - 1, inSection: indexPath!.section)
            let actualCell = self.tableView.cellForRowAtIndexPath(actualIndexPath) as! UserInfoTableViewCell
            actualCell.detailTextField?.text = selectedValue
            
            // save to data update dictionary
            switch UserInfoRow(rawValue: actualIndexPath.row)! {
            case .Height:
                self.updatedUserInfo["height"] = selectedValue
            default:
                break
            }
        }
    }
}

extension UserProfileTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let userNameTextField = textField as? UserNameTextField { // username textField
            let fullNameArr = userNameTextField.text!.characters.split{$0 == " "}.map(String.init)
            if fullNameArr.count == 2 { // must provide first and last name
                self.updatedUserInfo["first_name"] = fullNameArr[0]
                self.updatedUserInfo["last_name"] = fullNameArr[1]
            }
        } else { // weight textField
            self.updatedUserInfo["weight"] = textField.text
        }
    }
}

extension UserProfileTableViewController : ORKPasscodeDelegate {
   
    func editPasscode() {
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewControllerWithText("", delegate: self, passcodeType:.Type4Digit) as! ORKPasscodeViewController
            presentViewController(editPasscodeViewController, animated: true, completion: nil)
        }
    }
    
    func passcodeViewControllerDidFinishWithSuccess(viewController: UIViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func passcodeViewControllerDidFailAuthentication(viewController: UIViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        
        let alert = UIAlertController(title: "Wrong Passcode Entered", message:"", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Okay",
            style: UIAlertActionStyle.Default,
            handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension UserProfileTableViewController : ORKTaskViewControllerDelegate {
    
    func reviewConsent() {
        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentReviewStep", document: consentDocument)
        presentTaskViewController("ConsentReview", steps: [consentStep])
    }
    
    func sharingOptions() {
        let shareStep = JoinViewController.shareStep
        presentTaskViewController("ShareReview", steps: [shareStep])
    }
    
    func toWithdrawl() {
        let alert = UIAlertController(title: "Are you sure you want to withdraw?", message:"Withdrawing from the study will reset the app to the state it was in prior to you originally joining the study.", preferredStyle: .Alert)

        let withdraw = UIAlertAction(title: "Yes", style: .Default) { [unowned self] alertAction in
            SessionManager.sharedManager.removeUser()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(withdraw)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func presentTaskViewController(identifier: String, steps: [ORKStep]?) {
        let consentTask = ORKOrderedTask(identifier: identifier, steps: steps)
        let taskViewController = ORKTaskViewController(task: consentTask, taskRunUUID: nil)
        taskViewController.delegate = self
        
        presentViewController(taskViewController, animated: true, completion: nil)
    }
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
