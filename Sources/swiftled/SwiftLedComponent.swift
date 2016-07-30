//
//  SwiftLedComponent.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import Cleanse


struct SwiftLedComponent : Cleanse.RootComponent {
    typealias Root = EntryPoint
    
    static func configure<B : Binder>(binder: B) {
        binder
            .bind(EntryPoint.self)
            .to(factory: SwiftLedEntryPoint.init)
    }
}
