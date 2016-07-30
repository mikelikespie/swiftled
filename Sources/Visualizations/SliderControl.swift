//
//  SliderControl.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import RxSwift

class SliderControl : Control {
    let name: String
    let bounds: ClosedRange<Float>
    
//    let sliderCell: SliderCell
    
    var value: Float {
        // return midpoint for now :/
        return (bounds.lowerBound + bounds.upperBound) / 2
//        return sliderCell.slider.value
    }
//    
//    var cells: [UITableViewCell] {
//        return [sliderCell]
//    }
    
    init(bounds: ClosedRange<Float>, defaultValue: Float, name: String) {
        self.name = name
        self.bounds = bounds
//        self.sliderCell = SliderCell(bounds: bounds, defaultValue: defaultValue, name: name)
        
    }
    
    func run(_ ticker: Observable<TickContext>) -> Disposable {
        return NopDisposable.instance
    }
}

