//
//  EvaluateTest.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/10/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import XCTest

@testable import rcmdServer

let testSuiteCount = 1000

let dataManager = DataManager.sharedInstance
let filter = UserUserCollaborating()

let users = dataManager.users
let movies = dataManager.movies

class EvaluateTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRMSE() {
        var count = 0
        var result = 0.0
        if let users = users, movies = movies {
            for u in users {
                // calculate predicted rating for user `u`
                filter.normalizatoinPredictedRatingForUser(u, peoples: users, movies: movies)
                for (movie, rating) in u.ratings {
                    if let predicted = u.predictions[movie] where predicted != -1 { // ignore invalid predicted ratings
                        result += pow(rating - predicted, 2)
                        print("u:\(u.ID), movie: \(movie.id), rating:\(rating), predicted:\(predicted), pow:\(result)")
                        count += 1
                    }
                    
                    if count > testSuiteCount {
                       break
                    }
                }
                
                if count > testSuiteCount {
                   break
                }
            }
        }
        
        let r = sqrt(result / Double(count))
       print ("result:\(r)")
    }
    
    func testMAE() {
        var count = 0
        var result = 0.0
        if let users = users, movies = movies {
            for u in users {
                // calculate predicted rating for user `u`
                filter.normalizatoinPredictedRatingForUser(u, peoples: users, movies: movies)
                for (movie, rating) in u.ratings {
                    if let predicted = u.predictions[movie] where predicted != -1 { // ignore invalid predicted ratings
                        result += fabs(rating - predicted)
                        print("u:\(u.ID), movie: \(movie.id), rating:\(rating), predicted:\(predicted), pow:\(result)")
                        count += 1
                    }
                    
                    if count > testSuiteCount {
                       break
                    }
                }
                
                if count > testSuiteCount {
                   break
                }
            }
        }
        
        let r = result / Double(count)
       print ("result:\(r)")
    }

}
