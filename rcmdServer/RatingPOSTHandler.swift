//
//  RatingPOSTHandler.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/4/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib

class RatingPOSTHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        var result = ""
        var dict: [String: AnyObject]?
        
        if let data = request.postBodyString.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                dict = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : AnyObject]
            } catch {
                
            }
        }
        if let dict = dict {
            if let movieID = dict[movieIDKey] as? Int, let userID = dict[userIDKey] as? Int, let rating = dict[ratingKey] as? Int {
                if rating >= 0 && rating <= 5 {
                   let query = "UPDATE rating SET \"rating\"='\(rating)' WHERE \"movie_id\"='\(movieID)' AND \"user_id\"='\(userID)'"
                    print("\(query)")
                    
                    let r = DataManager.sharedInstance.pgsl.exec(query)
                    if r.status() == .CommandOK {
                    } else {
                        result = String.JSONStrErrorWithError(NSError.init(domain: DatabaseErrorDomain, code: DatabaseError.queryFailed.rawValue, userInfo: nil))
                    }
                } else {
                    result = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.requestVariablesNotValid.rawValue, userInfo: nil))
                }
                    
            } else {
                result = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.requestVariablesNotFound.rawValue, userInfo: nil))
            }
        } else {
            result = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.requestFormatError.rawValue, userInfo: nil))
        }
        
        
        response.appendBodyString(result)
        response.requestCompletedCallback()
    }
}