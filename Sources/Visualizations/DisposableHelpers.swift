//
//  DisposableHelpers.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/2/16.
//
//

import Foundation
import RxSwift


extension Disposable {
    public func addDisposableTo(_ compositeDisposable: CompositeDisposable) {
        _ = compositeDisposable.insert(self)
    }
}
