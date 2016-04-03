//
//  ItemDetailHandler.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/3/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib
import PostgreSQL

class ItemDetailHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        var resultStr = ""
        
        let dataManager = DataManager.sharedInstance
        var item: Movie?
        if let itemIDStr = request.urlVariables[itemIDKey] {
            if let itemID = Int(itemIDStr) {
                item = dataManager.getMovieWithID(itemID)
            } else {
                resultStr = String.JSONStrErrorWithError(NSError.init(domain: errorDomain, code: NetworkError.requestFormatError.rawValue, userInfo: nil))
            }
        } else {
            resultStr = String.JSONStrErrorWithError(NSError.init(domain: errorDomain, code: NetworkError.requestVariablesNotFound.rawValue, userInfo: nil))
        }
        
        if let i = item {
            resultStr = String.JSONStrFromObject(i.movieResponse)
        } else {
            resultStr = String.JSONStrErrorWithError(NSError.init(domain: errorDomain, code: NetworkError.resultNotFound.rawValue, userInfo: nil))
        }
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}