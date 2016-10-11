//
//  APIRoute.swift
//  Vasctrac
//
//  Created by Developer on 5/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Alamofire

enum APIRoute : URLStringConvertible {

    private static let baseURL : String = Constants.Network.currentServerUrl
    
    case Login
    case Register
    case CurrentUser
    case UpdateCurrentUser(String)
    case VerifyEmail(String)
    case IsEmailVerified(String)

    // surveys, activities
    case MedicalHistory(String)
    case Medication(String)
    case Surgeries(String)
    case WalkTest(String)
    case PhysicalActivity(String)
    case DailySteps(String)
    case UpdateDailySteps(String,String)
    
    case DashboardTrends(String)

    case Messages(String)
    case MessageRead(String,String)
    
    var URLString: String {

        let result: String = {

            switch self {
            case .Login:
                return "/login"

            case .Register:
                return "/register"

            case .CurrentUser:
                return "/currentuser"
                
            case .UpdateCurrentUser(let userId):
                return "/users/\(userId)"
                
            case .VerifyEmail(let userId):
                return "/users/\(userId)/verifyEmail"
                
            case .IsEmailVerified(let userId):
                return "/users/\(userId)/isEmailVerified"

            case .MedicalHistory(let userId):
                return "/users/\(userId)/medicalhistory"

            case .Medication(let userId):
                return "/users/\(userId)/medication"

            case .Surgeries(let userId):
                return "/users/\(userId)/surgeries"

            case .WalkTest(let userId):
                return  "/users/\(userId)/walkingtests"

            case .PhysicalActivity(let userId):
                return "/users/\(userId)/physicalactivity"

            case .DailySteps(let userId):
                return "/users/\(userId)/dailysteps"
                
            case .UpdateDailySteps(let userId, let stepsId):
                return "/users/\(userId)/dailysteps/\(stepsId)"
                
            case .DashboardTrends(let userId):
                return "/users/\(userId)/trends"
                
            case .Messages(let userId):
                return "/users/\(userId)/messages"
                
            case .MessageRead(let userId, let messageId):
                return "/users/\(userId)/messages/\(messageId)/read"
            }

        }()

        return APIRoute.baseURL + result
    }

}
