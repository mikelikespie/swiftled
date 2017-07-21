//
//  Root.swift
//  swiftled
//
//  Created by Michael Lewis on 7/20/17.
//
//

import UIKit
import Cleanse
import Fixtures
import RxSwift
import Views

struct RootScope : Scope {
}

struct Root : RootComponent {
    typealias Scope = RootScope
    typealias Root = Swiftlights.Root
    
    let window: UIWindow
    
    // This is so we don't lose memory from underneath us
    let rootRef: RootRef
    
    static func configure(binder: Binder<RootScope>) {
        
        binder
            .bind(UIWindow.self)
            .sharedInScope()
            .to(factory: makeKeyWindow)
        
        binder
            .bind()
            .to { UINavigationController() }
        
        binder
            .bind(RootViewController.self)
            .sharedInScope()
            .to(factory: RootViewController.init)
        
        
        binder
            .bind(LayoutDirtier.self)
            .sharedInScope()
            .to(factory: LayoutDirtier.init)
        
        binder
            .bind(RootView.self)
            .to(factory: RootView.init)
        
        binder.install(fixture: UVFixture.self)
        
        binder.include(module: ControlsModule.self)
        binder.include(module: ViewsModule.self)
        
        binder
            .bind(Observable<FixtureConfiguration>.self)
            .to(factory: self.makeFixtureConfiguration)
    }
    
    static func makeFixtureConfiguration(uvFixture: Provider<UVFixture>) -> Observable<FixtureConfiguration> {
        return Observable
            .just(FixtureConfiguration(fixtures: [
                .init(fixture: uvFixture.get(), startAddress: 0),
                .init(fixture: uvFixture.get(), startAddress: 3),
                .init(fixture: uvFixture.get(), startAddress: 3),
            ]))
    }

    static func makeKeyWindow(navController: UINavigationController, rootViewController: RootViewController) -> UIWindow {
        let window = UIWindow()
        
        navController.viewControllers = [rootViewController]
        window.rootViewController = navController
        
        return window
    }
    
    static func configureRoot(binder bind: ReceiptBinder<Root>) -> BindingReceipt<Root> {
        return bind.to(factory: Root.init)
    }
}

extension RootComponent where Root == Self, Seed == Void {
    init() throws {
        self = try ComponentFactory<Self>.of(Self.self).build(())
    }
}
