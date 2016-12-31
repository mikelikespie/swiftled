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
    
    public let entryPoint: EntryPoint
    public let rootVisualization: Visualization
    
    public static func configure<B : Binder>(binder: B) {
        binder
            .bind(SwiftLedComponent.self)
            .to(factory: SwiftLedComponent.init)
        
        binder
            .bind(EntryPoint.self)
            .to(factory: SwiftLedEntryPoint.init)
        
        binder.install(module: VisualizationsModule.self)
        
        binder.install(dependency: CompositeVisualization.self)
        
        binder
            .bind(Visualization.self)
            .asSingleton()
            .to {(factory: ComponentFactory<CompositeVisualization>) in
                
                return factory.build(())
        }
        
        
        binder.bindVisualization().to(factory: SimpleVisualization.init)
        binder.bindVisualization().to(factory: IdentificationVisualization.init)
        binder.bindVisualization().to(factory: StaticVisualization.init)
        binder.bindVisualization().to(factory: STimeVisualization.init)
        
        
        binder
            .bind([Visualization].self)
            .to { ($0 as TaggedProvider<UnsortedVisualizations>).get().sorted { $0.name < $1.name } }
    }
}


struct UnsortedVisualizations : Tag {
    typealias Element = [Visualization]
}
extension Binder {
    func bindVisualization() -> ScopedBindingDecorator<TaggedBindingBuilderDecorator<SingularCollectionBindingBuilderDecorator<BaseBindingBuilder<Visualization, Self>>, UnsortedVisualizations>, Singleton> {
        return self
            .bind(Visualization.self)
            .intoCollection()
            .tagged(with: UnsortedVisualizations.self)
            .asSingleton()
    }
}
