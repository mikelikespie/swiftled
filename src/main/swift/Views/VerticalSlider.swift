//
//  VerticalSlider.swift
//  swiftled
//
//  Created by Michael Lewis on 7/20/17.
//
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import YogaKit_swift
import yoga_YogaKit


class SliderGestureRecognizer : UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            self.state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .recognized
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .cancelled
    }
}

public class VerticalSlider : UIView {
    let sliderTopHalf = UIView()
    let sliderBottomHalf = UIView()
    
    let gr = SliderGestureRecognizer()
    
    let layoutDirtier: LayoutDirtier
    
    var value: CGFloat = 0.75 {
        didSet {
            updateSlider()
        }
    }
    
    public init(layoutDirtier: LayoutDirtier) {
        self.layoutDirtier = layoutDirtier
        
        super.init(frame: .zero)
        
        sliderTopHalf.backgroundColor = .red
        sliderBottomHalf.backgroundColor = .blue
        
        addSubview(sliderTopHalf)
        addSubview(sliderBottomHalf)
        
        addGestureRecognizer(gr)
        
        gr.addTarget(self, action: #selector(VerticalSlider.handleGesture))
        
        configureLayout {
            $0.isEnabled = true
            $0.flexDirection = .column
            $0.minHeight = 20
            $0.minWidth = 40
            $0.paddingLeft = 2
            $0.paddingRight = 2
        }
        
        sliderTopHalf.configureLayout {
            $0.isEnabled = true
        }
        
        sliderBottomHalf.configureLayout {
            $0.isEnabled = true
        }
        
        updateSlider()
    }
   
    @objc private func handleGesture() {
        switch gr.state {
        default:
            self.value = max(min(1.0 - gr.location(in: self).y / self.bounds.height, 1), 0)
        }
    }

    func updateSlider() {
        sliderTopHalf.configureLayout {
            $0.flexGrow = 1.0 - self.value
            $0.flexBasis = YGValue(1.0 - self.value)
        }
        
        sliderBottomHalf.configureLayout {
            $0.flexGrow = self.value
            $0.flexBasis = YGValue(self.value)
        }
        
        layoutDirtier.markAsDirty()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
