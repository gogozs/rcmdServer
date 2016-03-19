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

enum Occupation: String {
    case Administrator, Doctor, Educator, Engineer, Entertainment,
    Executive, Healthcare, Homemaker, Lawyer, Librarian,
    Marketing, None, Other, Programmer, Retired,
    Salesman, Scientist, Student, Technician, Writer
    
    static let allValues = [
        Administrator, Doctor, Educator, Engineer, Entertainment,
        Executive, Healthcare, Homemaker, Lawyer, Librarian,
        Marketing, None, Other, Programmer, Retired,
        Salesman, Scientist, Student, Technician, Writer
    ]
}

func OccupationWithString(s: String) -> Occupation {
    for e in Occupation.allValues {
        if e.rawValue == s.capitalizedString {
           return e
        }
    }
    
    return Occupation.None
}

enum Gender: Int {
    case Unknown = 0, Male, Female
    
    static let allValues = [
        Unknown, Male, Female
    ]
}

func GenderWithInt(s: Int) -> Gender {
    for g in Gender.allValues {
        if g.rawValue == s {
            return g
        }
    }
    
    return Gender.Unknown
}

// MARK: - Equal
func ==(lhs: People, rhs: People) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class People: Hashable {
    let ID: Int
    var userName: String?
    var password: String?
    var occupation = Occupation.None
    var gender = Gender.Unknown
    var age = 0
    var zipCode = 0
    
    var ratings = rating() // original ratings
    var predictions = rating() // predicted ratings
    var correlations = [correlation]() // correlation with other user
    
    init (id: Int) {
        self.ID = id;
    }
    
    // MARK: - Hash
    var hashValue: Int {
        get {
            return self.ID
        }
    }
    
    var description: String {
        return "\(self.ID): \(self.userName), \(self.password), \(self.occupation), \(self.gender), \(self.age), \(self.zipCode)"
    }
    
}