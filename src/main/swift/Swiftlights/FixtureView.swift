//
// Created by Michael Lewis on 7/20/17.
//

import UIKit
import Fixtures
import yoga_YogaKit
import YogaKit_swift
import yoga_yoga


class FixtureProfileView : UIView {
    let fixtureLabel = UILabel()
    let profileLabel = UILabel()
    let controlsView = UIView()
    
    init(fixture: FixtureBase, profile: FixtureProfile) {
        super.init(frame: .zero)

        configureLayout {
            $0.isEnabled = true
            $0.flexDirection = .column
        }
        
        fixtureLabel.text = fixture.name
        profileLabel.text = profile.name
        
        fixtureLabel.yoga.isEnabled = true
        profileLabel.yoga.isEnabled = true
        
        
        controlsView.configureLayout {
            $0.isEnabled = true
            $0.flexDirection = .row
            $0.flexGrow = 1
        }
        
        addSubview(fixtureLabel)
        addSubview(profileLabel)
        addSubview(controlsView)

        profile
            .controls
            .map {
                let controlView = ControlView(control: $0)
                
                controlView.yoga.isEnabled = true
                
                return controlView
            }
            .forEach(controlsView.addSubview)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
