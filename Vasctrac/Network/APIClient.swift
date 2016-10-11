//
//  APIClient.swift
//  Vasctrac
//
//  Created by Developer on 3/16/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class APIClient {
    
    static let sharedClient = APIClient()
    
    private(set) lazy var userId : String = {
        guard let user = SessionManager.sharedManager.currentUser else {
            fatalError("**no current user**")
        }
        return user.userId
    }()
    
    
    func request(
        method: Alamofire.Method,
        _ URLString: APIRoute,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .JSON,
        headers: [String: String]? = nil)
        -> Request
    {
        if let token = SessionManager.sharedManager.accessToken {
            guard let requestWithToken = self.makeRequestAuthorizationHeader(token, method,
                                                                             URLString.URLString,
                                                                             parameters: parameters,
                                                                             encoding: encoding) else {
                fatalError("***Request with token couldn't be created***")
            }
            print("token:\(token)")
            return Alamofire.request(requestWithToken)
        } else {
            return Alamofire.request(method, URLString, parameters: parameters, encoding: .JSON, headers: headers)
        }
        
    }
    
    func makeRequestWithErrorHandling (
        method: Alamofire.Method,
        _ URLString: APIRoute,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil,
        onCompletion: ((AnyObject?, String?) -> Void) )
    {
        print("PARAMETERS:\(parameters)")
        
        self.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON
        { response in
            
            print("Response debug description: \(response.debugDescription)\n")
            print("Response request: \(response.request!)")
            
            switch response.result {
                
            case .Success(let value):
                
                onCompletion(JSON(value).object, nil)
                
            case.Failure(let error):
                
                guard error._code != NSURLErrorTimedOut else {
                    //timeout
                    onCompletion(nil, "Seems you are not connected to the internet. Please, verify your connection and try again.")
                    return
                }
                
                var json = JSON(error)
                let error = json["error"]
                if error != nil {
                    
                    if error["user_error"] != nil {
                        
                        onCompletion(nil, error["user_error"].stringValue)
                        
                    } else if ErrorManager.sharedManager.isUserTokenExpiration(error["error"].stringValue) {
                            
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.SessionExpired, object: nil)
                        onCompletion(nil, nil)
                    }
                        
                } else {
                    onCompletion(nil, "Internal server error")
                }
                
            }
           
        }
    }
    
    // MARK: Conveninence
    
    // adds token to request's header
    private func makeRequestAuthorizationHeader(
        token: String,
        _ method: Alamofire.Method,
          _ URLString: String,
            parameters: [String: AnyObject]?,
            encoding: ParameterEncoding = .JSON)
        -> NSMutableURLRequest?
    {
        var body : NSData? = nil
        var URLString = URLString
        
        if let parameters = parameters {
            switch encoding {
            case .URLEncodedInURL:
                var queryItems = [NSURLQueryItem]()
                for key in parameters.keys {
                    queryItems += [NSURLQueryItem.init(name: key, value: parameters[key] as? String)]
                }
                let urlComponents = NSURLComponents.init(string: URLString)
                urlComponents!.queryItems = queryItems
                
                URLString = urlComponents!.URLString
                
            default:
                do {
                    body = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
                } catch {
                    print("json error: \(error)")
                }
            }
        }
        
        
        let URL = NSURL(string: URLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let body = body {
            mutableURLRequest.HTTPBody = body
        }
        
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return mutableURLRequest
    }
    
}
