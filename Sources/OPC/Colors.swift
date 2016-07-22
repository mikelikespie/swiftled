//
//  Colors.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//

import Foundation

//import simd



private func clampUnit(_ x: Float) -> Float {
    if x < 0 {
        return 0
    }
    
    if x > 1 {
        return 1
    }
    
    return x
}
//
//public struct RGBFloatDistance {
//    var storage: float3
//    
//    public var magnitude: Float {
//        return sqrt(magnitudeSquared)
//    }
//    public var magnitudeSquared: Float {
//        return r * r + g * g + b * b
//    }
//}

#if !os(Linux)
//import simd
#endif

@inline(__always) private func clampUnit(_ x: float3) -> float3 {
    return clamp(x, min: 0, max: 1)
}
/// Represent colors on unit scale
public struct RGBFloat : ColorConvertible, CustomStringConvertible {
    // Must be set between 0 and 1. Is not checked
    public var r: Float {
        @inline(__always) get {
            return storage.x
        }
        set {
            storage.x = newValue
        }
    }
    public var g: Float {
        @inline(__always) get {
            return storage.y
        }
        set {
            storage.y = newValue
        }
    }
    
    public var b: Float {
        @inline(__always) get {
            return storage.z
        }
        set {
            storage.z = newValue
        }
    }
    
    var storage: float3
    
    public var rgb8: RGB8 {
        let multiplied = storage * 255
        return RGB8(r: UInt8(multiplied.x), g: UInt8(multiplied.y), b: UInt8(multiplied.z))
    }
    
    public var rgbFloat: RGBFloat {
        return self
    }
    
    public init(r: Float, g: Float, b: Float) {
        self.storage = float3(r,g,b)
    }
    
    init(storage: float3) {
        self.storage = storage
    }
    
    /// from https://en.wikipedia.org/wiki/SRGB#The_reverse_transformation
    private func componentToLinear(_ c: Float) -> Float {
        if c < 0.04045 {
            return c / 12.92
        }
        let a: Float = 0.055
        return pow((c + a) / (1 + a), 2.4)
    }
    
    // Converts from something like sRGB -> linear which is what a device would do maybe
    public func toLinear() -> RGBFloat {
        return RGBFloat(r: componentToLinear(storage.x), g: componentToLinear(storage.y), b: componentToLinear(storage.z))
    }
    
    public func gammaAdjusted(_ gamma: Float = 2) -> RGBFloat {
        if gamma == 2 {
            return RGBFloat(storage: self.storage * self.storage)
        }
        
        return RGBFloat(r: pow(storage.x, gamma), g: pow(storage.y, gamma), b: pow(storage.z, gamma))
    }
    
    /// Should convert us to closest match of RGBARawColor
    public var rawColor: RGBARaw {
        
        // Possible naive algorithm
        
        
//        let minComponent = min(r, min(g,b))
        let maxComponent = max(storage.x, max(storage.y, storage.z))
        
        // This is the smallest our alpha can be
        let minA = UInt8(maxComponent * 31 + 1)
        let maxA: UInt8
        
        if maxComponent < 1.0 / 255.0 {
            maxA = UInt8((maxComponent / 255 * 31) + 1)
        } else {
            maxA = 31
        }
        
        let alphaSearchRange = minA...maxA
        
        var closestDeltaSquared = Float.infinity
        var closestRGBAColor = RGBARaw()
            
        /// If we have a delta less than 0.001, we can exit
        let thresholdSquared: Float = 0.001 * 0.001
        let secondThresholdSquared: Float = 0.00175 * 0.00175
        
        for a in alphaSearchRange {
            let c = self.closestRawColorWithAlpha(a)
            
            let cFloat = c.rgbFloat
            let deltaSquared = distance_squared(cFloat.storage, storage)
            
            let isMin = deltaSquared < closestDeltaSquared
            if isMin {
                closestRGBAColor = c
                closestDeltaSquared = deltaSquared
            }
            
            let numSearched = a - minA

            
            if numSearched > 5 {
                if closestDeltaSquared < secondThresholdSquared {
                    break
                }
            } else if numSearched > 2 && closestDeltaSquared < thresholdSquared {
                break
            }
        }
        
        return closestRGBAColor
    }
    
    @inline(__always) private func closestRawColorWithAlpha(_ alpha: UInt8) -> RGBARaw {
        if alpha == 0 {
            return RGBARaw(r: 0, g: 0, b: 0, a: 0)
        }
        
        let oneOverAlphaFloat = 31 / Float(alpha)
        
        // for each channel, solve c_256 in
        //   c_float = alpha_32 / 31 * c_256 / 256
        //   c_float = (c_256 / 255) * alpha_float
        //   c_float / alpha_float = (c_256 / 255)
        //   c_float / alpha_float * 255 = c_256
        
        let multiplied = clamp(storage * oneOverAlphaFloat * 255.0 + float3(0.5, 0.5, 0.5), min: 0, max: 255)
        
        return RGBARaw(
            r: UInt8(multiplied.x),
            g: UInt8(multiplied.y),
            b: UInt8(multiplied.z),
            a: alpha
        )
    }
    
    public func distanceToSquared(_ other: RGBFloat) -> Float {
        return distance_squared(self.storage, other.storage)
    }
    
    public var description: String {
        return "RGBFloat(r: \(r), g: \(g), b: \(b))"
    }
}


public struct RGB8 : ColorConvertible {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    
    public var rgb8: RGB8 {
        return self
    }
    
    public var rgbFloat: RGBFloat {
        return RGBFloat(r: Float(r) / 255.0, g: Float(g) / 255.0, b: Float(b) / 255.0)
    }
    
    public init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }
}

public protocol ColorConvertible {
    var rgbFloat: RGBFloat { get }
}

public extension ColorConvertible {
    /// Default implementation
    var rgb8: RGB8 {
        return self.rgbFloat.rgb8
    }
}


private let floatStorageMultiplierConstant: Float = 1.0 / 255.0 / 31

/// Represents the color format for an APA102
/// a is 0-31
public struct RGBARaw : ColorConvertible, CustomStringConvertible {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    public var a: UInt8
    
    private var rgbFloatStorage: float3 {
        @inline(__always) get {
            let mult = floatStorageMultiplierConstant * Float(a)
            return float3(Float(r), Float(g), Float(b)) * mult
        }
    }

    
    @inline(__always) private func distanceToRgbFloatSquared(_ other: float3) -> Float {
        let mult = floatStorageMultiplierConstant * Float(a)
        let ourStorage = float3(Float(r), Float(g), Float(b)) * mult
        return distance_squared(ourStorage, other)
    }
    
    public var rgbFloat: RGBFloat {
        return RGBFloat(storage: rgbFloatStorage)
    }

    public init(r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0, a: UInt8 = 31) {
        assert(a < 32)
        
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public var description: String {
        return "RGBARaw(r: \(r), g: \(g), b: \(b), a: \(a))"
    }
}


public struct HSV : ColorConvertible {
    public var h: Float
    public var s: Float
    public var v: Float
    
    public init(h: Float, s: Float, v: Float) {
        self.h = h
        self.s = s
        self.v = v
    }
    
    public var rgbFloat: RGBFloat {
        // Transliterated from FastLED
        let invsat = 1.0 - s
        let brightness_floor = (v * invsat)
        let color_amplitude = v - brightness_floor
        
        // Figure out which section of the hue wheel we're in,
        // and how far offset we are withing that section
        let section = Int(floor(h * 3.0))
        let offset = (h * 3.0).truncatingRemainder(dividingBy: 1.0)
        
        let rampup = offset
        let rampdown = 1.0 - offset
        
        // We now scale rampup and rampdown to a 0-255 range -- at least
        // in theory, but here's where architecture-specific decsions
        // come in to play:
        // To scale them up to 0-255, we'd want to multiply by 4.
        // But in the very next step, we multiply the ramps by other
        // values and then divide the resulting product by 256.
        // So which is faster?
        //   ((ramp * 4) * othervalue) / 256
        // or
        //   ((ramp    ) * othervalue) /  64
        // It depends on your processor architecture.
        // On 8-bit AVR, the "/ 256" is just a one-cycle register move,
        // but the "/ 64" might be a multicycle shift process. So on AVR
        // it's faster do multiply the ramp values by four, and then
        // divide by 256.
        // On ARM, the "/ 256" and "/ 64" are one cycle each, so it's
        // faster to NOT multiply the ramp values by four, and just to
        // divide the resulting product by 64 (instead of 256).
        // Moral of the story: trust your profiler, not your insticts.
        
        // Since there's an AVR assembly version elsewhere, we'll
        // assume what we're on an architecture where any number of
        // bit shifts has roughly the same cost, and we'll remove the
        // redundant math at the source level:
        
        //  // scale up to 255 range
        //  //rampup *= 4; // 0..252
        //  //rampdown *= 4; // 0..252
        
        // compute color-amplitude-scaled-down versions of rampup and rampdown
        let rampup_amp_adj   = (rampup   * color_amplitude)
        let rampdown_amp_adj = (rampdown * color_amplitude)
        
        // add brightness_floor offset to everything
        
        let r, g, b: Float
        
        
        switch section {
        case 0:
            r = brightness_floor
            g = rampdown_amp_adj
            b = rampup_amp_adj
        case 1:
            r = rampup_amp_adj
            g = brightness_floor
            b = rampdown_amp_adj
        case 2:
            r = rampdown_amp_adj
            g = rampup_amp_adj
            b = brightness_floor
        default: preconditionFailure()
        }
        return RGBFloat(r: r, g: g, b: b)
    }
}


public func *(lhs: RGBFloat, rhs: Float) -> RGBFloat {
    return RGBFloat(storage: lhs.storage * rhs)
}

