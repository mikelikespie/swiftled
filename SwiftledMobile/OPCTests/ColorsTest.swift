//
//  OPCTests.swift
//  OPCTests
//
//  Created by Michael Lewis on 2/6/16.
//  Copyright © 2016 Lolrus Industries. All rights reserved.
//

import XCTest

import OPC
//
//public struct RGBFloatDistance {
//    var r,g,b: Float
//}
//
//public extension RGBFloat: Strideable {
//
//}
//
//public protocol FloatDivisible {
//    func /(lhs: Self, rhs: Float) -> Self
//}
//
//public extension ClosedInterval where Bound: Strideable {
//
//}

class OPCTests: XCTestCase {
    let colorsToTest: [RGBFloat] = {
        let steps = 100
        let stepsFloat = Float(steps)
        
        /// Go all the way from 0 to 1
        let stepsInterpolated = (0...steps).map { Float($0) / stepsFloat }
        
        return stepsInterpolated.flatMap { r in
            stepsInterpolated.flatMap { g in
                stepsInterpolated.map { b in
                    // Gamma adjust the colors to make them more on the log scale
                    RGBFloat(r: r, g: g, b: b).gammaAdjusted()
                }
            }
        }
    }()
    
    let dimColorsToTest: [RGBFloat] = {
        let steps = 100
        let stepsFloat = Float(steps)
        
        /// Go all the way from 0 to 1
        let stepsInterpolated = (0...steps).map { Float($0) / stepsFloat * 0.5 }
        
        return stepsInterpolated.flatMap { r in
            stepsInterpolated.flatMap { g in
                stepsInterpolated.map { b in
                    // Gamma adjust the colors to make them more on the log scale
                    RGBFloat(r: r, g: g, b: b).gammaAdjusted()
                }
            }
        }
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    func testMapping<C: ColorConvertible>(name: String, colors: [RGBFloat], mappingFunc: (input: RGBFloat) -> C) {
        // This is an example of a performance test case.
        var deltaSum: Double = 0
        var logSum: Double = 0
        var count = 0
        
        var maxAdjustedDelta = 0.0
        var maxDelta = 0.0
        
        for c in colors {
            let mapping = mappingFunc(input: c)
            let adjustedDelta = sqrt(Double(mapping.rgbFloat.gammaAdjusted(0.5).distanceToSquared(c.gammaAdjusted(0.5))))
            let delta = sqrt(Double(mapping.rgbFloat.distanceToSquared(c)))
            
            deltaSum += adjustedDelta
            logSum += log(adjustedDelta + 0.0001)
            if c.r != 1 && c.g != 1 && c.b != 1 {
                maxAdjustedDelta = max(maxAdjustedDelta, adjustedDelta)
                maxDelta = max(maxDelta, delta)
            }
            count++
        }
        
        
        print("\(name): mean of delta: \(deltaSum / Double(count))")
        print("\(name): geomMean of delta: \(exp(logSum / Double(count)))")
        print("\(name): maxAdjustedDelta: \(maxAdjustedDelta)")
        print("\(name): maxDelta: \(maxDelta)")
        
        self.measureBlock {
            for c in self.colorsToTest {
                mappingFunc(input: c)
            }
        }
        
    }
    
    func testRGB8ColorMapping() {
        testMapping("rgb8", colors: dimColorsToTest) { $0.rgb8 }
    }
    
    func testRawColorMapping() {
        testMapping("rgbRaw", colors: dimColorsToTest) { $0.rawColor }
    }
}
