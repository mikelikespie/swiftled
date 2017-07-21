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
    public let rootVisualization: BaseVisualization

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
            .bind(BaseVisualization.self)
            .sharedInScope()
            .to {(factory: ComponentFactory<CompositeVisualization>) in
                
                return factory.build(())
        }
    
        binder
            .bind()
            .intoCollection()
            .tagged(with: UnsortedVisualizations.self)
            .to(value: [])
        
        binder.install(visualization: SimpleVisualization.self)
        binder.install(visualization: IdentificationVisualization.self)
        binder.install(visualization: StaticVisualization.self)
        binder.install(visualization: STimeVisualization.self)

        binder
            .bind([BaseVisualization].self)
            .to { ($0 as TaggedProvider<UnsortedVisualizations>).get().sorted { $0.name < $1.name } }
    }
}


struct UnsortedVisualizations : Tag {
    typealias Element = [BaseVisualization]
}


class VisualizationComponent<V: Visualization> : Component {
    static func configureRoot(binder bind: ReceiptBinder<BaseVisualization>) -> BindingReceipt<BaseVisualization> {
        return V.configureRoot(binder: bind)
    }
    
    public static func configure(binder: Binder<Unscoped>) {
    }
}

extension Binder where Scope == Singleton {
    public func install<V: Visualization>(visualization: V.Type) {
        install(dependency: VisualizationComponent<V>.self)
        
        bind(BaseVisualization.self)
            .intoCollection()
            .tagged(with: UnsortedVisualizations.self)
            .sharedInScope()
            .to {(factory: ComponentFactory<VisualizationComponent<V>>) -> BaseVisualization in
                return factory.build(())
        }
    }
}
