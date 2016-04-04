//
//  UserUserCFHandler.swift
//  rcmdServer
//
//  Created by Song Zhou on 3/5/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib
import PostgreSQL

class userUserCollaborativeFilterHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        var resultStr = ""
        
        let dataManager = DataManager.sharedInstance
        
        let filter = UserUserCollaborating()
        
        var user: People?
        if let userIDStr = request.urlVariables[userIDKey] {
            if let userID = Int(userIDStr) {
                user = dataManager.getUserWithUserID(userID)
            } else {
                resultStr = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.requestFormatError.rawValue, userInfo: nil))
            }
        } else {
            resultStr = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.requestVariablesNotFound.rawValue, userInfo: nil))
        }
        
        if let u = user {
            if let users = dataManager.users, let movies = dataManager.movies {
                let correlations = filter.top5UsersWith(user: u, users: users, movies: movies)
                filter.normalizationPredictedRatingForUser(u, withCorrelations: correlations, peoples: users, movies: movies)
                
                let predictions = u.predictions
                
                let predictedKeys =  Array(predictions.keys)
                let sortedMovies = predictedKeys.sort{predictions[$0] > predictions[$1]}
                
                var jsonArray = [[String: AnyObject]]()
                for i in 0...4 {
                    let movie = sortedMovies[i]
                    let item = ["id": movie.id,
                                "name": movie.name,
                                "genre": movie.genre ?? 0,
                                "release_date": movie.release_data ?? "",
                                "prediction": predictions[movie] ?? 0.0
                    ]
                    jsonArray.append(item as! [String : AnyObject])
                }
                
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(jsonArray, options: .PrettyPrinted)
                    resultStr = String.init(data: data, encoding: NSUTF8StringEncoding)!
                } catch {
                }
            } else {
                resultStr = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.resultNotFound.rawValue, userInfo: nil))
            }
            
        } else {
                resultStr = String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.resultNotFound.rawValue, userInfo: nil))
        }
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}