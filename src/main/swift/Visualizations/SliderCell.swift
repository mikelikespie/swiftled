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
    import yoga_YogaKit
    import YogaKit_swift
    import yoga_yoga
    
    import UIKit
    import RxSwift
    
    class SliderCell<Value: FloatValueConvertible> : UIView {
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
            super.init(frame: .zero)
            
            label = UILabel()
//            label.transform = .init(rotationAngle: .pi / 2)
            label.font = UIFont.systemFont(ofSize: 12)
            slider = UISlider()
    
//            slider.transform = .init(rotationAngle: .pi / 2)
            
            slider.minimumValue = bounds.lowerBound.floatValue
            slider.maximumValue = bounds.upperBound.floatValue
            
            
            slider.value = defaultValue.floatValue
            
            slider.addTarget(self, action: #selector(SliderCell.valueChanged), for: .valueChanged)
            
            rx_value
                .map(labelFunction)
                .subscribe(onNext: { [weak self] label in
                    guard let `self` = self else {
                        return
                    }
                    self.label.text = "\(name): \(label)"
                    self.label.yoga.markDirty()
                    self.superview?.setNeedsLayout()
                })
                .addDisposableTo(disposeBag)
            

            label.configureLayout {
                $0.isEnabled = true
//                $0.flexGrow = 1
//                $0.flexShrink = 1
            }
            
            slider.configureLayout {
                $0.isEnabled = true
                $0.height = 200
                $0.width = 200
            }
            
//            slider.transform = .init(rotationAngle: .pi / 2)
            addSubview(slider)
            addSubview(label)
            
            configureLayout {
                $0.flexDirection = .column
//                $0.flexShrink = 0.5
                $0.minWidth = 60
//                $0.
            }
            
            
        }
        
        func valueChanged() {
            let nextValue = Value(floatValue: self.slider.value)
            
            guard valueBounds.contains(nextValue) else {
                return
            }
            
            self.valueSubject.onNext(nextValue)
        }
        
        
        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
//        public override func layoutSubviews() {
//            super.layoutSubviews()
//            self.yoga.applyLayout(preservingOrigin: false)
//        }
    }
    
#endif
