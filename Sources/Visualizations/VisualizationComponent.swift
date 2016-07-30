//
//  VisualizationComponent.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import Cleanse

public struct VisualizationComponent : Cleanse.Component {
    public typealias Root = Visualization
    
    public static func configure<B : Binder>(binder: B) {
        binder
            .bind(Root.self)
            .to(factory: SimpleVisualization.init)
    }
}
