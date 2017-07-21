//
// Created by Michael Lewis on 7/20/17.
//

import Foundation


struct UVFixture : Fixture {
    class StandardProfile  : FixtureProfile {
        let controls = [Control]()
    }
    
    class StrobeProfile  : FixtureProfile {
        let controls = [Control]()
    }
    
    let name = "UV"
    let channels = 3
    
    let profiles: [FixtureProfile] = [
        StandardProfile(),
        StrobeProfile(),
    ]
}
