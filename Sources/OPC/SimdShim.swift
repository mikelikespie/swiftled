//
//  SimdShim.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 7/20/16.
//  Copyright © 2016 Lolrus Industries. All rights reserved.
//

import Foundation


public struct float3  {
    public var x: Float
    
    public var y: Float
    
    public var z: Float
    
    /// Initialize to the zero vector.
    public init() {
        self.init(0,0,0)
    }
    
    public init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}

func + (lhs: float3, rhs: float3) -> float3 {
    return float3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

func * (lhs: float3, rhs: Float) -> float3 {
    return float3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
}


func * (lhs: float3, rhs: float3) -> float3 {
    return float3(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
}


func distance_squared(_ lhs: float3, _ rhs: float3) -> Float {
    let (xd, yd, zd) = (lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    return xd * xd +
        yd * yd +
        zd * zd
}

func clamp(_ lhs: float3, min min_: Float, max max_: Float) -> float3 {
    return float3(
        max(min(lhs.x, max_), min_),
        max(min(lhs.y, max_), min_),
        max(min(lhs.z, max_), min_)
    )
}

#if os(Linux)

#endif
