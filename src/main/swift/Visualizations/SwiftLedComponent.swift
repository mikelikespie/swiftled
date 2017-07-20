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
    public typealias Scope = Singleton

    public let entryPoint: EntryPoint
    public let rootVisualization: Visualization

    public static func configureRoot(binder bind: Cleanse.ReceiptBinder<Root>) -> Cleanse.BindingReceipt<Root> {
        return bind.to(factory: Root.init)
    }

    public static func configure(binder: Binder<Singleton>) {
        binder
            .bind(EntryPoint.self)
            .to(factory: SwiftLedEntryPoint.init)
        
        binder.include(module: VisualizationsModule.self)
        
        binder.install(dependency: CompositeVisualization.self)
        
        binder
            .bind(Visualization.self)
            .sharedInScope()
            .to {(factory: ComponentFactory<CompositeVisualization>) in
                
                return factory.build(())
        }
    
        
        binder
            .bind()
            .intoCollection()
            .tagged(with: UnsortedVisualizations.self)
            .to(value: [])
        
//        binder.bindVisualization().to(factory: SimpleVisualization.init)
//        binder.bindVisualization().to(factory: IdentificationVisualization.init)
//        binder.bindVisualization().to(factory: StaticVisualization.init)
//        binder.bindVisualization().to(factory: STimeVisualization.init)

        binder
            .bind([Visualization].self)
            .to { ($0 as TaggedProvider<UnsortedVisualizations>).get().sorted { $0.name < $1.name } }
    }
}


struct UnsortedVisualizations : Tag {
    typealias Element = [Visualization]
}

extension Binder {
//    func bindVisualization() -> ReceiptBinder<Visualization> {
////        ReceiptBinder
////        return self
//        self
//            .bind(Visualization.self)
////            .intoCollection()
//            .tagged(with: UnsortedVisualizations.self)
//        .
////            .sharedInScope()
//    }
}


//struct VisualizationBinder : BindToable {
//    
//}
