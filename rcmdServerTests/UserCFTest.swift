//
//  UserCFTest.swift
//  rcmdServer
//
//  Created by Song Zhou on 3/6/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import XCTest

@testable import rcmdServer
@testable import PerfectLib
@testable import PostgreSQL

class UserCFTest: XCTestCase {
    var pgsl: PGConnection!
    var resultStr: String = ""
    
    var users = [Int: People]()
    var movies = [Int: Movie]()
    
    override func setUp() {
        super.setUp()
        
        pgsl = PostgreSQL.PGConnection()
        
        pgsl.connectdb(connectInfo)
        
        resultStr = pgsl.errorMessage()
        
        testConstructUserModel()
        testConstructMovieModel()
        testConstructRatingModel()
        
    }
    
    func testConstructRatingModel() {
        let ratingResult = pgsl.exec("select * from rating")
        let ratingStatus = ratingResult.status()
        
        if ratingStatus == .CommandOK || ratingStatus == .TuplesOK {
            if ratingResult.numFields() > 0 && ratingResult.numTuples() > 0 {
//
                XCTAssert(ratingResult.getFieldInt(0, fieldIndex: 0) == 1, "get user_id failed")
                XCTAssert(ratingResult.getFieldInt(0, fieldIndex: 1) == 61, "get movie_id failed")
                XCTAssert(ratingResult.getFieldInt(0, fieldIndex: 2) == 4, "get rating failed")
                
                for i in 0 ..< ratingResult.numTuples() {
                    let u = ratingResult.getFieldInt(i, fieldIndex: 0)
                    let m = ratingResult.getFieldInt(i, fieldIndex: 1)
                    let r = ratingResult.getFieldDouble(i, fieldIndex: 2)
                    
                    users[u]!.ratings[movies[m]!] = r
                }
            }
        }
    }
    
    func testConstructUserModel() {
        let result = pgsl.exec("select * from \"user\"")
        let s = result.status()
        if s == .CommandOK || s == .TuplesOK {
            if result.numFields() > 0 && result.numTuples() > 0 {
                for i in 0..<result.numTuples() {
                    let p = People(id: result.getFieldInt(i, fieldIndex: 0))
                    users[p.ID] = p
                
                }
            }
            XCTAssert(users.count == 925, "get user count failed")
        }
    }
    
    func testConstructMovieModel() {
        let result = pgsl.exec("select * from movie")
        let s = result.status()
        if s == .CommandOK || s == .TuplesOK {
            if result.numFields() > 0 && result.numTuples() > 0 {
                for i in 0..<result.numTuples() {
                    let m = Movie(id: result.getFieldInt(i, fieldIndex: 0))
                    movies[m.id] = m
                
                }
            }
            XCTAssert(movies.count == 1594, "get movie count failed")
        }
    }
    
    func testTop5Users() {
        let filter = UserUserCollaborating()
        let correlaitons = filter.top5UsersWith(user: users[1]!, users: Array(users.values), movies: Array(movies.values))
        XCTAssert(correlaitons.count == 5, "top 5 users count is not corrected")
    }
}