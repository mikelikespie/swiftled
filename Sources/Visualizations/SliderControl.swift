//
//  SliderControl.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import RxSwift

#if os(iOS)
    import UIKit
#endif

class SliderControl<V: FloatValueConvertible> : TypedControl {
    let name: String
    let bounds: Range<Value>
    
    typealias Value = V
    
    var rx_value: Observable<Value> {
        #if os(iOS)
            return sliderCell.rx_value
        #else
            return valueSubject
        #endif
    }
    
    #if !os(iOS)
    private var valueSubject: BehaviorSubject<Value>
    #endif
    
    var value: Value {
        // return midpoint for now :/
        #if os(iOS)
            return sliderCell.value
        #else
            return valueSubject.value()
        #endif
    }
    
    #if os(iOS)
    
    let sliderCell: SliderCell<Value>
    
    public var cells: [UITableViewCell] {
        return [sliderCell]
    }
    
    #endif
    
    
    init(bounds: Range<Value>, defaultValue: Value, name: String, labelFunction: Optional<(Value) -> String>=nil) {
        self.name = name
        self.bounds = bounds
        #if os(iOS)
            self.sliderCell = SliderCell(bounds: bounds, defaultValue: defaultValue, name: name, labelFunction: labelFunction)
        #else
            self.valueSubject = BehaviorSubject(value: defaultValue)
        #endif
    }
    
    public func run(_ ticker: Observable<TickContext>) -> Disposable {
        return Disposables.create()
    }
}

