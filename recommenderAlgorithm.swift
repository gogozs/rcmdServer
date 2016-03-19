//
//  recommenderAlgorithm.swift
//  recommederSystermExercise
//
//  Created by Song Zhou on 1/16/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation

// MARK: - todo: dirty hack, need refactoring
typealias correlationValue = Double
typealias ratingAVG =  Double

class UserUserCollaborating {
    func pearsonCorrelationForUser(a: People, userB b: People, itemRange range: Range<Int>) -> Double {
        var r :Double = 0.0
    
//        let ratingValuesForSortedMovieNames: (People) -> [Double] = { p in
//            p.ratings.keys.sort {
//                $0.id > $1.id
//            }.map {
//                p.ratings[$0]!
//            }
//        }
        
//        let ratingsA = ratingValuesForSortedMovieNames(a)
//        let ratingsB = ratingValuesForSortedMovieNames(b)
        
        let keys = Set(a.ratings.keys).intersect(Set(b.ratings.keys))
        if keys.count == 0 {
            return 0
        }
        
        let validRatingsA = keys.sort{
            $0.id < $1.id
            }.map {
                a.ratings[$0]!
            }
        
        let validRatingsB = keys.sort {
            $0.id < $1.id
            }.map {
                b.ratings[$0]!
            }
        
        
//        for i in 0 ..< keys.count {
//            if ratingsA[i] > -1 && ratingsB[i] > -1 {
//                validRatingsA.append(ratingsA[i])
//                validRatingsB.append(ratingsB[i])
//                
//            }
//        }
        
//        r = pearsonCorrelation(arrayA: validRatingsA, arrayB: validRatingsB);
        
        return r;
        
    }
    
    // return top 5 most correlatd user IDs
    func top5UsersWith(user u: People, users: [People], movies: [Movie]) -> ([correlation]) {
        let targetPeople = u
    
        for people in users {
            targetPeople.correlations.append(
                (people.ID, pearsonCorrelationForUser(targetPeople, userB: people, itemRange: 0..<min(people.ratings.count, targetPeople.ratings.count)))
            )
        }
        let correlations = targetPeople.correlations.sort { $0.1 > $1.1}
    
        // omit self(0)
        return Array(correlations[1...5])
    }
    
    func nonNormalizationPredictedRatingForUser(u: People, withCorrelations correlations: [correlation], movies: [Movie], users: [People]) {
        for movie in movies {
            var sumOfWeightedRatings = 0.0
            var weights = 0.0
            for c in correlations {
                let p = users.filter {$0.ID == c.0}.first!
                let rating = p.ratings[movie]!
                let weight = rating > 0 ? c.1: 0.0
    
                sumOfWeightedRatings += rating * weight
                weights += weight
    
            }
            u.predictions[movie] = sumOfWeightedRatings / weights
        }
    }
    
    func normalizationPredictedRatingForUser(u: People, withCorrelations correlations: [correlation], peoples: [People], movies: [Movie]) {
        var correlationPeoples = [(People, ratingAVG, correlationValue)]()
        for c in correlations {
            let p = peoples.filter {$0.ID == c.0}.first!
    
            let validRatings: [Double] = p.ratings.values.filter { $0 > 0 }
//            let ratingAvg = avg(validRatings)
    
//            correlationPeoples.append((p, ratingAvg, c.1))
        }
    
        for movie in movies {
            var sumOfWeightedRatings = 0.0
            var weights = 0.0
            for p in correlationPeoples {
                let rating = p.0.ratings[movie]!
                let weight = rating > 0 ? p.2: 0.0
    
                sumOfWeightedRatings += (rating - p.1) * weight
                weights += weight
                
            }
//            u.predictions[movie] = sumOfWeightedRatings / weights + avg(u.ratings.values.filter {$0 > 0})
        }
    }
    
    
}
