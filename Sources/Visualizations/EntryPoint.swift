//
//  EntryPoint.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import RxSwift

public protocol EntryPoint {
    func start() -> Disposable
}
