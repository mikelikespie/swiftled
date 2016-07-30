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
import Visualizations
import Cleanse

struct SwiftLedEntryPoint : EntryPoint {
    let ledRunner: VisualizationRunner
    let visualizationFactory: ComponentFactory<VisualizationComponent>
    
    private func doStuff(conn: ClientConnection) {        
        let visualization = visualizationFactory.build(seed: ())
        
        let disposable = ledRunner.startVisualization(visualization, fps: 600)
    }
    
    

    func run() {
        var didConnect = false
        
        let disposable = getaddrinfoSockAddrsAsync("pi0.local", servname: "7890")
            .debug("getaddrinfoSockAddrsAsync")
            .flatMap { sa in
                return sa.connect().catchError { _ in .empty() }
            }
            .take(1)
            .subscribe(
                onNext: { sock in
                    didConnect = true
                    
                    let connection = ClientConnection(fd: sock, ledCount: ledCount, mode: .rgbaRaw)
                    
                    self.doStuff(conn: connection)
                },
                onError: { error in
                    NSLog("failed \(error) \((error as? POSIXError)?.rawValue)")
                    exit(1)
                },
                onCompleted: {
                    if !didConnect {
                        NSLog("All connections failed")
                        exit(2)
                    }
                }
        )
        
        dispatchMain()
    }
}


