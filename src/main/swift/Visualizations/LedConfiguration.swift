
//
//  File.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/2/16.
//
//

import Foundation
import Cleanse



public struct LedConfiguration {
    let segmentLength: Int
    let segmentCount: Int
    
    public init(
        segmentLength: Int,
        segmentCount: Int
    ) {
        self.segmentLength = segmentLength
        self.segmentCount = segmentCount
    }
    
    var ledCount: Int {
        return segmentLength * segmentCount
    }
}


struct LedConfigurationModule : Module {
    static func configure(binder: Binder<Unscoped>) {
        
        binder
            .bind()
            .tagged(with: SegmentLength.self)
            .to { ($0 as LedConfiguration).segmentLength }
        
        binder
            .bind()
            .tagged(with: SegmentCount.self)
            .to { ($0 as LedConfiguration).segmentCount }
        
        binder
            .bind()
            .tagged(with: LedCount.self)
            .to { ($0 as LedConfiguration).ledCount }
    }
}
