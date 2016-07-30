//
//  VisualizationClient.swift
//  SwiftledMobile
//
    //  Created by Michael Lewis on 2/5/16.
//  Copyright © 2016 Lolrus Industries. All rights reserved.
//

import Foundation
import OPC
import RxSwift
import Cleanse
import Dispatch

private class VisualizationClient {
    let connection: ClientConnection
    
    var buffer: [RGBFloat]
    init(connection: ClientConnection) {
        self.connection = connection
        self.buffer = [RGBFloat](repeating: RGBFloat(r: 0, g: 0, b: 0), count: connection.count)
    }
    
    func start(_ fps: Double, visualization: Visualization) -> Disposable {
        let ticker: Observable<Int> =  Observable.interval(1.0 / TimeInterval(fps), scheduler: MainScheduler.instance)
        
        let compositeDisposable = CompositeDisposable()
        
        let publishSubject = PublishSubject<WriteContext>()
        let visualizationDisposable = visualization.bind(publishSubject)
        
        compositeDisposable.addDisposable(visualizationDisposable)
        
        let tickerDisposable = ticker
            .map { idx -> (Int, TimeInterval) in
                let now = Date.timeIntervalSinceReferenceDate
                return (index: idx, now: now)
            }
            .scan(nil as (startTime: TimeInterval, context: TickContext)?) { startOffsetLastContext, indexNow in
                let now = indexNow.1
                let start = startOffsetLastContext?.startTime ?? now
                let offset = now - start
                
                let delta = offset - (startOffsetLastContext?.context.timeOffset ?? offset)
                
                return (start, TickContext(tickIndex: indexNow.0, timeOffset: offset, timeDelta: delta))
            }
            .map { startOffsetContext -> TickContext in
                return startOffsetContext!.1
            }
            .subscribeNext { tickContext in
                self.buffer.withUnsafeMutableBufferPointer { ptr in
                    let writeContext = WriteContext(tickContext: tickContext, writeBuffer:  ptr)
                    publishSubject.onNext(writeContext)
                }
                
                // Divide the tasks up into 8
                
                let fullBounds = self.buffer.startIndex..<self.buffer.endIndex
                
                applyOverRange(fullBounds) { bounds in
                    for idx in bounds {
                        self.connection[idx] = self.buffer[idx]
                    }
                }
                
                self.connection.flush()
        }
        
        compositeDisposable.addDisposable(tickerDisposable)
        
        return compositeDisposable
    }
}


public func applyOverRange(_ fullBounds: CountableRange<Int>, iterations: Int = 16, fn: (CountableRange<Int>) -> ()) {
    let chunkSize = ((fullBounds.count - 1) / iterations) + 1
    let splitBounds = (0..<iterations).map { idx in
        (fullBounds.lowerBound + chunkSize * idx)..<min((fullBounds.lowerBound + chunkSize * (idx + 1)), fullBounds.upperBound)
    }
    
    DispatchQueue.concurrentPerform(iterations: iterations) { idx in
        let bounds = splitBounds[idx]
        fn(bounds)
    }
}


public struct VisualizationRunner {
    private let ledCount: Int
    
    public init(ledCount: TaggedProvider<LedCount>) {
        self.ledCount = ledCount.get()
    }
    
    public func startVisualization(_ visualization: Visualization, fps: Double) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        let addrInfoDisposable = getaddrinfoSockAddrsAsync("pi0.local", servname: "7890")
            .debug()
            .flatMap { sa in
                return sa.connect().catchError { _ in Observable.empty() }
            }
            .take(1)
            .subscribe(
                onNext: { sock in
                    let connection = ClientConnection(
                        fd: sock,
                        ledCount: self.ledCount,
                        mode: .rgbaRaw
                    )
                    //                let connection = ClientConnection(fd: sock, ledCount: ledCount, mode: .RGB8)
                    
                    let client = VisualizationClient(connection: connection)
                    
                    let clientDisposable = client.start(fps, visualization: visualization)
                    
                    _ = compositeDisposable.addDisposable(clientDisposable)
                    
                    NSLog("Connected!")
                },
                onError: { error in
                    NSLog("failed \(error) \((error as? POSIXError)?.rawValue)")
                    //            page.finishExecution()
                    
                },
                onCompleted: {
                    NSLog("completed?")
                    //            page.finishExecution()
                }
        )
        
        _ = compositeDisposable.addDisposable(addrInfoDisposable)
        
        return compositeDisposable
    }
}

