//
// Created by Michael Lewis on 7/20/17.
//

import UIKit
import Fixtures
import yoga_YogaKit
import YogaKit_swift
import yoga_yoga


class ControlView : UIView {
    let control: Control
    let nameLabel = UILabel()
    let controlControl: UIView

    init(control: Control) {
        self.control = control
        self.controlControl = control.cell

        super.init(frame: .zero)

        configureLayout {
            $0.isEnabled = true
            $0.flexDirection = .column
        }

        nameLabel.text = control.name

        nameLabel.configureLayout {
            $0.isEnabled = true
        }
        
        control.cell.yoga.flexGrow = 1

        addSubview(nameLabel)
        addSubview(control.cell)

    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
