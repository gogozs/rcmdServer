//
//  Movie.swift
//  recommederSystermExercise
//
//  Created by Song Zhou on 1/16/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation

typealias Score = Double
typealias PeopleID = Int

// MARK: - Equal
func ==(lhs: Movie, rhs: Movie) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Movie: Hashable, CustomStringConvertible {
    var name: String = ""
    var id: Int?
    var imdb_url: String = ""
    var genre: Int?
    var release_data: String = ""
    
    init(MovieName name: String) {
        self.name = name
    }
    
    convenience init() {
        self.init(MovieName: "")
    }
    
    // MARK: - Hash
    var hashValue: Int {
        get {
            return self.name.hashValue
        }
    }
    
    var description: String {
        return self.name
    }
    
}


