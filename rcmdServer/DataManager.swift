//
//  DataManager.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/2/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PostgreSQL

class DataManager {
    static let sharedInstance = DataManager()
    
    var pgsl: PGConnection!
    var resultStr: String = ""
    
    var users: [People]?
    var movies: [Movie]?
    var searchedMovies = [Int: Movie]?()
    var topRatedMovies: [String: Score]?
    
    private var usersDict = [Int: People]()
    private var moviesDict = [Int: Movie]()
    
    init() {
        pgsl = PostgreSQL.PGConnection()
        
        pgsl.connectdb(connectInfo)
        
        resultStr = pgsl.errorMessage()
        
        self.constructUserModel()
        self.constructMovieModel()
        self.constructRatingModel()
    }
    
    // MARK: - Construct Model
    private func constructRatingModel() {
        let ratingResult = pgsl.exec("select * from rating")
        let ratingStatus = ratingResult.status()
        
        if ratingStatus == .CommandOK || ratingStatus == .TuplesOK {
            if ratingResult.numFields() > 0 && ratingResult.numTuples() > 0 {
                
                for i in 0 ..< ratingResult.numTuples() {
                    let m = ratingResult.getFieldInt(i, fieldIndex: 0)
                    let u = ratingResult.getFieldInt(i, fieldIndex: 1)
                    let r = ratingResult.getFieldDouble(i, fieldIndex: 2)
                    
                    usersDict[u]!.ratings[moviesDict[m]!] = r
                }
            } else {
            }
        }
    }
    
    private func constructUserModel() {
        let result = pgsl.exec("select * from \"user\"")
        let s = result.status()
        if s == .CommandOK || s == .TuplesOK {
            if result.numFields() > 0 && result.numTuples() > 0 {
                for i in 0..<result.numTuples() {
                    let p = People(id: result.getFieldInt(i, fieldIndex: 0))
                    usersDict[p.ID] = p
                    
                }
                
                users = Array(usersDict.values)
            } else {
                users = nil
            }
        } else {
            users = nil
        }
    }
    
    private func constructMovieModel() {
        let result = pgsl.exec("select * from movie")
        let s = result.status()
        if s == .CommandOK || s == .TuplesOK {
            if result.numFields() > 0 && result.numTuples() > 0 {
                moviesDict = self.constructMovie(result)
                movies = Array(moviesDict.values)
            } else {
                movies = nil
            }
        } else {
            movies = nil
        }
    }
    
    // MARK: - Construct model from PGResult
    private func constructMovie(result: PGResult) -> [Int: Movie] {
        var moviesDict = [Int: Movie]()
        for i in 0..<result.numTuples() {
            let m = Movie(id: result.getFieldInt(i, fieldIndex: 0))
            m.name = result.getFieldString(i, fieldIndex: 1)
            m.release_data = result.getFieldString(i, fieldIndex: 2)
            m.genre = result.getFieldInt(i, fieldIndex: 4)
            
            moviesDict[m.id] = m
            
        }
        return moviesDict
    }
    
    
    // MARK: - Get User/Movie
    func getUserWithUserID(id: Int) -> People? {
        return usersDict[id]
    }
    
    func getMovieWithID(id: Int) -> Movie? {
        return moviesDict[id]
    }
    
    func getUserRatingWithMovieID(id: Int, userID: Int) -> Score? {
        if let user = usersDict[userID], let movie = moviesDict[id] {
           return user.ratings[movie]
        }
        
        return nil
    }
    
    // MARK: - Feature
    /// Search movies with keyword
    func searchMovie(keyword: String) {
        let select = "select * from movie where lower(name) like '%\(keyword)%'"
        let result = pgsl.exec(select)
        let s = result.status()
        if s == .CommandOK || s == .TuplesOK {
            if result.numFields() > 0 && result.numTuples() > 0 {
                searchedMovies = self.constructMovie(result)
            } else {
                searchedMovies = nil
            }
        } else {
            searchedMovies = nil
        }
    }
    
    func topRatedMovies(N: Int) {
        let select = "select movie_id, avg(rating) from rating group by movie_id order by avg(rating) desc limit \(N)"
        print("\(select)")
        let result = pgsl.exec(select)
        let s = result.status()
        if s == .CommandOK || s == .TuplesOK {
            if result.numFields() > 0 && result.numTuples() > 0 {
                var dict = [String: Score]()
                print("\(result.numTuples())")
                for i in 0 ..< result.numTuples() {
                    dict[result.getFieldString(i, fieldIndex: 0)] = result.getFieldDouble(i, fieldIndex: 1)
                }
                topRatedMovies = dict
            } else {
                topRatedMovies = nil
            }
        } else {
                topRatedMovies = nil
        }
    }
    
   
}