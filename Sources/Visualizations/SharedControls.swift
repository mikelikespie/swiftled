//
//  SharedControls.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/2/16.
//
//

import Foundation
import Cleanse

struct SharedControlsModule : Cleanse.Module {
    static func configure<B : Binder>(binder: B) {
        binder
        .bind()
            .tagged(with: BrightnessControl.self)
            .asSingleton()
            .to { SliderControl(bounds: 0..<1, defaultValue: 0.25, name: "Brightness") }
    }
}

struct BrightnessControl : Tag {
    typealias Element = SliderControl<Float>
}
