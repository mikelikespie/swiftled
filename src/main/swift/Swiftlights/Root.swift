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

struct RootScope : Scope {
}

struct Root : RootComponent {
    typealias Scope = RootScope
    typealias Root = Swiftlights.Root
    
    let window: UIWindow
    
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
            .to(factory: RootViewController.init)
        
        binder
            .bind(RootView.self)
            .to(factory: RootView.init)
        
        binder.install(fixture: UVFixture.self)
        
        binder.include(module: ControlsModule.self)
//        binder.install(dependency: UVFixture.Module.self)
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
