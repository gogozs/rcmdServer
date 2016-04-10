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
    
        var commonMovieFactor = 1.0
        let keys = Set(a.ratings.keys).intersect(Set(b.ratings.keys))
        
        if keys.count == 0 {
            return 0.0
        }
        
        if keys.count < 5 {
            commonMovieFactor = Double(keys.count) / 5.0
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
        
        r = pearsonCorrelation(arrayA: validRatingsA, arrayB: validRatingsB) * commonMovieFactor;
        
        return r.isNaN ? 0.0 : r;
        
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
            if weights == 0.0 {
                u.predictions[movie] = -1.0
            } else {
                u.predictions[movie] = sumOfWeightedRatings / weights + u.avgRating
            }
        }
        
    }
    
    /// convience method with top 5 correlations
    func normalizatoinPredictedRatingForUser(u: People, peoples: [People], movies: [Movie]) {
        let correlaitons = self.top5UsersWith(user: u, users: peoples, movies: movies)
        self.normalizationPredictedRatingForUser(u, withCorrelations: correlaitons, peoples: peoples, movies: movies)
    }
    
    
}

class ItemItemCF {
    // MARK: - Similarity
    /// Calculate similarity between two movies
    func itemSimilarity(movie1: Movie, movie2: Movie, users: [People]) -> Double {
        let ratedUserThreshold = Int(ceil(Double(users.count) * ratedUserThresholdPercent))
        
       // find users who both rated movie1 and movie2
       var ratedUsers = [People]()
        for user in users {
            if user.ratings[movie1] != nil && user.ratings[movie2] != nil {
               ratedUsers.append(user)
            }
        }
        
        guard ratedUsers.count >= ratedUserThreshold else {
            return 0.0
        }
        // Calculate weighted avg
        var sumOfNomalizedRatings = 0.0
        var weightsOf1 = 0.0
        var weightsOf2 = 0.0
        
        for user in ratedUsers {
            let r1 = user.ratings[movie1]! - user.avgRating
            let r2 = user.ratings[movie2]! - user.avgRating
            
            sumOfNomalizedRatings +=  r1 * r2
            weightsOf1 += pow(r1, 2)
            weightsOf2 += pow(r2, 2)
            
        }
        
        guard weightsOf1 != 0.0 && weightsOf2 != 0.0 else {
            return 0.0
        }
        
        return sumOfNomalizedRatings / (sqrt(weightsOf1) * sqrt(weightsOf2))
    }
    
    /// Return movie similarities with target movie
    private func similarMoviesWithMovie(movie: Movie, movies: [Movie], users: [People]) -> [Movie: Double] {
        var result = [Movie: Double]()
        
        for m in movies {
            if m != movie { // omit compare self
               result[m] = self.itemSimilarity(movie, movie2: m, users: users)
            }
        }
        
        return result
    }
    
    /// Find most similar movies, limit 20
    private func top20SimilarMoviesWithMovie(movie: Movie, movies: [Movie], users: [People]) -> [Movie: Double] {
       return self.topNSimilarMoviesWithMovie(movie, N: 20, movies: movies, users: users)
    }
    
    /// Find most similar movies, limit N
    func topNSimilarMoviesWithMovie(movie: Movie, N: Int, movies: [Movie], users: [People]) -> [Movie: Double] {
        let movieSimilarities = self.similarMoviesWithMovie(movie, movies: movies, users: users)
        
        let sortedMovies = Array(movieSimilarities.keys.sort {movieSimilarities[$0] > movieSimilarities[$1]})
        
        let limitMovies = Array(sortedMovies[0 ..< N])
        
        var result = [Movie: Double]()
        for m in limitMovies {
            result[m] = movieSimilarities[m]
        }
        
        return result
    }
  
    // MARK:- Similarity within taget user
    /// Find most similar movies with target movie that user has rated, at most limit 20
    /// @note return count may less than 20
    private func similar20MoviesUserRated(u: People, movie: Movie, movies: [Movie], users: [People]) -> [Movie: Double] {
        return self.similarMoviesUserRated(u, movie: movie, N: 20, movies: movies, users: users)
    }
    
    /// Find most similar movies that user has rated, at most limit N
    private func similarMoviesUserRated(u: People, movie: Movie, N: Int, movies: [Movie], users: [People]) -> [Movie: Double] {
        // Find movies with similarity that user has rated
        let movieSimilarities = self.similarMoviesWithMovie(movie, movies: movies, users: users)
        
        let ratedMovies = Array(u.ratings.keys)
        
        var ratedSimilarites = [Movie: Double]()
        
        for movie in ratedMovies {
            ratedSimilarites[movie] = movieSimilarities[movie]
        }
        
        // Limit by similarity at most N
        var sortedMovies = Array(ratedSimilarites.keys.sort {ratedSimilarites[$0] > ratedSimilarites[$1]})
        if sortedMovies.count > N {
            sortedMovies = Array(sortedMovies[0 ..< N])
        }
        
        // Construct result dict
        var result = [Movie: Double]()
        for m in sortedMovies{
            result[m] = ratedSimilarites[m]
        }
        
        return result
        
    }
  
    
    // MARK: - Predicting
    /// Predicting user `u` rating with target movie `i`
    func predictingRating(u: People, forItem i: Movie, movies: [Movie], users: [People]) -> Double {
        guard u.ratings.count >= 20 else {
            return -1.0
        }
        
       let topMovies = self.similar20MoviesUserRated(u, movie: i, movies: movies, users: users)
        
        var sumOfWeightedRatings = 0.0
        var weights = 0.0
        
        for (movie, similarity) in topMovies {
            sumOfWeightedRatings += u.ratings[movie]! * similarity
            weights += fabs(similarity)
        }
        
        guard weights != 0.0 else {
            return -1.0
        }
        
        return sumOfWeightedRatings / weights
        
    }
    
    /// Predicting top N movies for user `u`, exclude rated movies
    /// @note result count may less than N
    /// @deprected cost too much
    func predictedTopNMovies(withUser u: People, N: Int, movies: [Movie], users: [People]) -> [Movie: Double] {
       let notRatedMovies = Set(movies).subtract(Set(u.ratings.keys))
        
        var predictedMovies = [Movie: Double]()
        for movie in notRatedMovies {
            predictedMovies[movie] = self.predictingRating(u, forItem: movie, movies: movies, users: users)
        }
        
        let sortedMovies = predictedMovies.keys.sort {predictedMovies[$0] > predictedMovies[$1]}
        
        let limitedMovies = Array(sortedMovies[0 ..< N])
        
        var results = [Movie: Double]()
        
        for m in limitedMovies {
            results[m] = predictedMovies[m]
        }
        
        return results
        
    }
}
