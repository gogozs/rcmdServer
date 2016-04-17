//
//  userRatingHandler.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/17/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib

class UserRatingHandler:  RequestHandler{
    func handleRequest(request: WebRequest, response: WebResponse) {
        print("\(request.requestURI())")
        let parameters = request.requestParametersFromStr(request.urlVariables[ratingKey]!)
        
        var resultStr = ""
        
        if let parameters = parameters {
            if let userID = parameters[userIDKey], let movieID = parameters[movieIDKey]{
                if let score = DataManager.sharedInstance.getUserRatingWithMovieID(Int(movieID)!, userID: Int(userID)!) {
                    resultStr = String.JSONStrFromObject([ratingKey: score])
                } else {
                    resultStr = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.resultNotFound.rawValue, userInfo: nil))
                }
            }
        }
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}