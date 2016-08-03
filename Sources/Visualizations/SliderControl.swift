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

public class SliderControl : Control {
    public let name: String
    let bounds: ClosedRange<Float>

    public var value: Float {
        // return midpoint for now :/
        #if os(iOS)
            return sliderCell.slider.value
        #else
            return bounds.lowerBound + abs(bounds.lowerBound - bounds.upperBound) * 2 / 3
        #endif
    }

    #if os(iOS)
    
    public let sliderCell: SliderCell
    
    public var cells: [UITableViewCell] {
        return [sliderCell]
    }
    
    #endif
    
    
    public init(bounds: ClosedRange<Float>, defaultValue: Float, name: String) {
        self.name = name
        self.bounds = bounds
        #if os(iOS)
        self.sliderCell = SliderCell(bounds: bounds, defaultValue: defaultValue, name: name)
        #endif
    }
    
    public func run(_ ticker: Observable<TickContext>) -> Disposable {
        return NopDisposable.instance
    }
}

