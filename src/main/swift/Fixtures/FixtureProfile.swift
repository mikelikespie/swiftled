//
// Created by Michael Lewis on 7/20/17.
//

import Foundation
import Cleanse


// Profile for a fixture.
public protocol FixtureProfile {
    /// Profile name
    var name: String { get }
    
    /// Controls that this profile uses
    var controls: [Control] { get }

    /// Current values. These are polled.
    var values: [UInt8] { get }
}


public struct ConfiguredControl {
    public let name: String
    public let control: Control
}

extension FixtureProfile {
    public var controls: [ConfiguredControl] {
        return []
    }
    
    public var values: [UInt8] {
        return []
    }
}


/// Noop profile that turns everything off
struct OffProfile : FixtureProfile {
    let name = "Off"
    let controls = [Control]()
    let values = [UInt8]()

    init() {
    }
}
