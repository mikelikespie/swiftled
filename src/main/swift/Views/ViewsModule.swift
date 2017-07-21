//
//  ViewsModule.swift
//  swiftled
//
//  Created by Michael Lewis on 7/20/17.
//
//

import Foundation
import Cleanse
import UIKit

public struct ViewsModule : Module {
    public static func configure(binder: Binder<Unscoped>) {
        binder.bind().to(factory: VerticalSlider.init)
    }
}
