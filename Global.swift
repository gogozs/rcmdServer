//
//  Global.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/3/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation

// ItemItemCF
let ratedUserThresholdPercent = 0.005
//let mostSimilarMoviesCount = 20


// MARK: - Request key
let itemIDKey = "item_id"
let itemNameKey = "item_name"
let itemCountKey = "item_count"

let userIDKey = "user_id"
let ratingKey = "rating"
let countKey = "count"

// MARK: - Response key
// Movie
let movieIDKey = "movie_id"
let movieNameKey = "movie_name"
let movieGenreKey = "movie_genre"
let movieReleaseDateKey = "release_date"

let similarityKey = "similarity"

// error
let NetworkErrorDomain = "me.songzhou.RCMD.NetworkErrorDomain"
let DatabaseErrorDomain = "me.songzhou.RCMD.DatabaseErrorDomain"

enum NetworkError: Int {
    case requestFormatError
    case requestVariablesNotFound
    case requestVariablesNotValid
    case resultNotFound
}

enum DatabaseError: Int {
    case queryFailed
}