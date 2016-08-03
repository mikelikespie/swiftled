//
//  SwiftLedComponent.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import Cleanse


public struct SwiftLedComponent : Cleanse.RootComponent {
    public typealias Root = SwiftLedComponent
    public typealias Seed = LedConfiguration
    
    public let entryPoint: EntryPoint
    public let rootVisualization: Visualization
    
    public static func configure<B : Binder>(binder: B) {
        binder
            .bind(SwiftLedComponent.self)
            .to(factory: SwiftLedComponent.init)
        
        binder
            .bind(EntryPoint.self)
            .to(factory: SwiftLedEntryPoint.init)
        
        binder.install(module: VisualizationsModule.self)
        
        binder
            .bind(Visualization.self)
            .asSingleton()
            .to(factory: SimpleVisualization.init)
    }
}
