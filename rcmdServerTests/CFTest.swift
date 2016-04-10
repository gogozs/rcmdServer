//
//  CFTest.swift
//  rcmdServer
//
//  Created by Song Zhou on 3/6/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import XCTest

@testable import rcmdServer
@testable import PerfectLib
@testable import PostgreSQL

class CFTest: XCTestCase {
    var pgsl: PGConnection!
    var resultStr: String = ""
    
    var users = [Int: People]()
    var movies = [Int: Movie]()
    
    lazy var itemItemCFFilter = ItemItemCF()
    
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
                XCTAssert(ratingResult.numTuples() == 93094, "number of ratings nor correct")
                
                for i in 0 ..< ratingResult.numTuples() {
                    let m = ratingResult.getFieldInt(i, fieldIndex: 0)
                    let u = ratingResult.getFieldInt(i, fieldIndex: 1)
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
    
    func testNonNormalizationPredictedRating() {
        let filter = UserUserCollaborating()
        let correlaitons = filter.top5UsersWith(user: users[1]!, users: Array(users.values), movies: Array(movies.values))
        
        filter.nonNormalizationPredictedRatingForUser(users[1]!, withCorrelations: correlaitons, movies: Array(movies.values), users: Array(users.values))
    }
    
    func testNormalizationPredictedRating() {
        let filter = UserUserCollaborating()
        let correlaitons = filter.top5UsersWith(user: users[1]!, users: Array(users.values), movies: Array(movies.values))
        
        filter.normalizationPredictedRatingForUser(users[1]!, withCorrelations: correlaitons, peoples: Array(users.values), movies: Array(movies.values))
        
        // test
        top5PredictedMoviesForUser1()
        
    }
    
    func testNormalizationPredcitedRatingWithDefaultCorrrelation() {
        let filter = UserUserCollaborating()
        filter.normalizatoinPredictedRatingForUser(users[1]!, peoples: Array(users.values), movies: Array(movies.values))
        // test
        top5PredictedMoviesForUser1()
    }
    
    
    func testItemSimilarity() {
        // compare God Father
        let godFather = movies[127]!
        let s = itemItemCFFilter.itemSimilarity(godFather, movie2: movies[187]!, users: Array(users.values))
        XCTAssert(fabs(s - 0.771) < 0.01)
        
    }
    
    func testItemItemCF() {
        let godFather = movies[127]!
        
        let r = itemItemCFFilter.predictingRating(users[1]!, forItem: godFather, movies: Array(movies.values), users: Array(users.values))
        // result: 4.3422518850171405
        XCTAssert(fabs(r - 4.34225) < 0.01)
        
//        let predictedMovies = filter.predictedTopNMovies(withUser: users[1]!, N: 20, movies: Array(movies.values), users: Array(users.values))
//        for (movie, prediction) in predictedMovies {
//            print("\(movie): \(prediction)")
//        }
    }
    
    func testTopNSimilarMovies() {
        let godFather = movies[127]!
        let r = itemItemCFFilter.topNSimilarMoviesWithMovie(godFather, N: 20, movies: Array(movies.values), users: Array(users.values))
        for (movie, similarity) in r {
            print("\(movie.id): \(similarity)")
        }
    }
    
    // MARK: - Private Methods
    func top5PredictedMoviesForUser1() {
        let predictions = users[1]!.predictions
        let predictedKeys =  Array(predictions.keys)
        let sortedMovies = predictedKeys.sort{predictions[$0] > predictions[$1]}
        
        // test top 5 predicted movies IDs are correct
        XCTAssert(sortedMovies[0].id == 902)
        XCTAssert(sortedMovies[1].id == 242)
        XCTAssert(sortedMovies[2].id == 898)
        XCTAssert(sortedMovies[3].id == 270)
        XCTAssert(sortedMovies[4].id == 269)
    }
}