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
        binder.install(module: LedConfigurationModule.self)
        binder.install(module: SharedControlsModule.self)
        
        binder.install(module: VisualizationRunner.Module.self)
        
        binder.install(module: MyShape.Module.self)
    }
}
