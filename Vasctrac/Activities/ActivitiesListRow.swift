//
//  ActivitiesTasksListRow.swift
//  Vasctrac
//
//  Created by Developer on 2/29/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

/**
 An enum that corresponds to a row displayed in a `ActivitiesTableViewController`.
 */
enum ActivitiesListRow: Int, CustomStringConvertible {
    case MedicalHistory = 0
    case SurgicalHistory
    case PhysicalActivity
    case WalkTest
    
    case SurgicalHistoryIntruduction
    case SurgicalHistoryEnd
    
    static let onboardingSurveys = [MedicalHistory, SurgicalHistoryIntruduction, PhysicalActivity]
    static let quarterlySurveys = [SurgicalHistory, PhysicalActivity]
    static let all = [MedicalHistory, SurgicalHistory, PhysicalActivity, WalkTest]
    
    // MARK: CustomStrings
    
    var description: String {
        switch self {
        case .MedicalHistory:
            return NSLocalizedString("Medical History", comment: "")
            
        case .SurgicalHistory:
            return NSLocalizedString("Surgical History", comment: "")
            
        case .PhysicalActivity:
            return NSLocalizedString("Physical Activity", comment: "")
            
        case .WalkTest:
            return NSLocalizedString("Walk Test", comment: "")
        
        default: return ""
        }
    }
    
    enum MedicalHistoryIdentifier : String {
        // MedicalHistory
        case HistoryChoices = "medical_history_choices"
        case Pad = "pad"
        case Smoking = "smoking"
        case Diabetes = "diabetes"
        case Hypertension = "high_blood_pressure"
        case HeartDisease = "heart_disease"
        
        case MedicationChoices = "medication_choices"
        case Aspirin = "aspirin"
        case Plavix = "plavix"
        case Statin = "statin"
        case Insulin = "insulin"
        case Warfarin = "warfarin"
        case None = "none"
        
        static let historyChoicesValues = [Diabetes.rawValue, Hypertension.rawValue, HeartDisease.rawValue, None.rawValue]
        static let medicationChoicesValues = [Aspirin.rawValue, Plavix.rawValue, Insulin.rawValue, Statin.rawValue, Warfarin.rawValue, None.rawValue]
    }
    
    
    // MARK: Properties
    
    /// Returns a new `ORKTask` that the `TaskListRow` enumeration represents.
    var representedTask: ORKTask {
        switch self {
        case .MedicalHistory:
            return medicalHistoryTask
            
        case .SurgicalHistory:
            return surgicalHistoryTask
            
        case .SurgicalHistoryIntruduction:
            return surgicalHistoryIntruductionTask
            
        case .SurgicalHistoryEnd:
            return surgicalHistoryEndTask
            
        case .PhysicalActivity:
            return physicalActivityTask
            
        case .WalkTest:
            return walkTestActivity
        }
    }
    
    enum identifier : String {
        case MedicalHistory = "medicalHistoryTask"
        case SurgicalHistory = "surgicalHistoryTask"
        case SurgicalHistoryIntro = "surgicalHistoryIntoTask"
        case SurgicalHistoryEnd = "surgicalHistoryEndTask"
        case PhysicalActivity = "physicalActivityTask"
        case WalkTest = "walkTest"
    }
    
    enum WalkTestIdentifier : String {
        case GetReady = "walk_test_instruction_step_get_ready"
        case WalkActiveStep = "walk_active_step"
        
        case Tired = "stopping_reason_tired"
        case Interrupted = "stopping_reason_interrupted"
        case LegHurt = "stopping_reason_leg_hurt"
        
        static let stoppingReasons = [Tired.rawValue, Interrupted.rawValue, LegHurt.rawValue]
    }
    
    enum SurgicalHistoryIdentifier : String {
        case Choice = "surgical_history_choice"
        case Open = "open"
        case Endovascular = "endovascular"
        case EndovascularForm = "endovascular_form"
        case OpenForm = "open_form"
        
        case BaloonAngioplasty = "Balloon Angioplasty"
        case BaloonAngioplastyDate = "baloon_angioplasty_date"
        
        case Stent = "Stent"
        case StentDate = "Angiogram Stent Date"
        
        case Atherectomy = "Atherectomy"
        case AtherectomyDate = "AtherectomyDate"
        
        case OpenBypass = "Open Bypass"
        case OpenBypassDate = "OpenBypassDate"
        
        case Endarterectomy = "Endarterectomy"
        case EndarterectomyDate = "EndarterectomyDate"
        
        case Other = "Other Treatment"
        
        case Location =  "anatomical_location"
        case LeftLeg = "Left Leg"
        case RightLeg = "Right Leg"
        case Abdomen = "Abdomen"
        
        static let treatments = [BaloonAngioplasty.rawValue, Stent.rawValue, Atherectomy.rawValue, OpenBypass.rawValue, Endarterectomy.rawValue]
        
        static func gerCorrespondingAngiogramKey(value: String) -> String {
            var key = ""
            switch ActivitiesListRow.SurgicalHistoryIdentifier(rawValue: value)! {
            case .BaloonAngioplastyDate:
                key = BaloonAngioplasty.rawValue
            case .StentDate:
                key = Stent.rawValue
            case .AtherectomyDate:
                key = Atherectomy.rawValue
            case .OpenBypassDate:
                key = OpenBypass.rawValue
            case .EndarterectomyDate:
                key = Endarterectomy.rawValue
            default:break
            }
            return key
        }
        
        static func gerCorrespondingBypassKey(value: String) -> String {
            // I get date_bypass_0
            return value.stringByReplacingOccurrencesOfString("date_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
    }

    
    private var medicalHistoryTask: ORKTask {
        
        var steps = [ORKStep]()
        
        // STEP 1
        var step = ORKQuestionStep(identifier: MedicalHistoryIdentifier.Pad.rawValue, title: "Have you been diagnosed with Peripheral Arterial Disease (PAD)?", answer: ORKBooleanAnswerFormat())
        step.optional = false
        steps += [step]
        
        // STEP 2
        var textChoices = [
            ORKTextChoice(text: NSLocalizedString("Diabetes", comment: ""),value: MedicalHistoryIdentifier.Diabetes.rawValue),
            ORKTextChoice(text: NSLocalizedString("High Blood Preassure", comment: ""),value: MedicalHistoryIdentifier.Hypertension.rawValue),
            ORKTextChoice(text: NSLocalizedString("Heart Disease", comment: ""), value: MedicalHistoryIdentifier.HeartDisease.rawValue),
            ORKTextChoice(text: NSLocalizedString("None", comment: ""), detailText: nil, value: MedicalHistoryIdentifier.None.rawValue, exclusive: true)
            ]
        step = ORKQuestionStep(identifier: MedicalHistoryIdentifier.HistoryChoices.rawValue, title: "Please choose all of the following conditions that apply to you", answer: ORKTextChoiceAnswerFormat.init(style: .MultipleChoice, textChoices: textChoices))

        steps += [step]
        
        
        // STEP 3
        textChoices = [
            ORKTextChoice(text: NSLocalizedString("Current Smoker", comment: ""), value: "Current Smoker"),
            ORKTextChoice(text: NSLocalizedString("Former Smoker", comment: ""), value: "Former Smoker"),
            ORKTextChoice(text: NSLocalizedString("Never Smoked", comment: ""), value: "Never Smoked"),
            ]
        step = ORKQuestionStep(identifier: MedicalHistoryIdentifier.Smoking.rawValue, title: "History of Smoking",
                                          answer: ORKTextChoiceAnswerFormat.init(style: .SingleChoice, textChoices: textChoices))
        steps += [step]
        
        
        // STEP 4
        textChoices = [
            ORKTextChoice(text: NSLocalizedString("Aspirin", comment: ""), value: MedicalHistoryIdentifier.Aspirin.rawValue),
            ORKTextChoice(text: NSLocalizedString("Plavix/Clopidogrel", comment: ""), value: MedicalHistoryIdentifier.Plavix.rawValue),
            ORKTextChoice(text: NSLocalizedString("Statin", comment: ""), value: MedicalHistoryIdentifier.Statin.rawValue),
            ORKTextChoice(text: NSLocalizedString("Insulin", comment: ""), value: MedicalHistoryIdentifier.Insulin.rawValue),
            ORKTextChoice(text: NSLocalizedString("Warfarin/Coumadin", comment: ""), value: MedicalHistoryIdentifier.Warfarin.rawValue),
            ORKTextChoice(text: NSLocalizedString("None", comment: ""), detailText: nil, value: MedicalHistoryIdentifier.None.rawValue, exclusive: true),
            ]
        step = ORKQuestionStep(identifier: MedicalHistoryIdentifier.MedicationChoices.rawValue, title: "Medications", answer: ORKTextChoiceAnswerFormat.init(style: .MultipleChoice, textChoices: textChoices))
        step.text = NSLocalizedString("Please choose all of the medications that you currently take", comment: "")
        steps += [step]
        
        // END
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Medical History"
        summaryStep.text = "Thank you for your information."
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: identifier.MedicalHistory.rawValue, steps: steps)
    }
    
    private var surgicalHistoryIntruductionTask: ORKTask {
        
        let step = ORKQuestionStep(identifier: "surgical_history_boolean", title: "Have you had any new vascular procedures?", answer: ORKBooleanAnswerFormat())
        
        // Create navigable task
        return ORKOrderedTask(identifier: identifier.SurgicalHistoryIntro.rawValue, steps: [step])
    }
    
    private var surgicalHistoryEndTask: ORKTask {
        
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Surgical History"
        summaryStep.text = "Thank you for your information."
        
        return ORKOrderedTask(identifier: identifier.SurgicalHistoryEnd.rawValue, steps: [summaryStep])
    }

    
    private var surgicalHistoryTask: ORKTask {
        
        var steps = [ORKStep]()

        // STEP 1
        var textChoices = [
            ORKTextChoice(text: NSLocalizedString("Endovascular Procedure \n(Angioplasty or Stent)", comment: ""), value: SurgicalHistoryIdentifier.Endovascular.rawValue),
            ORKTextChoice(text: NSLocalizedString("Open Surgery \n(Bypass or Endarterectomy)", comment: ""), value: SurgicalHistoryIdentifier.Open.rawValue)
        ]
        var step = ORKQuestionStep(identifier: SurgicalHistoryIdentifier.Choice.rawValue, title: "Which procedures?", answer: ORKTextChoiceAnswerFormat.init(style: .SingleChoice, textChoices: textChoices))
        steps += [step]
        
        
        // STEP Open Surgery
        let openForm = ORKFormStep(identifier: "open_surgery_form", title: "What type of open vascular surgical procedure did you have?", text: "")
        var openFormItems = [ORKFormItem]()
        
        // open_surgery_bypass
        var item = ORKFormItem(identifier: SurgicalHistoryIdentifier.OpenBypass.rawValue, text: "", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: [ORKTextChoice(text: "Bypass Surgery", value: "bypass")]))
        openFormItems += [item]
        
        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.OpenBypassDate.rawValue, text: "", answerFormat: ORKAnswerFormat.dateAnswerFormatWithDefaultDate(NSDate(), minimumDate: nil, maximumDate: NSDate(), calendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)))
        item.placeholder = "Date Performed"
        openFormItems += [item]
        
        // open_surgery_endarterectomy
        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.Endarterectomy.rawValue, text: "", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: [ORKTextChoice(text: "Endarterectomy", value: "endarterectomy")]))
        openFormItems += [item]
        
        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.EndarterectomyDate.rawValue, text: "", answerFormat: ORKAnswerFormat.dateAnswerFormatWithDefaultDate(NSDate(), minimumDate: nil, maximumDate: NSDate(), calendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)))
        item.placeholder = "Date Performed"
        openFormItems += [item]
        
        
        // open_surgery_other
        let answerFormat = ORKAnswerFormat.textAnswerFormat()
        answerFormat.multipleLines = false
        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.Other.rawValue, text: "", answerFormat: answerFormat)
        item.placeholder = NSLocalizedString("Other", comment: "");
        openFormItems += [item]
        
        
        openForm.formItems = openFormItems
        steps += [openForm]
        
        
        // STEP Endovascular Procedure - Angiogram
        let endoForm = ORKFormStep(identifier: SurgicalHistoryIdentifier.EndovascularForm.rawValue, title: "What type of endovascular procedure did you have?", text: "")
        var endoFormItems = [ORKFormItem]()
        
        
        //
        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.BaloonAngioplasty.rawValue, text: "", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: [ORKTextChoice(text: "Balloon Angioplasty", value: "baloon_angioplasty")]))
        endoFormItems += [item]
        
//        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.BaloonAngioplastyDate.rawValue, text: "", answerFormat: ORKAnswerFormat.dateAnswerFormatWithDefaultDate(NSDate(), minimumDate: nil, maximumDate: NSDate(), calendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)))
//        item.placeholder = "Date Performed"
//        endoFormItems += [item]
        
        
        //
        item = ORKFormItem(identifier:  SurgicalHistoryIdentifier.Stent.rawValue, text: "", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: [ORKTextChoice(text: "Stent", value: "stent")]))
        endoFormItems += [item]
        
//        item = ORKFormItem(identifier:  SurgicalHistoryIdentifier.StentDate.rawValue, text: "", answerFormat: ORKAnswerFormat.dateAnswerFormatWithDefaultDate(NSDate(), minimumDate: nil, maximumDate: NSDate(), calendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)))
//        item.placeholder = "Date Performed"
//        endoFormItems += [item]
        
        
        //
        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.Atherectomy.rawValue, text: "", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: [ORKTextChoice(text: "Atherectomy", value: "atherectomy")]))
        endoFormItems += [item]
        
        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.AtherectomyDate.rawValue, text: "", answerFormat: ORKAnswerFormat.dateAnswerFormatWithDefaultDate(NSDate(), minimumDate: nil, maximumDate: NSDate(), calendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)))
        item.placeholder = "Date Performed"
        endoFormItems += [item]
        
        
        //
//        item = ORKFormItem(identifier: SurgicalHistoryIdentifier.Other.rawValue, text: "", answerFormat: answerFormat)
//        item.placeholder = NSLocalizedString("Other", comment: "");
//        endoFormItems += [item]
        
        
        endoForm.formItems = endoFormItems
        steps += [endoForm]
        
        
        
        // STEP Anatomical Location
        textChoices = [
            ORKTextChoice(text: NSLocalizedString("Abdomen", comment: ""), value: SurgicalHistoryIdentifier.Abdomen.rawValue),
            ORKTextChoice(text: NSLocalizedString("Left Leg", comment: ""), value: SurgicalHistoryIdentifier.LeftLeg.rawValue),
            ORKTextChoice(text: NSLocalizedString("Right Leg", comment: ""), value: SurgicalHistoryIdentifier.RightLeg.rawValue),
        ]
        step = ORKQuestionStep(identifier: SurgicalHistoryIdentifier.Location.rawValue, title: "Where are the arteries that were treated?", answer: ORKTextChoiceAnswerFormat.init(style: .MultipleChoice, textChoices: textChoices))
        steps += [step]
        
        
        // Another procedure? -> If yes, show the task again
        step = ORKQuestionStep(identifier: "another_procedure_boolean", title: "Did you have another vascular procedure?", answer: ORKBooleanAnswerFormat())
        step.optional = false
        steps += [step]
        
        // Create navigable task
        let surgicalHistoryTask = ORKNavigableOrderedTask(identifier: identifier.SurgicalHistory.rawValue, steps: steps)
        
        
        // NAVIGATION RULES
        
        // if user selects 'endovascular'
        var resultSelector = ORKResultSelector(resultIdentifier: SurgicalHistoryIdentifier.Choice.rawValue)
        var predicate = ORKResultPredicate.predicateForChoiceQuestionResultWithResultSelector(resultSelector, expectedAnswerValue: SurgicalHistoryIdentifier.Endovascular.rawValue)
        let predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(predicate, SurgicalHistoryIdentifier.EndovascularForm.rawValue)])
        surgicalHistoryTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: SurgicalHistoryIdentifier.Choice.rawValue)
        
        // from 'open_surgery_form' jump to 'anatomical_location'
        resultSelector = ORKResultSelector(resultIdentifier: "open_surgery_form")
        surgicalHistoryTask.setNavigationRule(ORKDirectStepNavigationRule(destinationStepIdentifier: "anatomical_location"), forTriggerStepIdentifier: "open_surgery_form")
        
        // Another procedure? -> If yes, show the task again -> don't show summary step
        resultSelector = ORKResultSelector(resultIdentifier: "another_procedure_boolean")
        predicate = ORKResultPredicate.predicateForBooleanQuestionResultWithResultSelector(resultSelector, expectedAnswer: true)
        let directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: ORKNullStepIdentifier)
        surgicalHistoryTask.setNavigationRule(directRule, forTriggerStepIdentifier: "another_procedure_boolean")
        
        return surgicalHistoryTask
    }
    
    private func indexIdentifier(identifier: String, index: Int) -> String {
        return identifier + "_" + String(index)
    }
    
    private var physicalActivityTask: ORKTask {
        
        var steps = [ORKStep]()
        
        var step = ORKQuestionStep(identifier: "cramping_with_activity", title: "Do you have painful cramping in the leg or thigh with activity?", answer: ORKBooleanAnswerFormat())
        steps += [step]
        
        
        step = ORKQuestionStep(identifier: "rest_improve_pain", title: "Does rest improve the pain?", answer: ORKBooleanAnswerFormat())
        steps += [step]
        
        step = ORKQuestionStep(identifier: "pain_with_exercise", title: "Does the pain come on every time you excercise?", answer: ORKBooleanAnswerFormat())
        steps += [step]
        
        // STEP 1
        var textChoices = [
            ORKTextChoice(text: NSLocalizedString("At Rest", comment: ""), value: "At Rest"),
            ORKTextChoice(text: NSLocalizedString("In Bed", comment: ""), value: "In Bed"),
            ORKTextChoice(text: NSLocalizedString("Sitting", comment: ""), value: "Sitting"),
            ORKTextChoice(text: NSLocalizedString("When walking", comment: ""), value: "When walking"),
            ]
        step = ORKQuestionStep(identifier: "when_pain_occurs", title: "When do you get the pain?",
                                        answer: ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: textChoices))
        steps += [step]
        
        
        step = ORKQuestionStep(identifier: "open_wounds", title: "Do you have any open wounds on your feet?", answer: ORKBooleanAnswerFormat())
        steps += [step]

        
        // STEP 3
        textChoices = [
            ORKTextChoice(text: NSLocalizedString("Cane", comment: ""), value: "cane"),
            ORKTextChoice(text: NSLocalizedString("Walker", comment: ""), value: "walker"),
            ORKTextChoice(text: NSLocalizedString("Wheel Chair", comment: ""), value: "wheelchair"),
            ORKTextChoice(text: NSLocalizedString("None", comment: ""), detailText: nil, value: "None", exclusive: true),
        ]
        step = ORKQuestionStep(identifier: "walking_aids", title: "Do you use any walking aid?",
                                       answer: ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: textChoices))
        steps += [step]
    
    
        // STEP 4
        let form = ORKFormStep(identifier: "abi_form", title: "Please provide your most current Ankle Brachial Index (ABI)", text: "")
        var items = [ORKFormItem]()
        
        var item = ORKFormItem(identifier: "abi_right_leg", text: "Right Leg", answerFormat: ORKDecimalOrNullAnswerFormat(style: .Decimal, unit: "", minimum: nil, maximum: nil), optional: true)
        items += [item]
        
        item = ORKFormItem(identifier: "abi_left_leg", text: "Left Leg", answerFormat: ORKDecimalOrNullAnswerFormat(style: .Decimal, unit: "", minimum: nil, maximum: nil), optional: true)
        items += [item]
        
        item = ORKFormItem(identifier: "dont_know_abi", text: "", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithStyle(.MultipleChoice, textChoices: [ORKTextChoice(text: "I dont know my ABI", value: "dont_know_abi")]))
        items += [item]
        
        form.formItems = items
        steps += [form]

        
        // END
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "PAD History"
        summaryStep.text = "Thank you for your information."
        steps += [summaryStep]
        
        // Create navigable task
        let physicalActivityTask = ORKNavigableOrderedTask(identifier: identifier.PhysicalActivity.rawValue, steps: steps)

        // Navigation Rules
        
        // If user selects No
        let predicate = ORKResultPredicate.predicateForBooleanQuestionResultWithResultSelector(ORKResultSelector(resultIdentifier: steps[0].identifier), expectedAnswer: false)
        let rule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(predicate, steps[4].identifier)])
        physicalActivityTask.setNavigationRule(rule, forTriggerStepIdentifier: steps[0].identifier)

        return physicalActivityTask
    }
    
    private var walkTestActivity: ORKTask {
        let description = NSLocalizedString("We want to see how far you can walk without stopping because PAD affects your ability to walk.", comment: "")
        return walkTillStationaryTaskWithIdentifier("walk_test", intendedUseDescription: description, maxStationaryDuration: 60, options:[])
    }
    
    
    func walkTillStationaryTaskWithIdentifier(identifier: String, intendedUseDescription: String, maxStationaryDuration: NSTimeInterval, options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        
        var steps = [ORKStep]()
        
        var step : ORKInstructionStep = ORKInstructionStep(identifier: "walk_test_instruction_step")
        step.title = NSLocalizedString("Walk Test", comment: "")
        step.text = intendedUseDescription
        step.image = UIImage(named: "test_walking_man")?.imageWithRenderingMode(.AlwaysOriginal)
        //step.image = UIImage(named: "walking_man")
        steps += [step]
        
        step = ORKInstructionStep(identifier: WalkTestIdentifier.GetReady.rawValue)
        step.title = NSLocalizedString("Get Ready", comment: "")
        step.text = NSLocalizedString("Find an open area. Hold the phone in your hand and walk as far as you can without stopping. Aim for at least 6 minutes.", comment: "")
        step.image = UIImage(named: "walk_man")
        steps += [step]
      
        let countdownStep = ORKCountdownStep(identifier: "countdown_step")
        countdownStep.stepDuration = 5.0
        countdownStep.shouldSpeakCountDown = true
        steps += [countdownStep]
        
        var recorderConfigurations = [ORKRecorderConfiguration]()
        recorderConfigurations += [ORKPedometerRecorderConfiguration(identifier: "pedometer")]
        
        let walkingStep = WalkTillStationaryTaskStep(identifier: WalkTestIdentifier.WalkActiveStep.rawValue)
        walkingStep.title = NSLocalizedString("Go!", comment: "")
        walkingStep.text = NSLocalizedString("Enjoy your walk! \n Hit \"Stop\" to end the walk test" , comment: "")
        walkingStep.maxStationaryDuration = maxStationaryDuration
        walkingStep.recorderConfigurations = recorderConfigurations
        walkingStep.shouldContinueOnFinish = true
        walkingStep.optional = false
        steps += [walkingStep]
        
        let stopStepForm = ORKFormStep(identifier: "walk_step_stop_reason_form", title: "Help us understand why you stopped", text: "")
        let textChoices = [
            ORKTextChoice(text: NSLocalizedString("I was interrupted", comment: ""),      value: WalkTestIdentifier.Interrupted.rawValue),
            ORKTextChoice(text: NSLocalizedString("I'm tired", comment: ""),              value: WalkTestIdentifier.Tired.rawValue),
            ORKTextChoice(text: NSLocalizedString("My legs hurt", comment: ""),           value: WalkTestIdentifier.LegHurt.rawValue)
            ]
        let stopStep = ORKFormItem(identifier: "walk_step_stop_reason", text: "",
                                   answerFormat: ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: textChoices))
        
        stopStepForm.formItems = [stopStep]
        steps += [stopStepForm]
        
        steps += [completionStep]
        
        let task = ORKOrderedTask(identifier: ActivitiesListRow.identifier.WalkTest.rawValue, steps: steps)
        return task
    }
    
    private var completionStep : ORKCompletionStep {
        let step = ORKCompletionStep(identifier: "completion_step")
        step.title = NSLocalizedString("Thank you", comment: "")
        step.text = NSLocalizedString("The results of this activity can be viewed on the dashboard.", comment: "")
        return step
    }
    
    static func quarterlyEventSurvey() -> ORKOrderedTask {
        
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you for your information."
        summaryStep.text = "We appreciate your time."
        
        let task = ORKOrderedTask(identifier: "QuarterlyEventSurvey", steps: [summaryStep])
        return task
    }
}
