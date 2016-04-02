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
    /// Only calculate pearson correlation on intersect of two person rated items
    func pearsonCorrelationForUser(a: People, userB b: People) -> Double {
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
        
        if b.ID == 418 {
            
        }
        var commonMovieFactor = 1.0
        let keys = Set(a.ratings.keys).intersect(Set(b.ratings.keys))
        
        if keys.count == 0 {
            return 0.0
        }
        
        if keys.count < 5 {
            commonMovieFactor = Double(keys.count) / 5.0
        }
        
//        print("common movies count: \(keys.count), People ID: \(a.ID) - \(b.ID)")
        
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
        
        r = pearsonCorrelation(arrayA: validRatingsA, arrayB: validRatingsB) * commonMovieFactor;
        
        return r;
        
    }
    
    // return top 5 most correlatd user IDs
    func top5UsersWith(user u: People, users: [People], movies: [Movie]) -> (correlation) {
        let targetPeople = u
    
        var correlations = targetPeople.correlations
        for people in users {
            correlations[people] = pearsonCorrelationForUser(targetPeople, userB: people)
        }
        let correlationsKeys = Array(correlations.keys).sort {
            correlations[$0] > correlations[$1]
        }
            
    
        // omit self(0)
        var r = correlation()
        for i in 1...5 {
            let key = correlationsKeys[i]
            r[key] = correlations[key]!
        }
        
        return r
    }
    
    func nonNormalizationPredictedRatingForUser(u: People, withCorrelations correlations: correlation, movies: [Movie], users: [People]) {
        for movie in movies {
            var sumOfWeightedRatings = 0.0
            var weights = 0.0
            for (people, correlation) in correlations {
                if let rating = people.ratings[movie] {
                    sumOfWeightedRatings += rating * correlation
                    weights += correlation
                }
            }
            
            // if no one in correlations with user u has rated this movie
            if weights == 0 {
                u.predictions[movie] = 0
            } else {
                u.predictions[movie] = sumOfWeightedRatings / weights
            }
        }
    }
    
    func normalizationPredictedRatingForUser(u: People, withCorrelations correlations: correlation, peoples: [People], movies: [Movie]) {
        // calculate correlation with user u users avg rating
        for (p, _) in correlations {
            self.calculateAVGRatingForUser(p)
        }
        
        self.calculateAVGRatingForUser(u)
        
        for movie in movies {
            var sumOfWeightedRatings = 0.0
            var weights = 0.0
            for (people, correlation) in correlations {
                if let rating = people.ratings[movie] {
                    sumOfWeightedRatings += (rating - people.avgRating) * correlation
                    weights += correlation
                }
            }
            
            // if no one in correlations with user u has rated this movie
            if weights == 0 {
                u.predictions[movie] = 0
            } else {
                u.predictions[movie] = sumOfWeightedRatings / weights + u.avgRating
            }
        }
        
    }
    
    func calculateAVGRatingForUser(u: People) {
        u.avgRating = avg(Array(u.ratings.values))
    }
    
    
}
