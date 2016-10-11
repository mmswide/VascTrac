//
//  JoinViewController.swift
//  Vasctrac
//
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class JoinViewController: UIViewController {

    var elegible : Bool = false

    let toRegisterSegueId = "toRegister"
    let toPermissionsSegueId = "toPermissions"
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var indicationLabel: UILabel!
    @IBOutlet weak var startConsent: UIButton!
    @IBOutlet weak var nonElegibleImage: UIImageView!
    @IBOutlet weak var successImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.elegible {
            showElegible()
        } else {
            showNonElegible()
        }
    }
    
    private func showElegible() {
        resultLabel.text = NSLocalizedString("You are elegible to join the study.", comment: "")
        indicationLabel.text = NSLocalizedString("Tap the button below to begin the consent process.", comment: "")
        nonElegibleImage.hidden = true
        successImage.hidden = false
        startConsent.hidden = false
    }
    
    private func showNonElegible() {
        resultLabel.text = NSLocalizedString("Sorry, but you are not eligible to directly participate in the VascTrac PAD ResearchKit Study.", comment: "")
        indicationLabel.text = NSLocalizedString("", comment: "")
        nonElegibleImage.hidden = false
        successImage.hidden = true
        startConsent.hidden = true
    }
    
    @IBAction func startConsent(sender: AnyObject) {
        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
        
        let signature = consentDocument.signatures!.first
        
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReview", signature: signature, inDocument: consentDocument)
        
        // In a real application, you would supply your own localized text.
        reviewConsentStep.reasonForConsent = NSLocalizedString("By agreeing you confirm that you read the consent form and that you wish to take part in this research study.", comment: "")
        
        let joinTask = ORKOrderedTask(identifier: "consentTask", steps: [
            consentStep,
            JoinViewController.shareStep,
            reviewConsentStep
            ]
        )
        
        let taskViewController = ORKTaskViewController(task: joinTask, taskRunUUID: nil)
        taskViewController.delegate = self

        presentViewController(taskViewController, animated: true, completion: nil)
    }
    
    class var shareStep : ORKConsentSharingStep {
        let investigatorShortDescription = NSLocalizedString("VascTrac", comment: "")
        let investigatorLongDescription = NSLocalizedString("VascTrac", comment: "")
        let localizedLearnMoreHTMLContent = NSLocalizedString("You have the option of only sharing your data with the VascTrac research team or allowing us to share your de-identified data with other approved worldwide researchers. Many research groups around the world study peripheral arterial disease and could benefit from having access to your data.", comment: "")
        return ORKConsentSharingStep(identifier: "SharingStep", investigatorShortDescription: investigatorShortDescription, investigatorLongDescription: investigatorLongDescription, localizedLearnMoreHTMLContent: localizedLearnMoreHTMLContent)
    }
    
    
    // MARK : - Navigation
    
    func toPermissions() {
        self.performSegueWithIdentifier(toPermissionsSegueId, sender: nil)
    }
    
    func toHealthData() {
        let healthDataStep = HealthDataStep(identifier: "Health")
        let healthData = ORKOrderedTask(identifier: "healthData", steps: [healthDataStep])
        let taskViewController = ORKTaskViewController(task: healthData, taskRunUUID: nil)
        taskViewController.delegate = self
        self.presentViewController(taskViewController, animated: true, completion: nil)
    }
    
}

extension JoinViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        if reason == .Completed {
            self.dismissViewControllerAnimated(true, completion: nil)
            
            if taskViewController.task?.identifier == "consentTask" {
                
                SessionManager.sharedManager.userSignatureFirstName = DataCollector.collectContentData(taskViewController.result).0
                SessionManager.sharedManager.userSignatureLastName = DataCollector.collectContentData(taskViewController.result).1
                
                // user agreed to consent review if both names form signature are not nil
                if SessionManager.sharedManager.userSignatureLastName != nil &&
                    SessionManager.sharedManager.userSignatureFirstName != nil {
                    if DailyHealthManager.sharedManager.userAuthorizedHKOnDevice == nil {
                        toHealthData()
                    } else {
                        toPermissions()
                    }
                } else {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                
            } else if taskViewController.task?.identifier == "healthData" {
                toPermissions()
            }
            
        } else { // if fails or discarded
            self.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
}
