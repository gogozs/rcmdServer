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
        let pgsl = PostgreSQL.PGConnection()
        pgsl.connectdb(connectInfo)
        
        var resultStr = pgsl.errorMessage()
        
        var users = [Int: People]()
        var movies = [Int: Movie]()
        
        if pgsl.status() == .Bad {
        } else {
            
            let result = pgsl.exec("select * from \"user\"")
            let s = result.status()
            if s == .CommandOK || s == .TuplesOK {
                if result.numFields() > 0 && result.numTuples() > 0 {
                    for i in 0..<result.numTuples() {
                        let p = People(id: result.getFieldInt(i, fieldIndex: 0))
                        users[p.ID] = p
                    
                    }
                }
            }
            
            let movieResult = pgsl.exec("select * from movie")
            let movieStatus = movieResult.status()
            
            if movieStatus == .CommandOK || movieStatus == .TuplesOK {
                if movieResult.numFields() > 0 && movieResult.numTuples() > 0 {
                    for i in 0 ..< movieResult.numTuples() {
                        let m = Movie(id: movieResult.getFieldInt(i, fieldIndex: 0))
                        movies[m.id] = m
                    }
                }
            }
            
            let ratingResult = pgsl.exec("select * from rating where user_id = 1")
            let ratingStatus = ratingResult.status()
            
            if ratingStatus == .CommandOK || ratingStatus == .TuplesOK {
                if ratingResult.numFields() > 0 && ratingResult.numTuples() > 0 {
                    for i in 0 ..< ratingResult.numTuples() {
                        let u = ratingResult.getFieldInt(i, fieldIndex: 0)
                        let m = ratingResult.getFieldInt(i, fieldIndex: 1)
                        let r = ratingResult.getFieldDouble(i, fieldIndex: 2)
                        resultStr += "\(u), \(m), \(r)\n"
                        users[u]!.ratings[movies[m]!] = r
                    }
                }
            }
            
        }
        
//        for u in users.enumerate() {
//            for m in u.element.1.ratings.enumerate() {
//                resultStr += "uid: \(u.element.0), ratings: (\(m.element.0): \(m.element.1))\n"
//            }
//        }
        
        let p = users[1]
        
        print("\(p?.ratings[movies[3]!])")
        
        pgsl.close()
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}