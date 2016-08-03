//
//  SwiftLedEntryPoint.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import OPC
import RxSwift
import Cleanse

struct SwiftLedEntryPoint : EntryPoint {
    let ledRunner: VisualizationRunner
    let visualization: Visualization
    let configuration: LedConfiguration
    
    private func doStuff(conn: ClientConnection) -> Disposable {        
        return ledRunner.startVisualization(visualization, fps: 600)
    }
    
    func start() -> Disposable {
        var didConnect = false
        
        let compositeDisposable = CompositeDisposable()
        
        
        let connDisposable = getaddrinfoSockAddrsAsync("pi0.local", servname: "7890")
            .debug("getaddrinfoSockAddrsAsync")
            .flatMap { sa in
                return sa.connect().catchError { _ in .empty() }
            }
            .take(1)
            .subscribe(
                onNext: { sock in
                    didConnect = true
                    
                    let connection = ClientConnection(
                        fd: sock,
                        ledCount: self.configuration.ledCount,
                        mode: .rgbaRaw
                    )
                    
                    
                    
                    _ = compositeDisposable.addDisposable(self.doStuff(conn: connection))

                },
                onError: { error in
                    NSLog("failed \(error) \((error as? POSIXErrorCode)?.rawValue)")
                    exit(1)
                },
                onCompleted: {
                    if !didConnect {
                        NSLog("All connections failed")
                        exit(2)
                    }
                }
        )
        
        _ = compositeDisposable.addDisposable(connDisposable)
        
        return compositeDisposable
    }
}

