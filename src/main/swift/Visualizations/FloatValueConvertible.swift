//
//  FloatValueConvertible.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/2/16.
//
//

import Foundation



protocol FloatValueConvertible : Comparable {
    init(floatValue: Float)
    var floatValue: Float { get }
}

extension Float : FloatValueConvertible {
    init(floatValue: Float) {
        self = floatValue
    }
    
    var floatValue: Float {
        return self
    }
}

extension Int : FloatValueConvertible {
    init(floatValue: Float) {
        self = Int(floatValue)
    }
    
    var floatValue: Float {
        return Float(self)
    }
}
