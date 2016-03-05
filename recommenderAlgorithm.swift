//
//  recommenderAlgorithm.swift
//  recommederSystermExercise
//
//  Created by Song Zhou on 1/16/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation

class UserUserCollaborating {
    func pearsonCorrelationForUser(a: People, userB b: People, itemRange range: Range<Int>) -> Double {
        var r :Double = 0.0
    
        let ratingValuesForSortedMovieNames: (People) -> [Double] = { p in
            p.ratings.keys.sort {
                $0.name > $1.name
            }.map {
                p.ratings[$0]!
            }
        }
        
        let ratingsA = ratingValuesForSortedMovieNames(a)
        let ratingsB = ratingValuesForSortedMovieNames(b)
        
        var validRatingsA = [Double]()
        var validRatingsB = [Double]()
        
        for i in range.startIndex..<range.endIndex {
            if ratingsA[i] > -1 && ratingsB[i] > -1 {
                validRatingsA.append(ratingsA[i])
                validRatingsB.append(ratingsB[i])
                
            }
        }
        
        r = pearsonCorrelation(arrayA: validRatingsA, arrayB: validRatingsB);
        
        return r;
        
    }
    
    
}
