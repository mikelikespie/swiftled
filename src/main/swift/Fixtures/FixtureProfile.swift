//
// Created by Michael Lewis on 7/20/17.
//

import Foundation
import Cleanse


// Profile for a fixture.
protocol FixtureProfile {
    /// Controls that this profile uses
    var controls: [Control] { get }

    /// Current values. These are polled.
    var values: [UInt8] { get }
}


extension FixtureProfile {
    var controls: [Control] {
        return []
    }
    
    var values: [UInt8] {
        return []
    }
}


/// Noop profile that turns everything off
struct OffProfile : FixtureProfile {
    let controls = [Control]()
    let values = [UInt8]()

    init() {
    }
}