//
// Created by Michael Lewis on 7/20/17.
//

import Foundation
import Cleanse

protocol Fixture {
    var name: String { get }
    var profiles: [FixtureProfile] { get }
    var channels: Int { get }
}
