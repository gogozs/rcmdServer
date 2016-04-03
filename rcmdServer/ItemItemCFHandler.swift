//
//  ItemItemCFHandler.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/3/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib
import PostgreSQL

class ItemItemCFHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        var resultStr = ""
        
        let dataManager = DataManager.sharedInstance
        
        var item: Movie?
        var N: Int?
        if let itemIDStr = request.urlVariables[itemIDKey], let NStr = request.urlVariables[itemCountKey] {
            if let itemID = Int(itemIDStr), let NInt = Int(NStr){
                item = dataManager.getMovieWithID(itemID)
                N = NInt
            } else {
                resultStr = "request variables format is not correct"
            }
        } else {
            resultStr = "you need provid item id and N count"
        }
        
        if let i = item, let N = N{
            if let users = dataManager.users, let movies = dataManager.movies {
                let filter = ItemItemCF()
                let results = filter.topNSimilarMoviesWithMovie(i, N: N, movies: movies, users: users)
                
                var jsonArray = [[String: AnyObject]]()
                for (movie, similarity) in results {
                    let item = [movieIDKey: movie.id,
                                similarityKey: similarity]
                    jsonArray.append(item as! [String: AnyObject])
                }
                
//                do {
//                    let data = try NSJSONSerialization.dataWithJSONObject(jsonArray, options: .PrettyPrinted)
//                    resultStr = String.init(data: data, encoding: NSUTF8StringEncoding)!
//                } catch {
//                    
//                }
                resultStr = String.JSONStrFromObject(jsonArray)
            } else {
                resultStr = "can not get users & movies form database"
            }
        } else {
            resultStr = "can not find requested item"
        }
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}
