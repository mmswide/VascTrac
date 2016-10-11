//
//  LoginViewController.swift
//  Vasctrac
//
//  Created by Developer on 3/2/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class LoginViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var index = 0
    var imageFile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //contentImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        for i in 0...6
        {
            let subView : UIScrollView = UIScrollView(frame: CGRectMake(scrollView.frame.size.width * CGFloat(i), 0, scrollView.frame.size.width, scrollView.frame.size.height))
            
            
            let imageView : UIImageView;
            imageView = UIImageView(image : UIImage(named : String(format:"page_%d", i + 1)));
            imageView.contentMode = .Top
            
            //imageView.image = UIImage(named : String(format:"page_%d", i + 1))
            
            let offset = subView.bounds.size.width - imageView.bounds.size.width
            let subScrollView : UIScrollView = UIScrollView(frame: CGRectMake(offset / 2 , 0, scrollView.frame.size.width, scrollView.frame.size.height))

            subScrollView.addSubview(imageView);
            subScrollView.contentSize = imageView.bounds.size
            subScrollView.showsVerticalScrollIndicator = false
            
            subView.addSubview(subScrollView)
            scrollView.addSubview(subView);
            
        }
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 7, scrollView.frame.size.height)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(offset)
    }
    
    // MARK: Login Handler
    lazy var loginHandler : (ORKTaskResult -> Void)? = { taskResult in
        
        var email = ""
        var password = ""
        if let results = taskResult.results as? [ORKStepResult] {
            
            for stepResult: ORKStepResult in results {
                
                for result: ORKResult in stepResult.results! {
                    
                    if let questionResult = result as? ORKQuestionResult {
                        let questionId = questionResult.identifier
                        
                        if let answer = questionResult.answer {
                            if questionId == "ORKLoginFormItemEmail" {
                                email = answer as! String
                                
                            } else if questionId == "ORKLoginFormItemPassword"  {
                                password = answer as! String
                            }
                        }
                    }
                }
            }
        }
        
        SessionManager.sharedManager.login(email, password: password) { [unowned self] success in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil) // dismisses login view
                self.toLoginExtraTask()
            }
        }
    }
    
    private var loginTask: ORKTask {
        class LoginStepViewController : ORKLoginStepViewController {
            override func forgotPasswordButtonTapped() {
                
                guard let stepResult = self.result else {
                    return
                }
                
                var email: String? = nil
                
                for result: ORKResult in stepResult.results! {
                    if let questionResult = result as? ORKQuestionResult {
                        let questionId = questionResult.identifier
                        
                        if let answer = questionResult.answer {
                            if questionId == "ORKLoginFormItemEmail" {
                                email = answer as? String
                            }
                        }
                    }
                }
                
                if let email = email {
                    SessionManager.sharedManager.login(email, password: "") { success in
                        if success {
                            
                        }
                    }
                    let alertTitle = NSLocalizedString("Forgot password?", comment: "")
                    let alert = UIAlertController(title: alertTitle, message: "We just sent you an email to reset your password", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }
        
        let loginTitle = NSLocalizedString("Login", comment: "")
        let loginStep = ORKLoginStep(identifier: "loginStep", title: loginTitle, text: "", loginViewControllerClass: LoginStepViewController.self)
        
        return ORKOrderedTask(identifier: "login_task", steps: [loginStep])
    }
    
    
    // MARK: Login
    @IBAction func login(sender: AnyObject) {
        let taskViewController = ORKTaskViewController(task: loginTask, taskRunUUID: nil)
        
        // Make sure we receive events from `taskViewController`.
        taskViewController.delegate = self
        
        self.presentViewController(taskViewController, animated: true, completion: {
            if (UIApplication.sharedApplication().currentUserNotificationSettings()!.types == .None) {
                PermissionsManager.sharedManager.allowNotifications()
            }
        })
    }
    

    private func toLoginExtraTask() {
        
        var steps = [ORKStep]()
        
        // Ask to share health data if it havn't been asked before
        if DailyHealthManager.sharedManager.userAuthorizedHKOnDevice == nil {
            let healthDataStep = HealthDataStep(identifier: "health_step")
            steps += [healthDataStep]
        }

        let passcodeStep = ORKPasscodeStep(identifier: "passcode_step")
        steps += [passcodeStep]
        
        let extraTask = ORKOrderedTask(identifier: "extra_login_task", steps: steps)
        
        let taskViewController = ORKTaskViewController(task: extraTask, taskRunUUID: nil)
        
        taskViewController.delegate = self
        
        self.presentViewController(taskViewController, animated: true, completion: nil)
    }
    
    private func didLogin() {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.OnboardingCompleteNotification,
                                                                  object: nil)
        self.performSegueWithIdentifier("toResearch", sender: nil)
    }
}

extension LoginViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        if reason == .Completed {
            if taskViewController.task?.identifier == "login_task" {
                self.loginHandler?(taskViewController.result)
            } else if taskViewController.task?.identifier == "extra_login_task" {
                self.dismissViewControllerAnimated(true, completion: nil)
                self.didLogin()
            }
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
