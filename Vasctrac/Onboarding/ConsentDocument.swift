//
//  ConsentDocument.swift
//  Vasctrac
//
//  Created by Developer on 3/2/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

class ConsentDocument: ORKConsentDocument {
    // MARK: Properties
    
    /*
    let consentSections = [
        [
            "sectionType" : "custom",
            "sectionTitle": "PURPOSE OF RESEARCH",
            "sectionSummary" : "You are invited to participate in a research study of activity in patients with peripheral arterial disease (PAD). We hope to learn how activity changes over time in people with peripheral arterial disease and also how our interventions affect your activity. If are eligible for this study if you have PAD. This study is being done together by researchers at VA Palo Alto and Stanford University. Individual health information will be de-identified to all researchers, and will be stored as anonymized data in the databases. However, individuals may choose to send their identifiable data to their personal physicians to receive personalized care. Health information will be used to identify trends between physical fitness and participant demographics and PAD.\n\nThis research study is looking for 5000 people with PAD in the United States.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "VOLUNTARY PARTICIPATION",
            "sectionSummary" : "Your participation in this study is entirely voluntary. Your decision not to participate will not have any negative effect on you or your medical care. You can decide to participate now, but withdraw your consent later and stop being in the study without any loss of benefits or medical care you are entitled to.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "DURATION OF STUDY INVOLVEMENT",
            "sectionSummary" : "This research study is expected to take approximately 2 years. The mobile registration process requires an eligibility questionnaire and is followed by a brief medical and surgical history. Your daily activity will be monitored passively (without any further input from you) through your mobile phone. Every quarter we will send a questionnaire to ask if you have had any vascular surgical interventions or other health issues. Your active participation answering surveys will be likely only 9 days.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "PROCEDURES",
            "sectionSummary" : "If you choose to participate, the investigators will not require any procedures to be performed. The investigators will monitor your activity using the activity tracker of your mobile phone and will send out a questionnaire on your mobile phone upon registering as well as on a quarterly basis.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "PARTICIPANT RESPONSIBILITIES",
            "sectionSummary" : "As a participant, your responsibilities include:\n\n• Follow the instructions of the investigators and study staff.\n• Complete your questionnaires as instructed.\n• Contact us to ask questions as you think of them.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "WITHDRAWAL FROM STUDY",
            "sectionSummary" : "If you first agree to participate and then you change your mind, you are free to withdraw your consent and stop your participation at any time. If you decide to withdraw from the study, you will not lose any benefits to which you would otherwise be entitled [(if applicable) and your decision will not affect your ability to receive medical care for your condition].\n\nIf you want to stop being in the study you may do so from the VascTrac App. In the “Profile” menu you will see a “Leave Study” option. Simply this option and confirm your selection.\n\nAfter any revocation, your health information will no longer be used or disclosed in the study, except to the extent that the law allows us to continue using your information (e.g., necessary to maintain integrity of research). If you wish to revoke your authorization for the research use or disclosure of your health information in this study, you must contact: Dr. Oliver Aalami. (650) 852-3451. 3801 Miranda Avenue (112), Palo Alto, CA 94304-1290.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "POSSIBLE RISKS, DISCOMFORTS, AND INCONVENIENCES",
            "sectionSummary" : "This study involves the following risks, and possible inconveniences: Your health information related to this study may be used or disclosed in connection with this research study, including, but not limited to name, email, gender, ethnicity, and previous medical and surgical treatments. In addition, users will be asked to perform a 6-minute walk test if capable, and users’ smartphones will record physical activity data that will be used to determine the relation between activity and PAD.\n\nThe following parties are authorized to use and/or disclose your health information in connection with this research study:\n\n• The Protocol Director (Dr. Oliver Aalami)\n• The Stanford University Administrative Panel on Human Subjects in Medical Research and any other unit of Stanford University as necessary\n• Research Staff\n\nThe parties listed in the preceding paragraph may disclose your health information to the following persons and organizations for their use in connection with this research study:\n\n• The Office for Human Research Protections in the U.S. Department of Health and Human Services\n• Microsoft Azure (Secure web hosting)\n• Software developer\n\nYour authorization for the use and/or disclosure of your health information will end on January 1, 2025 or when the research project ends, whichever is earlier.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "POTENTIAL BENEFITS",
            "sectionSummary" : "We hope to learn more about the natural history of PAD and hope to become better at determining when to perform surveillance studies in patients that have had open or endovascular interventions.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "ALTERNATIVES",
            "sectionSummary" : "The alternative to this study is not to participate.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "PARTICIPANT’S RIGHTS",
            "sectionSummary" : "You should not feel obligated to agree to participate. Your questions should be answered clearly and to your satisfaction.\n\nYou will be told of any important new information that is learned during the course of this research study, which might affect your condition or your willingness to continue participation in this study.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "ClinicalTrials.gov",
            "sectionSummary" : "A description of this clinical trial will be available on http://www.ClinicalTrials.gov, as required by U.S. Law. This Web site will not include information that can identify you. At most, the Web site will include a summary of the results. You can search this Web site at any time.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "CONFIDENTIALITY",
            "sectionSummary" : "We will keep your name and all the information about you used in this study as confidential as possible. We may publish the results of this study for others to read about, but you will not be identified in any articles about the study by name, social security number, address, telephone number, or any other direct personal identifier. Also, other federal agencies as required, such as the VA Office of Research Oversight and the VA Office of the Inspector General may have access to your information.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "FINANCIAL CONSIDERATIONS",
            "sectionSummary" : "Payment\nThere is no payment associated with this study.\n\nCosts\nThere will be no costs to you for any of the treatment or testing done as part of this research study. However, medical care and services provided by the VA that are not part of this study (e.g., normal hospital and prescription expenses which are not part of the research study) may require co-payments if your VA-eligibility category requires co-payment for VA services.\nYou will not have to pay anything to be in this study.\n\nSponsor\nAbbott Vascular, Gore Medical, Cook Medical and Microsoft Azure are providing financial support and/or material for this study.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "CONTACT INFORMATION",
            "sectionSummary" : "Questions, Concerns, or Complaints: If you have any questions, concerns or complaints about this research study, its procedures, risks and benefits, or alternative courses of treatment, you should ask the principal investigator Dr. Oliver Aalami. (650) 852-3451. 3801 Miranda Avenue (112), Palo Alto, CA 94304-1290.\n*Injury Notification: If you feel you have been hurt by being a part of this study, please contact the principal investigator, Dr. Oliver Aalami. (650) 852-3451. 3801 Miranda Avenue (112), Palo Alto, CA 94304-1290.\n\nIndependent Contact: If you are not satisfied with how this study is being conducted, or if you have any concerns, complaints, or general questions about the research or your rights as a participant, please contact the Stanford Institutional Review Board (IRB) to speak to someone independent of the research team at (650)-723-5244 or toll free at 1-866-680-2906. You can also write to the Stanford IRB, Stanford University, 3000 El Camino Real, Five Palo Alto Square, 4th Floor, Palo Alto, CA 94306.\n\nQuestions, Concerns, or Complaints: If you have any questions, concerns or complaints about this research study, its procedures, risks and benefits, or alternative courses of treatment, you should ask the principal investigator Dr. Oliver Aalami. (650) 852-3451. 3801 Miranda Avenue (112), Palo Alto, CA 94304-1290.You should also contact him at any time if you feel you have been hurt by being a part of this study.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "EXPERIMENTAL SUBJECT’S BILL OF RIGHTS",
            "sectionSummary" : "As a research participant you have the following rights. These rights include but are not limited to the participant's right to:\n\n• be informed of the nature and purpose of the experiment;\n• be given an explanation of the procedures to be followed in the medical experiment, and any drug or device to be utilized;\n• be given a description of any attendant discomforts and risks reasonably to be expected;\n• be given an explanation of any benefits to the subject reasonably to be expected, if applicable;\n• be given a disclosure of any appropriate alternatives, drugs or devices that might be advantageous to the subject, their relative risks and benefits;\n• be informed of the avenues of medical treatment, if any available to the subject after the experiment if complications should arise;\n• be given an opportunity to ask questions concerning the experiment or the procedures involved;\n• be instructed that consent to participate in the medical experiment may be withdrawn at any time and the subject may discontinue participation without prejudice;\n• be given a copy of the signed and dated consent form; and\n• be given the opportunity to decide to consent or not to consent to a medical experiment without the intervention of any element of force, fraud, deceit, duress, coercion or undue influence on the subject's decision.",
            "sectionHtmlContent" : "",
            "sectionImage": "overview",
        ]
    ]
    */
    
    
    let consentSections = [
        [
            "sectionType" : "onlyInDocument",
            "sectionHtmlContent" : "Fullconsent"
        ],
        [
            "sectionType" : "custom",
            "sectionTitle": "Welcome!",
            "sectionSummary" : "This simple walkthrough will explain the research study, the impact it may have on your life and will allow you to provide your consent to participate.",
            "sectionHtmlContent" : "Welcome",
            "sectionImage": "overview",
        ],
        
        [
            "sectionType" : "custom",
            "sectionTitle": "Activities",
            "sectionSummary": "This study will ask you to perform tasks and respond to surveys.",
            "sectionHtmlContent" : "Activities",
            "sectionImage": "activities",
        ],
        
        [
            "sectionType" : "custom",
            "sectionTitle": "Sensor and Health Data",
            "sectionSummary": "This study will also gather sensor and health data from your iPhone with your permission.",
            "sectionHtmlContent" : "Sensor_and_Health_Data",
            "sectionImage": "sensor_and_health_data",
        ],
        
        [
            "sectionType" : "custom",
            "sectionTitle": "Protecting your Data",
            "sectionSummary": "Your data will be encrypted and sent to a secure database, with your name replaced by a random code.",
            "sectionImage": "protecting_your_data",
            "sectionHtmlContent" : "Protecting_your_Data"
        ],
        
        [
            "sectionType" : "custom",
            "sectionTitle" : "Time Commitment",
            "sectionSummary": "After completing enrollment, this study will require 20 minutes of participation per month until the end of the study.",
            "sectionImage": "time_commitment",
            "sectionHtmlContent" : "Time_Commitment"
        ],
        
        [
            "sectionType" : "custom",
            "sectionTitle" : "Withdrawing",
            "sectionSummary" : "You may withdraw from the study at any time from the My Profile section.",
            "sectionImage": "withdrawing",
            "sectionHtmlContent" : "Withdrawing"
            
        ],
        
        [
            "sectionType" : "custom",
            "sectionTitle": "Data Use",
            "sectionSummary" : "Your coded data will be used for research by Stanford. You can also opt-in to share your data with other researchers approved by Stanford.",
            "sectionHtmlContent" : "Data_Use",
            "sectionImage": "data_use",
        ],
        
        [
            "sectionType" : "custom",
            "sectionTitle": "Potential Benefits",
            "sectionSummary": "The information collected by this study may help you better understand and monitor your peripheral arterial disease.",
            "sectionHtmlContent" : "Potential_Benefits",
            "sectionImage": "potential_benifits",
        ],
        
        [
            "sectionType" : "custom",
            "sectionTitle": "Risk to Privacy",
            "sectionSummary": "We make every effort to protect your information including encryption and de-identification but there is always an small risk to a loss of privacy.",
            "sectionHtmlContent" : "Risk_to_Privacy",
            "sectionImage": "risk_to_privacy",
        ]
    ]
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        title = NSLocalizedString("VascTrac Study Consent Form", comment: "")
        
        sections = loadSections()
        
        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature")
        addSignature(signature)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadSections() -> [ORKConsentSection]? {
        let kSectionType: String = "sectionType"
        let kSectionTitle: String = "sectionTitle"
        let kSectionFormalTitle: String = "sectionFormalTitle"
        let kSectionSummary: String = "sectionSummary"
        let kSectionContent: String = "sectionContent"
        let kSectionHtmlContent: String = "sectionHtmlContent"
        let kSectionImage: String = "sectionImage"
        let kSectionAnimationUrl: String = "sectionAnimationUrl"
        
        let kOmitFromDocument: String = "kOmitFromDocument"
        
        var consentSectionsArray: [ORKConsentSection] = [ORKConsentSection]()
        
        for section in self.consentSections {
            
            let sectionType: ORKConsentSectionType = self.toSectionType(section[kSectionType]!)
            let title: String? = (section[kSectionTitle])
            let formalTitle: String? = (section[kSectionFormalTitle])
            let summary: String? = (section[kSectionSummary])
            let content: String? = (section[kSectionContent])
            let htmlContent: String? = (section[kSectionHtmlContent])
            let image: String? = (section[kSectionImage])
            let animationUrl: String? = (section[kSectionAnimationUrl])

            let section: ORKConsentSection = ORKConsentSection(type: sectionType)
            if title != nil {
                section.title = title
            }
            if formalTitle != nil {
                section.formalTitle = formalTitle
            }
            if summary != nil {
                section.summary = summary
            }
            if content != nil {
                section.content = content
            }
            if htmlContent != nil {
                let path: String? = NSBundle.mainBundle().pathForResource(htmlContent!, ofType: "html")
                if (path != nil) {
                    let content: String?
                    do {
                        content = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
                    } catch _ {
                        content = nil
                    }
                    section.htmlContent = content
                }
            }
            // old broken red overlay
//            if image != nil {
//                section.customImage = UIImage(named: image!)
//            }
            //new code to keep images in consent images properly shown
            if image != nil {
                section.customImage = UIImage(named: image!)?.imageWithRenderingMode(.AlwaysOriginal)
            }
            if animationUrl != nil {
                var nameWithScaleFactor: String = animationUrl!
                if UIScreen.mainScreen().scale >= 3 {
                    nameWithScaleFactor = nameWithScaleFactor.stringByAppendingString("@3x")
                }
                else {
                    nameWithScaleFactor = nameWithScaleFactor.stringByAppendingString("@2x")
                }
                let url: NSURL = NSBundle.mainBundle().URLForResource(nameWithScaleFactor, withExtension: "m4v")!
                section.customAnimationURL = url
            }
            
            if sectionType != ORKConsentSectionType.OnlyInDocument {
                section.omitFromDocument = true
            }
            
            consentSectionsArray.append(section)
        }
        return consentSectionsArray
    }
    
    func toSectionType(sectionTypeName: String) -> ORKConsentSectionType {
        var sectionType: ORKConsentSectionType = .Custom
        
        if (sectionTypeName == "overview") {
            sectionType = .Overview
        }
        else if (sectionTypeName == "privacy") {
            sectionType = .Privacy
        }
        else if (sectionTypeName == "dataGathering") {
            sectionType = .DataGathering
        }
        else if (sectionTypeName == "dataUse") {
            sectionType = .DataUse
        }
        else if (sectionTypeName == "timeCommitment") {
            sectionType = .TimeCommitment
        }
        else if (sectionTypeName == "studySurvey") {
            sectionType = .StudySurvey
        }
        else if (sectionTypeName == "studyTasks") {
            sectionType = .StudyTasks
        }
        else if (sectionTypeName == "withdrawing") {
            sectionType = .Withdrawing
        }
        else if (sectionTypeName == "custom") {
            sectionType = .Custom
        }
        else if (sectionTypeName == "onlyInDocument") {
            sectionType = .OnlyInDocument
        }
        return sectionType
    }
}
