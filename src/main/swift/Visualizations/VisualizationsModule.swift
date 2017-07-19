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
    public static func configure(binder: Binder<Singleton>) {
        binder.include(module: LedConfigurationModule.self)
        binder.include(module: SharedControlsModule.self)
        
        binder.include(module: VisualizationRunner.Module.self)
        
        binder.include(module: MyShape.Module.self)
    }
}
