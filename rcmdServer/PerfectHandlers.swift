//
//  PerfectHandlers.swift
//  URL Routing
//
//  Created by Kyle Jessup on 2015-12-15.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU Affero General Public License as
//	published by the Free Software Foundation, either version 3 of the
//	License, or (at your option) any later version, as supplemented by the
//	Perfect Additional Terms.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU Affero General Public License, as supplemented by the
//	Perfect Additional Terms, for more details.
//
//	You should have received a copy of the GNU Affero General Public License
//	and the Perfect Additional Terms that immediately follow the terms and
//	conditions of the GNU Affero General Public License along with this
//	program. If not, see <http://www.perfect.org/AGPL_3_0_With_Perfect_Additional_Terms.txt>.
//

import PerfectLib

// This is the function which all Perfect Server modules must expose.
// The system will load the module and call this function.
// In here, register any handlers or perform any one-time tasks.
public func PerfectServerModuleInit() {
	
	// Install the built-in routing handler.
	// Using this system is optional and you could install your own system if desired.
	Routing.Handler.registerGlobally()
	
	Routing.Routes["GET", ["/", "index.html"] ] = { (_:WebResponse) in return IndexHandler() }
    Routing.Routes["GET", "/top_n_movies/{\(countKey)}"] = {_ in return TopNMoviesHandler() }
    Routing.Routes["GET", "/userUserCF/{\(userIDKey)}"] = {_ in return userUserCollaborativeFilterHandler() }
    Routing.Routes["GET", "/itemItemCF/{\(itemIDKey)}/{\(itemCountKey)}"] = {_ in return ItemItemCFHandler()}
    Routing.Routes["GET", "/movie/id/{\(itemIDKey)}"] = {_ in return ItemDetailHandler()}
    Routing.Routes["GET", "/movie/name/{\(itemNameKey)}"] = {_ in return MovieSearchHandler()}
    Routing.Routes["GET", "/rating/{\(ratingKey)}"] = {_ in return UserRatingHandler()}
	
	Routing.Routes["POST", "/rating"] = { _ in return RatingPOSTHandler() }
	
	// Check the console to see the logical structure of what was installed.
	print("\(Routing.Routes.description)")
}

class IndexHandler: RequestHandler {
	
	func handleRequest(request: WebRequest, response: WebResponse) {
		response.appendBodyString("Index handler: You accessed path \(request.requestURI())")
		response.requestCompletedCallback()
	}
}
