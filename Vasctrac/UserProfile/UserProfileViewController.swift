//
//  UserProfileViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/11/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class UserProfileViewController: UserViewController {

    let kSettingCell = "settingCell"
    let kUserInfoCell = "userInfoCell"
    let kPickerCellIdentifier = "pickerTableViewCell"
    
    enum ProfileSection : Int {
        case UserInfo = 0
        case Passcode
        case Permissions
        
        static let all = [UserInfo, Passcode, Permissions]
    }
    
    enum UserInfoRow : Int {
        case Birthday = 0
        case Gender
        case Height
        case Weight
        
        static let allValues = [Birthday, Gender, Height, Weight]
    }
    
    enum SettingRow {
        case AutoLock
        case ChangePasscode
        case SharingOptions
        case Permissions
        case ReviewConsent
    }
    
    let settingsRowContent = [
        // User Info
        [
            "Date of Birth",
            "Gender",
            "Height (ft)",
            "Weight (lb)"
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
        ]
        
    ]
    
    var isEditingMode : Bool = false
    var updatedUserInfo = [String: AnyObject]()
    var nameCorrect : Bool = true
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
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
        self.view.endEditing(true)
        
        if verifyData() {
            SessionManager.sharedManager.updateUser(updatedUserInfo, onCompletion: nil)
        }
    }
    
    func verifyData() -> Bool {
        guard nameCorrect else {
            let alertController = UIAlertController(title: "", message: "You must include first and last name", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        return true
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
        return settingRowType
    }
    
    
    func changeAutoLock() {
        performSegueWithIdentifier("toAutoLock", sender: nil)
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
        
        if segue.identifier == "toWebView",
            let alert = sender as? UIAlertAction {
            if alert.title == "View PDF" {
                let detailWVC = segue.destinationViewController as! DetailWebViewController
                detailWVC.content = "vasctrac_consent"
                detailWVC.contentExtension = "pdf"
                detailWVC.contentTitle = "Consent"
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

extension UserProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ProfileSection.all.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch ProfileSection(rawValue: section)! {
        case .UserInfo:
            var rows = UserInfoRow.allValues.count
            if (self.pickerIndexPath != nil && self.pickerShowing) {
                rows += 1
            }
            return rows
        case .Passcode:
            return 3
        case .Permissions:
            return 2
        }
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
                        detail = date.longFormattedString()
                    }
                case .Gender:
                    detail = String(user.stringGender())
                case .Height:
                    detail = user.heightInFeets()
                case .Weight:
                    detail = user.weight.description
                    cell.detailTextField.delegate = self
                }
                cell.detailTextField?.text = detail
            }
            return cell
            
        case .Passcode, .Permissions:
            let cell = tableView.dequeueReusableCellWithIdentifier(kSettingCell, forIndexPath: indexPath) as! SettingTableViewCell
            cell.settingLabel.text = section[indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
                    handlePickerForIndexPath(PickerType.Custom, indexPath: indexPath)
                    
                case .Weight:
                    if pickerShowing {
                        hidePicker()
                    }
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserInfoTableViewCell
                    cell.setEnableEditing()
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
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.pickerShowing && indexPath == self.pickerIndexPath) {
            return 164
        }
        return 65
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { //first section
            return 0
        }
        return 25
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == ProfileSection.all.count-1 { //last section
            return 25
        }
        return 0
    }

}

extension UserProfileViewController : PickerViewDelegate {
    
    func pickerViewDidSelectIndices(cell: PickerTableViewCell, heightStringValue: String, heightInInches: Double) {
        
        let indexPath = self.tableView.indexPathForCell(cell)
        if self.pickerShowing && indexPath != nil {
            let actualIndexPath = NSIndexPath(forRow: indexPath!.row - 1, inSection: indexPath!.section)
            let actualCell = self.tableView.cellForRowAtIndexPath(actualIndexPath) as! UserInfoTableViewCell
            actualCell.detailTextField?.text = heightStringValue
            
            // save to data update dictionary
            switch UserInfoRow(rawValue: actualIndexPath.row)! {
            case .Height:
                self.updatedUserInfo["height"] = heightInInches
            default:
                break
            }
        }
    }
}

extension UserProfileViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let textField = textField as? UserNameTextField { // username textField
            let validNameRegex = "^\\W*(\\w+\\b\\W*){2,}$" // more than two words
            if textField.text!.isNotEmpty && textField.text!.rangeOfString(validNameRegex, options: .RegularExpressionSearch) != nil {
                nameCorrect = true
                let fullNameComponents = textField.text?.componentsSeparatedByString(" ") ?? []
                self.updatedUserInfo["first_name"] = fullNameComponents[0]
                self.updatedUserInfo["last_name"] = fullNameComponents[1]
            } else {
                nameCorrect = false
            }
        } else { // weight textField
            self.updatedUserInfo["weight"] = textField.text
        }
    }
}

extension UserProfileViewController : ORKPasscodeDelegate {
   
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

extension UserProfileViewController : ORKTaskViewControllerDelegate {
    
    func reviewConsent() {
        
        let alert = UIAlertController(title: "Review Consent", message:"", preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "View PDF", style: .Default, handler: { alert in
            self.performSegueWithIdentifier("toWebView", sender: alert)
        }))
        
        alert.addAction(UIAlertAction(title: "View Slides", style: .Default, handler: { alert in
            let consentDocument = ConsentDocument()
            let consentStep = ORKVisualConsentStep(identifier: "VisualConsentReviewStep", document: consentDocument)
            self.presentTaskViewController("ConsentReview", steps: [consentStep])
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func sharingOptions() {
        let shareStep = JoinViewController.shareStep
        presentTaskViewController("ShareReview", steps: [shareStep])
    }
    
    func toWithdrawl() {
        let alert = UIAlertController(title: "Are you sure you want to withdraw?", message:"Withdrawing from the study will reset the app to the state it was in prior to you originally joining the study.", preferredStyle: .Alert)

        let withdraw = UIAlertAction(title: "Yes", style: .Default) { alertAction in
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.SessionExpired, object: nil)
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
