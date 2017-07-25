//
// Created by Michael Lewis on 7/20/17.
//

import Foundation
import UIKit
import Views
import RxSwift

struct LightnessControl : Control {
    let name = "Brightness"
    
    let slider: VerticalSlider
    
    let value = Variable<Float>(0)

    let imageView = UIImageView(image: UIImage(named: "sun"))

    init(slider: VerticalSlider) {
        self.slider = slider
        cell.addSubview(imageView)
        cell.addSubview(slider)
    }
    
    let cell = UIView()
}
