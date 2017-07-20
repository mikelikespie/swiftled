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

private final class VisualizationClient : Component {
    fileprivate typealias Root = VisualizationClient
    fileprivate typealias Seed = ClientConnection
    
    let connection: ClientConnection
    
    let gamma: TaggedProvider<Gamma>
    let brightness: TaggedProvider<Brightness>
    
    var buffer: [RGBFloat]
    init(
        connection: ClientConnection,
        gamma: TaggedProvider<Gamma>,
        brightness: TaggedProvider<Brightness>) {
        self.brightness = brightness
        self.gamma = gamma
        
        self.connection = connection
        self.buffer = [RGBFloat](repeating: RGBFloat(r: 0, g: 0, b: 0), count: connection.count)
    }


    fileprivate static func configureRoot(binder bind: Cleanse.ReceiptBinder<Root>) -> Cleanse.BindingReceipt<Root> {
        return bind.to(factory: Root.init)
    }

    fileprivate static func configure(binder: Binder<Unscoped>) {
    }
    

    func start(_ fps: Double, visualization: BaseVisualization) -> Disposable {
        let serialQueue = DispatchQueue(label: "MyQueue", attributes: [], target: nil)
        
        let defaultScheduler = SerialDispatchQueueScheduler(queue: serialQueue, internalSerialQueueName: "MyQueue")

        let ticker: Observable<Int> =  Observable.interval(1.0 / TimeInterval(fps), scheduler: defaultScheduler)
        
        let compositeDisposable = CompositeDisposable()
        
        let publishSubject = PublishSubject<WriteContext>()
        let visualizationDisposable = visualization.bind(publishSubject)
        
        _ = compositeDisposable.insert(visualizationDisposable)
        
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
            .subscribe(onNext: { tickContext in
                self.buffer.withUnsafeMutableBufferPointer { ptr in
                    let writeContext = WriteContext(tickContext: tickContext, writeBuffer:  ptr)
                    publishSubject.onNext(writeContext)
                }
                
                // Divide the tasks up into 8
                
                let fullBounds = self.buffer.startIndex..<self.buffer.endIndex
                
                let brightness = self.brightness.get()
                
                applyOverRange(fullBounds) { bounds in
                    for idx in bounds {
                        let bufferValue = self.buffer[idx]
                        
                        self.connection[idx] =
                            (bufferValue * brightness)
//                            .toLinear()
                    }
                }
                
                _ = self.connection.flush()
        })
        
        _ = compositeDisposable.insert(tickerDisposable)
        
        return compositeDisposable
    }
    
}

public struct VisualizationRunner {
    private let ledCount: Int
    private let visualizationClientFactory: ComponentFactory<VisualizationClient>
    
    private init(
        ledCount: TaggedProvider<LedCount>,
        visualizationClientFactory: ComponentFactory<VisualizationClient>
    ) {
        self.ledCount = ledCount.get()
        self.visualizationClientFactory = visualizationClientFactory
    }
    
    public func startVisualization(_ visualization: BaseVisualization, fps: Double) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        let visualizationClientFactory = self.visualizationClientFactory
        
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
                    
                    let client = visualizationClientFactory.build(connection)
                    
                    let clientDisposable = client.start(fps, visualization: visualization)
                    
                    _ = compositeDisposable.insert(clientDisposable)
                    
                    NSLog("Connected!")
                },
                onError: { error in
                    NSLog("failed \(error) \((error as? POSIXErrorCode)?.rawValue ?? -999)")
                    //            page.finishExecution()
                    
                },
                onCompleted: {
                    NSLog("completed?")
                    //            page.finishExecution()
                }
        )
        
        _ = compositeDisposable.insert(addrInfoDisposable)
        
        return compositeDisposable
    }
    
    struct Module : Cleanse.Module {
        static func configure(binder: Binder<Unscoped>) {
            binder.install(dependency: VisualizationClient.self)
            
            binder
                .bind()
                .to(factory: VisualizationRunner.init)
        }
    }
}

