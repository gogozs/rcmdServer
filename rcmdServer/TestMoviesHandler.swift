//
//  TestMoviesHandler.swift
//  rcmdServer
//
//  Created by Song Zhou on 2/12/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib
import PostgreSQL

class TestMoviesHandler:  RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
       let pgsl = PostgreSQL.PGConnection()
        pgsl.connectdb(connectInfo)
        
        var resultStr = pgsl.errorMessage()
        
        if pgsl.status() == .Bad {
        } else {
            let result = pgsl.exec("select json_agg(x) from (SELECT * FROM movie limit 10) x")
            let s = result.status()
            if s == .CommandOK || s == .TuplesOK {
                if result.numFields() > 0 && result.numTuples() > 0 {
                    resultStr = result.getFieldString(0, fieldIndex: 0)
                    }
                }
        }
        
        pgsl.close()
        
        response.addHeader("Content-Type", value: "application/json")
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
    
}