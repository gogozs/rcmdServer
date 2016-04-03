//
//  StringExtension.swift
//  rcmdServer
//
//  Created by Song Zhou on 4/3/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation

extension String {
    static func JSONStrFromObject(object: AnyObject) -> String {
    
        do {
         let data = try NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
            
            return String.init(data: data, encoding: NSUTF8StringEncoding)!
        } catch {
            return ""
        }
        
    }
}