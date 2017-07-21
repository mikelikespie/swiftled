//
// Created by Michael Lewis on 7/20/17.
//

import Foundation
import UIKit
import Views

struct LightnessControl : Control {
    let name = "Brightness"
    
    let slider: VerticalSlider
    
    var cell: UIView {
        return slider
    }
}
