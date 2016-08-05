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
        
        binder
            .bind()
            .tagged(with: Brightness.self)
            .to { ($0 as TaggedProvider<BrightnessControl>).get().value }
        
        binder
            .bind(Control.self)
            .intoCollection()
            .to { ($0 as TaggedProvider<BrightnessControl>).get() }

        binder
            .bind()
            .tagged(with: GammaControl.self)
            .asSingleton()
            .to {  SliderControl<Float>(bounds: 1.0..<4.0, defaultValue: 2.4, name: "Gamma") }
        
        binder
            .bind(Control.self)
            .intoCollection()
            .to { ($0 as TaggedProvider<GammaControl>).get() }

        binder
            .bind()
            .tagged(with: Gamma.self)
            .to { ($0 as TaggedProvider<GammaControl>).get().value }
    }
}


struct Brightness : Tag {
    typealias Element = Float
}

struct Gamma : Tag {
    typealias Element = Float
}

struct BrightnessControl : Tag {
    typealias Element = SliderControl<Float>
}

struct GammaControl : Tag {
    typealias Element = SliderControl<Float>
}


