//
//  RGBControl.swift
//  swiftled
//
//  Created by Michael Lewis on 7/20/17.
//
//

import UIKit
import Cleanse
import Views
import RxSwift
import yoga_YogaKit

struct RGBControl : Control {
    let name = "RGB"
    
    let cell = UIView()
    
    let rSlider: VerticalSlider
    let gSlider: VerticalSlider
    let bSlider: VerticalSlider
    
    init(slider: Provider<VerticalSlider>) {
        rSlider = slider.get()
        gSlider = slider.get()
        bSlider = slider.get()
        
        
        cell.configureLayout {
            $0.isEnabled = true
            $0.flexDirection = .row
            
        }
        
        
        cell.addSubview(rSlider)
        cell.addSubview(gSlider)
        cell.addSubview(bSlider)
    }
    
    let value = Variable<Float>(0)
    

}
