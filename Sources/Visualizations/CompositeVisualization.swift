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

/// Composes many visualizations
struct CompositeVisualization : Visualization, Component {
    public typealias Root = Visualization
    
    let visualizations: [Visualization]
    
    let currentVisualization: Observable<Visualization>
    
    let visualizationControl: SliderControl<Int>
    
    init(visualizations: [Visualization]) {
        self.visualizations = visualizations
        
        let visualizationNames = visualizations.map { $0.name }
        precondition(visualizations.count > 0)
    
        visualizationControl = SliderControl<Int>(
            bounds: Range(self.visualizations.indices),
            defaultValue: 0,
            name: "Visualization",
            labelFunction: { visualizationNames[$0] })
        
//        self.visualizations.indices.c
        
        self.currentVisualization = visualizationControl
            .rx_value
            .map { Int($0) }
            .distinctUntilChanged()
            .map { visualizations[$0] }
        
        self.ourControls = .just([visualizationControl])
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
        
        let currentVisualizationDisposable = SerialDisposable()
        
        // To work around a bug
        currentVisualizationDisposable.disposable = NopDisposable.instance
        
        currentVisualizationDisposable.addDisposableTo(compositeDisposable)
        
        currentVisualization
            .subscribeNext { visualization in
                currentVisualizationDisposable.disposable.dispose()
                currentVisualizationDisposable.disposable = visualization.bind(ticker)
            }
            .addDisposableTo(compositeDisposable)
        
        return compositeDisposable
    }
    
    private let ourControls: Observable<[Control]>
    
    static func configure<B : Binder>(binder: B) {
        binder
            .bind(Root.self)
            .to(factory: CompositeVisualization.init)
    }
}
