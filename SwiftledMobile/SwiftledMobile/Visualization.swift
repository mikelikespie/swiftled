//
//  Visualization.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 2/5/16.
//  Copyright © 2016 Lolrus Industries. All rights reserved.
//

import Foundation
import RxSwift

public protocol Visualization {
    /// Name of visualization. Can change
    var name: Observable<String> { get }
    var controls: Observable<[Control]> { get }
    
    /// - parameter ticker: ticks with time interval
    /// - returns: Disposable. It should stop listening for tick information
    func bind(ticker: Observable<WriteContext>) -> Disposable
}