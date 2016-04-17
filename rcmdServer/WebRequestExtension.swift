//
//  WebRequestExtension.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/17/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation
import PerfectLib

extension WebRequest {
    
    /// return parameters dict from str
    /// e.g., input: `user_id=1&movie_id=250` output: `["movie_id": "250", "user_id": "1"]`
    func requestParametersFromStr(str: String) -> [String: String]? {
        var result = [String: String]()
        
        let parameterStrs = str.componentsSeparatedByString("&")
        
        for parameterStr in parameterStrs {
            let parameterArray = parameterStr.componentsSeparatedByString("=")
            
            guard (parameterArray.count > 1) else { // not valid format
                return nil
            }
            
            result[parameterArray.first!] = parameterArray.last!
        }
        
        return result
    }
}