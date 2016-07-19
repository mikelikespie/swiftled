//
//  Control.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 2/5/16.
//  Copyright © 2016 Lolrus Industries. All rights reserved.
//

import UIKit
import RxSwift
import OPC

/// Str
public struct TickContext {
    var tickIndex: Int
    
    /// Offset we are from when the visualization started
    var timeOffset: TimeInterval
    
    /// Time since last tick
    var timeDelta: TimeInterval
    
}

public struct WriteContext {
    var tickContext: TickContext
    /// The pixels to write to. Only while the tick observer is being called
    var writeBuffer: UnsafeMutableBufferPointer<RGBFloat>
}

// Represents a control. They can have state. They are only mutated on one thread
public protocol Control : class {
    var name: String { get }
    
    /// Cells to present in the split view. Should be pre-configured
    var cells: [UITableViewCell] { get }
    
    /// - parameter ticker: ticks with time interval
    /// - returns: Disposable. It should stop listening for tick information
    func run(_ ticker: Observable<TickContext>) -> Disposable
}
