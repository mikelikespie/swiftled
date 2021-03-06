//
//  RGBAFloat.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/4/16.
//
//

import Foundation
import OPC
#if os(Linux)
    typealias float3 = OPC.float3
#else
    import simd
    typealias float3 = simd.float3
#endif

public struct RGBAFloat {
    var premultipliedRGB: float3
    
    public var alpha: Float = 1
    
    /// Initializes with alpha of 1
    init(rgb: RGBFloat) {
        premultipliedRGB = rgb.storage
        alpha = 1
    }
    
    init(rgb: RGBFloat, alpha: Float) {
        premultipliedRGB = rgb.storage * alpha
        self.alpha = alpha
    }
}


extension RGBFloat {
    func with(alpha: Float) -> RGBAFloat {
        return RGBAFloat(rgb: self, alpha: alpha)
    }
}

extension RGBAFloat {
    static let clear = RGBAFloat(rgb: .black, alpha: 0)
}

extension RGBAFloat : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "rgba(r:\(premultipliedRGB.x), g:\(premultipliedRGB.y), b:\(premultipliedRGB.z), alpha:\(alpha))"
    }
}
protocol RGBAMergeable {
    static func += (lhs: inout Self, rhs: RGBAFloat)
}

extension RGBAFloat : RGBAMergeable {
}
extension RGBFloat : RGBAMergeable {
}
public func +=(lhs: inout RGBAFloat, rhs: RGBAFloat)  {
    // Additive combining
    
    lhs.premultipliedRGB = min(lhs.premultipliedRGB + rhs.premultipliedRGB, 1)
    lhs.alpha = min(lhs.alpha + rhs.alpha, 1)
}

public func +=(lhs: inout RGBFloat, rhs: RGBAFloat)  {
    // Additive combining
    // TODO: Make it combine w/ linear, not additive
    lhs.storage = min(lhs.storage * lhs.storage + rhs.premultipliedRGB * rhs.premultipliedRGB, 1)
}




extension MutableCollection where Iterator.Element : RGBAMergeable, Index == Int {
    mutating func merge<O: Collection>(other: O) where O.Iterator.Element == RGBAFloat, O.Index == Int {
        let startIndex = Swift.max(self.startIndex, other.startIndex)
        let endIndex = Swift.max(Swift.min(self.endIndex, other.endIndex), startIndex)
        
        for idx in startIndex..<endIndex {
            self[idx] += other[idx]
        }
    }
    
    mutating func merge<O: Collection>(other: O) where O.Iterator.Element == RGBFloat, O.Index == Int {
        let startIndex = Swift.max(self.startIndex, other.startIndex)
        let endIndex = Swift.max(Swift.min(self.endIndex, other.endIndex), startIndex)
        
        for idx in startIndex..<endIndex {
            self[idx] += RGBAFloat(rgb: other[idx])
        }
    }
}


