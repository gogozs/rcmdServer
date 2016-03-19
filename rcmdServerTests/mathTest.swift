//
//  mathTest.swift
//  rcmdServer
//
//  Created by Song Zhou on 3/19/16.
//  Copyright © 2016 Song Zhou. All rights reserved.
//

import XCTest

// avg
var avgArray = [Double]()

// standard deveation
let stdDevArray =  [1.0, 2, -2, 4, -3]
let stdDevResult = 2.8810
let error = 0.001

// Pearson Correlation
let correlation1 = [1.0, 2, 3, 5, 8]
let correlation2 = [0.11, 0.12, 0.13, 0.15, 0.18]
let correlation3 = [1.0, 2, 3, 4]
let correlation4 = [40.0, 50, 70, 80]

class mathTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        for i in 1...100 {
           avgArray.append(Double(i))
        }
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAvg() {
        XCTAssert(avg(avgArray) == 50.5)
    }
    
    func testStdDev() {
        
        let r =  standardDeviation(stdDevArray, isSample: true)
        XCTAssert(fabs(r - stdDevResult) < error)
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPearsonCorrelation() {
        
        let same = pearsonCorrelation(arrayA: stdDevArray, arrayB: stdDevArray)
        XCTAssert(same - 1.0 < error, "test same value failed")
        XCTAssert(pearsonCorrelation(arrayA: correlation1, arrayB: correlation2) - 1.0 < error)
        XCTAssert(pearsonCorrelation(arrayA: correlation3, arrayB: correlation4) - 0.9899 < error)
        
        
    }
}
