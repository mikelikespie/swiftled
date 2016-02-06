//
//  ClientConnection.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//

import Foundation
import RxSwift

private let headerSize = 4
private let broadcastChannel: UInt8 = 0

private enum OpcCommand : UInt8 {
    case SetPixels = 0
}

/// A way to reuse by applying an element type over ourselves. This is how a "ClientConnection" is represented
public protocol ValueSink : class {
    /// Usually a pixel format or something
    typealias Element
    
    /// The function we pass in is called inine which should return an element at each index
}

public final class ClientConnection : CollectionType {
    public typealias Element = RGB8
    
    public typealias Index = Int
    
    private var pixelBuffer: [UInt8]
    private var workQueue = dispatch_queue_create("connection work queue", DISPATCH_QUEUE_SERIAL)
    private var channel: dispatch_io_t
    private var ledCount: Int
    private var start: NSTimeInterval
    
    public init(fd: dispatch_fd_t, ledCount: Int) {
        self.pixelBuffer =  [UInt8](count: headerSize + ledCount * 3, repeatedValue: 0)
        // Only support 1 channel for now
        let channel = broadcastChannel
        
        pixelBuffer[0] = channel
        pixelBuffer[1] = OpcCommand.SetPixels.rawValue
        pixelBuffer[2] = UInt8(truncatingBitPattern: UInt(ledCount * 3) >> 8)
        pixelBuffer[3] = UInt8(truncatingBitPattern: UInt(ledCount * 3) >> 0)
        
        
        self.start = NSDate.timeIntervalSinceReferenceDate()
        self.ledCount = ledCount
        self.channel = dispatch_io_create(DISPATCH_IO_STREAM, fd, workQueue, { _ in })
        dispatch_io_set_low_water(self.channel, 0)
        dispatch_io_set_high_water(self.channel, Int.max)
        dispatch_io_set_interval(self.channel, 0, DISPATCH_IO_STRICT_INTERVAL)
    }
    
    public func apply<C: ColorConvertible>(@noescape fn: (index: Int, now: NSTimeInterval) -> C) {
        let timeOffset = NSDate.timeIntervalSinceReferenceDate() - start
        for idx in 0..<ledCount {
            self[idx] = fn(index: idx, now: timeOffset).rgb8
        }
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return self.ledCount
    }
    
    public subscript(index: Int) -> RGB8 {
        get {
            let baseOffset = headerSize + index * 3
            
            return RGB8(
                r: pixelBuffer[baseOffset],
                g: pixelBuffer[baseOffset + 1],
                b: pixelBuffer[baseOffset + 2]
            )
        }
        
        set(color) {
            let baseOffset = headerSize + index * 3
            
            pixelBuffer[baseOffset] = color.r
            pixelBuffer[baseOffset + 1] = color.g
            pixelBuffer[baseOffset + 2] = color.b
        }
    }
    
    public func flush() -> Observable<Void> {
        let dispatchData = self.pixelBuffer.withUnsafeBufferPointer { ptr in
            return dispatch_data_create(ptr.baseAddress, ptr.count, nil, nil)
        }
        
        let subject = PublishSubject<Void>()
        
        dispatch_io_write(self.channel, 0, dispatchData, self.workQueue) { done, data, error in
            guard error == 0 else {
                subject.onError(POSIXError(rawValue: error)!)
                return
            }
            
            if done {
                subject.onNext()
                subject.onCompleted()
            }
        }

        dispatch_io_barrier(self.channel) {
            let fd = dispatch_io_get_descriptor(self.channel);
            var flag: Int = 1
        }
        
        return subject
    }
}