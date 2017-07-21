//
//  ControlsModule.swift
//  swiftled
//
//  Created by Michael Lewis on 7/20/17.
//
//

import Foundation
import Cleanse

public struct ControlsModule : Module {
    public static func configure(binder: Binder<Unscoped>) {
        binder.bind().to(factory: LightnessControl.init)
    }
}
