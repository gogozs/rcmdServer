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
                resultStr = "request variables format is not correct"
            }
        } else {
            resultStr = "you need provid item id"
        }
        
        if let i = item {
            let item = [
                movieIDKey: i.id,
                movieNameKey: i.name,
                movieGenreKey: i.genre ?? 0,
                movieReleaseDateKey: i.release_data ?? ""
            ]
            
            resultStr = String.JSONStrFromObject(item)
        } else {
           resultStr = "can not get movie from database"
        }
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}