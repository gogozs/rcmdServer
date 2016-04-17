//
//  MovieSearchHandler.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/3/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib

class MovieSearchHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        print("\(request.requestURI())")
        var resultStr = ""
        let dataManager = DataManager.sharedInstance
        
        if let keyword = request.urlVariables[itemNameKey] {
            dataManager.searchMovie(keyword)
            if let r = dataManager.searchedMovies {
                var jsonArray = [[String: AnyObject]]()
                for (_, movie) in r {
                    jsonArray.append(movie.movieResponse)
                }
                resultStr = String.JSONStrFromObject(jsonArray)
            } else {
                resultStr =  String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.resultNotFound.rawValue, userInfo: nil))
            }
        } else {
            resultStr =  String.JSONStrErrorWithError(NSError.init(domain: NetworkErrorDomain, code: NetworkError.requestFormatError.rawValue, userInfo: nil))
        }
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}