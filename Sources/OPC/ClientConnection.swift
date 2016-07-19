//
//  ClientConnection.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//

import Foundation
import RxSwift
import Dispatch
import Swift

private let headerSize = 4
private let broadcastChannel: UInt8 = 0

 enum OpcCommand : UInt8 {
    case setPixels = 0
    case customCommand = 255
}

/// A way to reuse by applying an element type over ourselves. This is how a "ClientConnection" is represented
public protocol ValueSink : class {
    /// Usually a pixel format or something
    associatedtype Element
    
    /// The function we pass in is called inine which should return an element at each index
}

public enum ConnectionMode {
    case rgb8 // use for standard OPC protocol
    case rgbaRaw // APA protocol for used in go-led-spi. Color conversion will probably be slower
}

extension ConnectionMode {
    var bytesPerPixel: Int {
        switch self {
        case .rgb8: return 3
        case .rgbaRaw: return 4
        }
    }
    var headerCommand: OpcCommand {
        switch self {
        case .rgb8: return .setPixels
        case .rgbaRaw: return .customCommand
        }
    }
}

public final class ClientConnection : Collection {
    public typealias Element = RGBFloat
    
    public typealias Index = Int
    
    private var pixelBuffer: [UInt8]
    private var workQueue = DispatchQueue(label: "connection work queue", attributes: DispatchQueueAttributes.serial)
    private var channel: DispatchIO
    private var ledCount: Int
    private var start: TimeInterval
    private let mode: ConnectionMode
    private let bytesPerPixel: Int
    
    public init(fd: Int32, ledCount: Int, mode: ConnectionMode) {
        self.mode = mode
        bytesPerPixel = mode.bytesPerPixel


        self.pixelBuffer =  [UInt8](repeating: 0, count: headerSize + ledCount * bytesPerPixel)
        // Only support 1 channel for now
        
        let channel = broadcastChannel
        
        pixelBuffer[0] = channel
        pixelBuffer[1] = mode.headerCommand.rawValue
        pixelBuffer[2] = UInt8(truncatingBitPattern: UInt(self.pixelBuffer.count - headerSize) >> 8)
        pixelBuffer[3] = UInt8(truncatingBitPattern: UInt(self.pixelBuffer.count - headerSize) >> 0)
        
        self.start = Date.timeIntervalSinceReferenceDate
        self.ledCount = ledCount
        self.channel = DispatchIO(type: DispatchIO.StreamType.stream, fileDescriptor: fd, queue: workQueue, cleanupHandler: { _ in })
        self.channel.setLimit(lowWater: 0)
        self.channel.setLimit(highWater: Int.max)
        self.channel.setInterval(interval: .seconds(0), flags: DispatchIO.IntervalFlags.strictInterval)
    }
    
    public func apply<C: ColorConvertible>( _ fn: @noescape (index: Int, now: TimeInterval) -> C) {
        let timeOffset = Date.timeIntervalSinceReferenceDate - start
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
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
    public subscript(index: Int) -> RGBFloat {
        get {
            let baseOffset = headerSize + index * bytesPerPixel
            
            switch mode {
            case .rgb8:
                return RGB8(
                    r: pixelBuffer[baseOffset],
                    g: pixelBuffer[baseOffset + 1],
                    b: pixelBuffer[baseOffset + 2]
                    ).rgbFloat
                
            case .rgbaRaw:
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
            case .rgb8:
                let color = newValue.rgb8
                
                pixelBuffer[baseOffset] = color.r
                pixelBuffer[baseOffset + 1] = color.g
                pixelBuffer[baseOffset + 2] = color.b
                
            case .rgbaRaw:
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
            return DispatchData(bytesNoCopy: ptr)
        }
        
        let subject = PublishSubject<Void>()
        
        self.channel.write(offset: 0, data: dispatchData, queue: self.workQueue) { done, data, error in
            guard error == 0 else {
                subject.onError(POSIXError(rawValue: error)!)
                return
            }
            
            if done {
                subject.onNext()
                subject.onCompleted()
            }
        }

        self.channel.barrier {
//            _ = dispatch_io_get_descriptor(self.channel);
//            var flag: Int = 1
        }
        
        return subject
    }
}
