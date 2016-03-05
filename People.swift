//
//  People.swift
//  recommederSystermExercise
//
//  Created by Song Zhou on 1/23/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation

typealias rating = [Movie: Score]
typealias correlation = (PeopleID, Double)

class People {
    var ID = 0
    var ratings = rating()
    var predictions = rating()
    var correlations = [correlation]()
    
    init(ID id:Int) {
       self.ID = id
    }
}