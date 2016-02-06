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

 enum OpcCommand : UInt8 {
    case SetPixels = 0
    case CustomCommand = 255
}

/// A way to reuse by applying an element type over ourselves. This is how a "ClientConnection" is represented
public protocol ValueSink : class {
    /// Usually a pixel format or something
    typealias Element
    
    /// The function we pass in is called inine which should return an element at each index
}

public enum ConnectionMode {
    case RGB8 // use for standard OPC protocol
    case RGBARaw // APA protocol for used in go-led-spi. Color conversion will probably be slower
}

extension ConnectionMode {
    var bytesPerPixel: Int {
        switch self {
        case .RGB8: return 3
        case .RGBARaw: return 4
        }
    }
    var headerCommand: OpcCommand {
        switch self {
        case .RGB8: return .SetPixels
        case .RGBARaw: return .CustomCommand
        }
    }
}

public final class ClientConnection : CollectionType {
    public typealias Element = RGBFloat
    
    public typealias Index = Int
    
    private var pixelBuffer: [UInt8]
    private var workQueue = dispatch_queue_create("connection work queue", DISPATCH_QUEUE_SERIAL)
    private var channel: dispatch_io_t
    private var ledCount: Int
    private var start: NSTimeInterval
    private let mode: ConnectionMode
    private let bytesPerPixel: Int
    
    public init(fd: dispatch_fd_t, ledCount: Int, mode: ConnectionMode) {
        self.mode = mode
        bytesPerPixel = mode.bytesPerPixel


        self.pixelBuffer =  [UInt8](count: headerSize + ledCount * bytesPerPixel, repeatedValue: 0)
        // Only support 1 channel for now
        
        let channel = broadcastChannel
        
        pixelBuffer[0] = channel
        pixelBuffer[1] = mode.headerCommand.rawValue
        pixelBuffer[2] = UInt8(truncatingBitPattern: UInt(self.pixelBuffer.count - headerSize) >> 8)
        pixelBuffer[3] = UInt8(truncatingBitPattern: UInt(self.pixelBuffer.count - headerSize) >> 0)
        
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
            self[idx] = fn(index: idx, now: timeOffset).rgbFloat
        }
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return self.ledCount
    }
    
    public subscript(index: Int) -> RGBFloat {
        get {
            let baseOffset = headerSize + index * bytesPerPixel
            
            switch mode {
            case .RGB8:
                return RGB8(
                    r: pixelBuffer[baseOffset],
                    g: pixelBuffer[baseOffset + 1],
                    b: pixelBuffer[baseOffset + 2]
                    ).rgbFloat
                
            case .RGBARaw:
                return RGBARaw(
                    r: pixelBuffer[baseOffset],
                    g: pixelBuffer[baseOffset + 1],
                    b: pixelBuffer[baseOffset + 2],
                    a: pixelBuffer[baseOffset + 3]
                    ).rgbFloat
                
            }
        }
        
        set {
            let baseOffset = headerSize + index * bytesPerPixel
            
            switch mode {
            case .RGB8:
                let color = newValue.rgb8
                
                pixelBuffer[baseOffset] = color.r
                pixelBuffer[baseOffset + 1] = color.g
                pixelBuffer[baseOffset + 2] = color.b
                
            case .RGBARaw:
                let color = newValue.rawColor
                pixelBuffer[baseOffset] = color.r
                pixelBuffer[baseOffset + 1] = color.g
                pixelBuffer[baseOffset + 2] = color.b
                pixelBuffer[baseOffset + 3] = color.a
            }
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