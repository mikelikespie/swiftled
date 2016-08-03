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
    
    public class SliderCell : UITableViewCell {
        var slider: UISlider!
        var label: UILabel!
        var name: String
        
        private var disposeBag = DisposeBag()
        
        init(bounds: ClosedRange<Float>, defaultValue: Float, name: String) {
            self.name = name
            super.init(style: .default, reuseIdentifier: nil)
            
            label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            slider = UISlider()
            
            slider.minimumValue = bounds.lowerBound
            slider.maximumValue = bounds.upperBound
            
            label.translatesAutoresizingMaskIntoConstraints = false
            slider.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(slider)
            contentView.addSubview(label)
            
            slider.value = defaultValue
//            slider
//                .rx_value
//                .subscribeNext { [unowned self] value in
//                    self.label.text = "\(self.name): \(value)"
//                }
//                .addDisposableTo(disposeBag)
//            
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
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}

#endif
