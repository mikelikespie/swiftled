//
//  FixtureConfiguration.swift
//  swiftled
//
//  Created by Michael Lewis on 7/20/17.
//
//

import Foundation


public struct FixtureConfiguration {
    public struct ConfiguredFixture {
        public let fixture: FixtureBase
        public let startAddress: UInt8
    }
    
    public let fixtures: [ConfiguredFixture]
    
    public init(fixtures: [ConfiguredFixture]) {
        self.fixtures = fixtures
    }
}
