//
//  SwiftLedComponent.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import Cleanse
import Visualizations

struct LedConfiguration {
    let segmentLength: Int
    let segmentCount: Int
    
    var ledCount: Int {
        return segmentLength * segmentCount
    }
}
struct SwiftLedComponent : Cleanse.RootComponent {
    typealias Root = EntryPoint
    typealias Seed = LedConfiguration
    
    static func configure<B : Binder>(binder: B) {
        binder
            .bind(EntryPoint.self)
            .to(factory: SwiftLedEntryPoint.init)
        
        binder
            .bind()
            .tagged(with: SegmentLength.self)
            .to { ($0 as Seed).segmentLength }
        binder
            .bind()
            .tagged(with: LedCount.self)
            .to { ($0 as Seed).ledCount }
        
        binder.install(module: VisualizationsModule.self)
    }
}
