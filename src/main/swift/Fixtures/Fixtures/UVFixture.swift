//
// Created by Michael Lewis on 7/20/17.
//

import Foundation
import Cleanse

public struct UVFixture : Fixture {
    public static let name = "UV"
    public static let channels = 3
    
    public let profiles: [FixtureProfile]
    
    public static func configureSelf(binder bind: ReceiptBinder<UVFixture>) -> BindingReceipt<UVFixture> {
        return bind.to(factory: self.init)
    }
    
    public static func configure(binder: Binder<FixtureScope>) {
        binder.bind(FixtureProfile.self).intoCollection().to(factory: StandardProfile.init)
        binder.bind(FixtureProfile.self).intoCollection().to(factory: StrobeProfile.init)
    }
    
    
    struct StandardProfile  : FixtureProfile {
        let lightnessControl: LightnessControl
        
        var controls: [Control] {
            return [
                lightnessControl,
            ]
        }
    }
    
    struct StrobeProfile  : FixtureProfile {
        let lightnessControl: LightnessControl
        
        var controls: [Control] {
            return [
                lightnessControl,
            ]
        }
    }
}
