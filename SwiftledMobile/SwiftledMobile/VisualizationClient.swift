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

private class VisualizationClient {
    let connection: ClientConnection
    
    var buffer: [RGBFloat]
    init(connection: ClientConnection) {
        self.connection = connection
        self.buffer = [RGBFloat].init(count: connection.count, repeatedValue: RGBFloat(r: 0, g: 0, b: 0))
    }
    
    func start(fps: Double, visualization: Visualization) -> Disposable {
        let ticker: Observable<Int> =  Observable.interval(1.0 / NSTimeInterval(fps), scheduler: MainScheduler.instance)
        
        let compositeDisposable = CompositeDisposable()
        
        let publishSubject = PublishSubject<WriteContext>()
        let visualizationDisposable = visualization.bind(publishSubject)
        
        compositeDisposable.addDisposable(visualizationDisposable)
        
        let tickerDisposable = ticker
            .map { idx -> (Int, NSTimeInterval) in
                let now = NSDate.timeIntervalSinceReferenceDate()
                return (index: idx, now: now)
            }
            .scan(nil as (startTime: NSTimeInterval, context: TickContext)?) { startOffsetLastContext, indexNow in
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
                
                for idx in self.buffer.startIndex..<self.buffer.endIndex {
                    self.connection[idx] = self.buffer[idx].rgb8
                }
                
                self.connection.flush()
        }
        
        compositeDisposable.addDisposable(tickerDisposable)
        
        return compositeDisposable
        //        return TickContext.init(tickIndex: $0, timeOffset: startTime - now, timeDelta: <#T##NSTimeInterval#>)
    }
}

func startVisualization(visualization: Visualization, fps: Double) -> Disposable {
    let compositeDisposable = CompositeDisposable()
    let addrInfoDisposable = getaddrinfoSockAddrsAsync("raspberrypi.local", servname: "7890")
        .debug()
        .flatMap { sa in
            return sa.connect().catchError { _ in Observable.empty() }
        }
        .take(1)
        .subscribe(
            onNext: { sock in
                let connection = ClientConnection(fd: sock, ledCount: ledCount)
                
                let client = VisualizationClient(connection: connection)
                
                let clientDisposable = client.start(fps, visualization: visualization)
                
                compositeDisposable.addDisposable(clientDisposable)
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
    
    compositeDisposable.addDisposable(addrInfoDisposable)
    
    return compositeDisposable
}