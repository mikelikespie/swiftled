//
//  SliderCell.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/2/16.
//
//

import Foundation


#if os(iOS)

import UIKit
import RxSwift
    
    class SliderCell<Value: FloatValueConvertible> : UITableViewCell {
        var slider: UISlider!
        var label: UILabel!
        var name: String
        
        let valueBounds: Range<Value>
        
        var rx_value: Observable<Value> {
            return valueSubject
        }
        
        @nonobjc
        var value: Value {
            return (try? valueSubject.value()) ?? valueBounds.lowerBound
        }
        
        private var disposeBag = DisposeBag()
        
        private let valueSubject: BehaviorSubject<Value>
        init(
            bounds: Range<Value>,
            defaultValue: Value,
            name: String,
            labelFunction: Optional<(Value) -> String>
        ) {
            
            self.valueSubject = BehaviorSubject(value: defaultValue)
            
            let labelFunction = labelFunction ?? { "\($0)" }
            
            self.valueBounds = bounds
            self.name = name
            super.init(style: .default, reuseIdentifier: nil)
            
            label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            slider = UISlider()
            
            slider.minimumValue = bounds.lowerBound.floatValue
            slider.maximumValue = bounds.upperBound.floatValue
            
            label.translatesAutoresizingMaskIntoConstraints = false
            slider.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(slider)
            contentView.addSubview(label)
            
            slider.value = defaultValue.floatValue
            
            slider.addTarget(self, action: #selector(SliderCell.valueChanged), for: .valueChanged)
        
            rx_value
                .map(labelFunction)
                .subscribeNext { [weak self] label in
                    guard let `self` = self else {
                        return
                    }
                    
                    
                    
                    self.label.text = "\(name): \(label)"
                }
                .addDisposableTo(disposeBag)

            let constraints = [
                NSLayoutConstraint(item: slider, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: slider, attribute: .bottom, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0),
                ] + ([label, slider] as [UIView]).flatMap {
                    [
                        NSLayoutConstraint(item: $0, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leadingMargin, multiplier: 1, constant: 0),
                        NSLayoutConstraint(item: $0, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailingMargin, multiplier: 1, constant: 0),
                        ]
            }
            
            NSLayoutConstraint.activate(constraints)
        }
        
        func valueChanged() {
            let nextValue = Value(floatValue: self.slider.value)
            
            guard valueBounds.contains(nextValue) else {
                return
            }
            
            self.valueSubject.onNext(nextValue)
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}

#endif
