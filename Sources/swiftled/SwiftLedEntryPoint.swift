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

struct SwiftLedEntryPoint : EntryPoint {
    private func doStuff(conn: ClientConnection) {
        
        let timeInterval: RxTimeInterval = 1.0/600.0
        
        serialQueue.after(when: .now() + .seconds(3)) { NSLog("!!After 3 seconds!!!") }
        
        //    Observable<Int>.interval(timeInterval / 1000, scheduler: defaultScheduler)
        //        .debug("OMGOMG333")
        //        .subscribeNext { _ in
        //
        //            serialQueue.after(when: .now() + .seconds(3)) { NSLog("After 3 seconds!!!") }
        //
        //            NSLog("hey hey hey")
        //    }
        //
        Observable
            .interval(timeInterval, scheduler: defaultScheduler)
            .subscribeNext { (tick: IntMax) in
                conn.apply { i, now  -> HSV in
                    let hue: Float = (Float(now / 5) + Float(i * 2) / Float(ledCount)).truncatingRemainder(dividingBy: 1.0)
                    let value = 0.5 + 0.5 * sin(Float(now * 2) + Float(M_PI * 2) * Float(i % segmentLength) / Float(segmentLength))
                    return HSV(h: hue, s: 1, v: value * value)
                }
                
                _ = conn.flush()
                
                if tick % 1000 == 0 {
                    NSLog("Still alive after \(tick) frames")
                }
        }
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


