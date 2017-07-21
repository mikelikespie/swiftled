//
// Created by Michael Lewis on 7/20/17.
//

import Foundation
import Cleanse

public struct FixtureScope : Scope {
}


public protocol FixtureBase {
    static var name: String { get }
    static var channels: Int { get }
    
    var profiles: [FixtureProfile] { get }
}

public protocol Fixture : FixtureBase {    
    var profiles: [FixtureProfile] { get }
    
    static func configureSelf(binder bind: ReceiptBinder<Self>) -> BindingReceipt<Self>
    static func configure(binder: Binder<FixtureScope>)
}


struct FixtureComponent<F: Fixture> : Component {
    typealias Scope = FixtureScope
    typealias Root = F
    
    static func configureRoot(binder bind: ReceiptBinder<F>) -> BindingReceipt<F> {
        return F.configureSelf(binder: bind)
    }
    static func configure(binder: Binder<FixtureScope>) {
        F.configure(binder: binder)
    }
}

extension Binder {
    public func install<F: Fixture>(fixture: F.Type) {
        install(dependency: FixtureComponent<F>.self)
        bind(F.self).to { ($0 as ComponentFactory<FixtureComponent<F>>).build() }
    }
}
