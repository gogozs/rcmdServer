//
//  Math.swift
//  recommederSystermExercise
//
//  Created by Song Zhou on 1/16/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import Foundation

public func avg(numbers:[Double]) -> Double {
    let count = Double(numbers.count)
    if count != 0 {
        var r :Double = 0.0
        for i in numbers {
            r += i
        }
        
        return r / count
    }
    
    return 0.0
}

public func populationStandardDeviation(numbers: [Double]) -> Double {
    return standardDeviation(numbers, isSample: false)
}

public func sampleStandardDeviation(numbers: [Double]) -> Double {
    return standardDeviation(numbers, isSample: true)
}

public func standardDeviation(numbers: [Double], isSample yesOrNo: Bool) -> Double {
    var count = Double(numbers.count)
    if yesOrNo {
        count -= 1
    }
    if count == 0 {
       return 0.0
    }
    
    let mean = avg(numbers)
    
    var r :Double = 0.0
    for i in numbers {
        r += pow((i - mean), 2)
    }
    
    return sqrt(r / count)
}

public func pearsonCorrelation(arrayA a: [Double], arrayB b: [Double]) -> Double {
        var r: Double = 0.0
    
        if a.count != b.count {
            return 0.0
        }
        let count = a.count
    
        let avgA = avg(a)
        let avgB = avg(b)
        
        for i in 0...(count-1) {
            r += (a[i] - avgA) * (b[i] - avgB)
        }
        
        let stdDeviationA = sampleStandardDeviation(a)
        let stdDeviationB = sampleStandardDeviation(b)
        
        return r / (stdDeviationA * stdDeviationB * Double(count - 1))
}