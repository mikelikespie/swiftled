//
//  CompositeVisualization.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/2/16.
//
//

import Foundation
import Cleanse
import RxSwift


struct CompositeVisualizationScope : Scope {
}

/// Composes many visualizations
struct CompositeVisualization : BaseVisualization, Component {
    typealias Root = BaseVisualization
    typealias Scope = CompositeVisualizationScope
    

    static func configureRoot(binder bind: ReceiptBinder<BaseVisualization>) -> BindingReceipt<BaseVisualization> {
        return bind.to(factory: self.init)
    }
    
    let currentVisualization: Observable<BaseVisualization>
    
    init(currentVisualization: Observable<BaseVisualization>, controls: [Control]) {
        self.ourControls = .just(controls)
        self.currentVisualization = currentVisualization
    }

    var name: String {
        return "Multiple Visualizations"
    }

    private var currentVisualizationControls: Observable<[Control]> {
        return currentVisualization.flatMap { $0.controls }
    }
    var controls: Observable<[Control]> {
        return Observable.combineLatest(ourControls, currentVisualizationControls) { ours, currents in
            return ours + currents
        }
    }
    
    func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        
        var currentVisualizationDisposable = Disposables.create()
        
        
        currentVisualizationDisposable.addDisposableTo(compositeDisposable)
        
        currentVisualization
            .subscribe(onNext: {visualization in
                currentVisualizationDisposable.dispose()
                currentVisualizationDisposable = visualization.bind(ticker)
            })
            .addDisposableTo(compositeDisposable)
        
        return compositeDisposable
    }
    
    private let ourControls: Observable<[Control]>
    
    static func configure(binder: Binder<CompositeVisualizationScope>) {
        binder
            .bind()
            .tagged(with: VisualizationControl.self)
            .sharedInScope()
            .to(factory: self.makeVisualizationControl)
        
        binder
            .bind(Control.self)
            .intoCollection()
            .to { ($0 as TaggedProvider<VisualizationControl>).get() }
        
        binder
            .bind(Observable<BaseVisualization>.self)
            .sharedInScope()
            .to(factory: self.makeCurrentVisualization)
        
    }
    
    struct VisualizationControl : Tag {
        typealias Element = SliderControl<Int>
    }
    
    static func makeVisualizationControl(visualizations: [BaseVisualization]) -> VisualizationControl.Element {
        let visualizationNames = visualizations.map { $0.name }

        return
            SliderControl<Int>(
                bounds: Range(visualizations.indices),
                defaultValue: 0,
                name: "Visualization",
                labelFunction: { visualizationNames[$0] })
    }
    
    static func makeCurrentVisualization(
        visualizations: [BaseVisualization],
        visualizationControl: TaggedProvider<VisualizationControl>
    ) -> Observable<BaseVisualization> {
        precondition(visualizations.count > 0)
        
        return visualizationControl
            .get()
            .rx_value
            .map { Int($0) }
            .distinctUntilChanged()
            .map { visualizations[$0] }

    }
}
