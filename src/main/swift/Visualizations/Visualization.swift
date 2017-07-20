//
//  Visualization.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 2/5/16.
//  Copyright © 2016 Lolrus Industries. All rights reserved.
//

import Foundation
import RxSwift
import Cleanse

public protocol BaseVisualization {
    /// Name of visualization. Can change
    var name: String { get }
    var controls: Observable<[Control]> { get }
    
    /// - parameter ticker: ticks with time interval
    /// - returns: Disposable. It should stop listening for tick information
    func bind(_ writeContext: Observable<WriteContext>) -> Disposable

}

extension BaseVisualization {
    public func bind(_ writeContext: Observable<WriteContext>)  -> Disposable {
        return Disposables.create()
    }
}

public protocol Visualization : BaseVisualization {
    // Root must be self
    static func configureRoot(binder bind: ReceiptBinder<BaseVisualization>) -> BindingReceipt<BaseVisualization>
}
