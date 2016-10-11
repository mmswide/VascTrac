//
//  SurveysViewController.swift
//  Vasctrac
//
//  Created by Developer on 5/30/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

enum SurveyType {
    case Onboarding
    case Quarterly
    
    var surveys : [ActivitiesListRow] {
        switch self {
        case .Onboarding:
            return ActivitiesListRow.onboardingSurveys
        case .Quarterly:
            return  ActivitiesListRow.quarterlySurveys
        }
    }
}

class SurveysViewController: UIViewController {

    var surveysType : SurveyType? = .Onboarding
    var onCompletion : ((reason: ORKTaskViewControllerFinishReason) -> Void)!
    private var reasonForCompletion : ORKTaskViewControllerFinishReason = .Completed
    
    private var isPresentingSurveys : Bool = false
    
    private lazy var activities : [Activity] = {
        var _activities = [Activity]()
        if let surveyType = self.surveysType {
            for index in 0...surveyType.surveys.count-1 {
                let task = surveyType.surveys[index].representedTask
                let activity = Activity(task: task)
                _activities.append(activity)
            }
        }
        return _activities
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isPresentingSurveys {
            self.showSurveys()
        }
    }
    
    func showSurveys() {
        self.toNextSurvey()
        isPresentingSurveys = true
    }
    
    private func toNextSurvey() {
        if let activity = activities.first {
            let taskViewController = ORKTaskViewController(task: activity.task, taskRunUUID: nil)
            taskViewController.delegate = self
            presentViewController(taskViewController, animated: true, completion: {
                self.activities.removeFirst()
            })
            
        } else { // there are no more surveys to show
            
            self.navigationController?.navigationBarHidden = false
            self.onCompletion(reason: self.reasonForCompletion)
        }
    }
    
}

extension SurveysViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
        reasonForCompletion = reason
        
        if reason == .Completed {
            switch ActivitiesListRow.identifier(rawValue: taskViewController.task!.identifier)! {
            case .SurgicalHistoryIntro:
                self.handleSurgicalHistoryIntro(taskViewController.result)
            case .SurgicalHistory:
                self.handleSurgicalHistorySurveyCompletion(taskViewController.result)
            case .MedicalHistory:
                self.handleMedicalHistorySurveyCompletion(taskViewController.result)
            case .PhysicalActivity:
                self.handlePhysicalActivitySurveyCompletion(taskViewController.result)
            default:break
            }
            
            self.dismissViewControllerAnimated(true) {
                self.toNextSurvey()
            }
            
        } else {
            self.dismissViewControllerAnimated(true) {
                self.activities.removeAll() // remove all the activities
                self.toNextSurvey()
            }
        }

    }
    
    func handleSurgicalHistoryIntro(taskResult: ORKTaskResult) {
        let shouldShowSurgicalSurvey = DataCollector.surgicalHistoryIntroCollectorHandler(taskResult)
        if !shouldShowSurgicalSurvey {
            if let index = self.activities.indexOf({$0.description == ActivitiesListRow.SurgicalHistory.description}) {
                self.activities.removeAtIndex(index)
            }
        } else {
            let activity = Activity(task: ActivitiesListRow.SurgicalHistory.representedTask)
            activities.insert(activity, atIndex: 0)
        }
    }
    
    func handleMedicalHistorySurveyCompletion(taskResult: ORKTaskResult) {
        let medicalHistoryData = DataCollector.medicalHistoryCollectorHandler(taskResult)
        APIClient.sharedClient.sendMedicalHistorySurvey(medicalHistoryData.0, dataMedication: medicalHistoryData.1) {
            stringError in
            if stringError != nil {
                print("Could not send MedicalHistorySurvey \(stringError)")
            }
        }
    }
    
    func handleSurgicalHistorySurveyCompletion(taskResult: ORKTaskResult) {
        let result = DataCollector.surgicalHistoryCollectorHandler(taskResult)
        let surgicalHistoryData = result.0
        let shouldShowAgain = result.1
        APIClient.sharedClient.sendSurgicalHistory(surgicalHistoryData) {
            stringError in
            print("Could not send Surgeries \(stringError)")
        }
        
        // if there is more surgeries to add
        if shouldShowAgain {
            let activity = Activity(task: ActivitiesListRow.SurgicalHistory.representedTask)
            activities.insert(activity, atIndex: 0)
        } else { // add completion task
            let activity = Activity(task: ActivitiesListRow.SurgicalHistoryEnd.representedTask)
            activities.insert(activity, atIndex: 0)
        }
        self.toNextSurvey()
    
    }
    
    func handlePhysicalActivitySurveyCompletion(taskResult: ORKTaskResult) {
        let physicalData = DataCollector.physicalDataCollectorHandler(taskResult)
        APIClient.sharedClient.sendPhysicalActivitySurvey(physicalData)
    }
}
