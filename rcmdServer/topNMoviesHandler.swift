//
//  topNMoviesHandler.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/4/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib
import PostgreSQL

class TopNMoviesHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        var result = ""
        
        if let NStr = request.urlVariables[countKey] {
            if let N = Int(NStr) {
                DataManager.sharedInstance.topRatedMovies(N)
            } else {
                result = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.requestFormatError.rawValue, userInfo: nil))
            }
        } else {
            result = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.requestVariablesNotFound.rawValue, userInfo: nil))
        }
        
        if let topRatedMovies = DataManager.sharedInstance.topRatedMovies {
            result = String.JSONStrFromObject(topRatedMovies)
        } else {
            result = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.resultNotFound.rawValue, userInfo: nil))
        }
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(result)
        response.requestCompletedCallback()
    }
}