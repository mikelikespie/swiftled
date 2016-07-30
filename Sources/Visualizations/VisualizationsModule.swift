//
//  VisualizationsModule.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import Cleanse

public struct VisualizationsModule : Module {
    public static func configure<B : Binder>(binder: B) {
        binder.install(dependency: VisualizationComponent.self)
        
        binder
            .bind(VisualizationRunner.self)
            .to(factory: VisualizationRunner.init)
    }
}
