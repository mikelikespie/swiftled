//
//  Control.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 2/5/16.
//  Copyright © 2016 Lolrus Industries. All rights reserved.
//

//import UIKit

import Foundation
import RxSwift
import OPC

#if os(iOS)
    import UIKit
#endif

/// Str
public struct TickContext {
    public private(set) var tickIndex: Int
    
    /// Offset we are from when the visualization started
    public private(set) var timeOffset: TimeInterval
    
    /// Time since last tick
    public private(set) var timeDelta: TimeInterval
    
}

public struct WriteContext {
    public private(set) var tickContext: TickContext
    /// The pixels to write to. Only while the tick observer is being called
    public private(set) var writeBuffer: UnsafeMutableBufferPointer<RGBFloat>
}

// Represents a control. They can have state. They are only mutated on one thread
public protocol Control : class {
    var name: String { get }
    
    /// Cells to present in the split view. Should be pre-configured
    #if os(iOS)
    var cells: [UITableViewCell] { get }
    #endif
    
    /// - parameter ticker: ticks with time interval
    /// - returns: Disposable. It should stop listening for tick information
    func run(_ ticker: Observable<TickContext>) -> Disposable
}
