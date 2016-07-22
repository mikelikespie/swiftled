import OPC
import RxSwift
import Foundation
import Dispatch

let compositeDisposable = CompositeDisposable()

let segmentLength = 18
let segmentCount = 30
let ledCount =  segmentLength * segmentCount

let serialQueue = DispatchQueue(label: "MyQueue", attributes: .serial, target: nil)

let defaultScheduler = SerialDispatchQueueScheduler(queue: serialQueue, internalSerialQueueName: "MyQueue")

func doStuff(conn: ClientConnection) {
    
    let timeInterval: RxTimeInterval = 1.0/600.0
    
    
    Observable<Int>.interval(timeInterval / 1000, scheduler: defaultScheduler)
        .debug("OMGOMG")
        .subscribeNext { _ in
            
            serialQueue.after(when: .now() + .seconds(3)) { NSLog("After 3 seconds!!!") }
            
            NSLog("hey hey hey")
    }
    
    Observable<Int>.interval(timeInterval, scheduler: SerialDispatchQueueScheduler(internalSerialQueueName: "Queue"))
        .debug("OMGOMG")
        .subscribeNext { _ in
            NSLog("pew")
            conn.apply { i, now  -> HSV in
                let hue: Float = (Float(now / 5) + Float(i * 2) / Float(ledCount)).truncatingRemainder(dividingBy: 1.0)
					let value = 0.5 + 0.5 * sin(Float(now * 2) + Float(M_PI * 2) * Float(i % segmentLength) / Float(segmentLength))
                return HSV(h: hue, s: 1, v: value * value)
            }
            
    }
}
//
//
let disposable = getaddrinfoSockAddrsAsync("pi0.local", servname: "7890")
    .debug("getaddrinfoSockAddrsAsync")
    .flatMap { sa in
        return sa.connect().catchError { _ in .empty() }
    }
    .take(1)
    .subscribe(
        onNext: { sock in
            let connection = ClientConnection(fd: sock, ledCount: ledCount, mode: .rgbaRaw)
            
            doStuff(conn: connection)
        },
        onError: { error in
            NSLog("failed \(error) \((error as? POSIXError)?.rawValue)")
//            page.finishExecution()
            
        },
        onCompleted: {
//            page.finishExecution()
        }
)


#if os(Linux)
    
    @_silgen_name("dispatch_main")
    func dispatchMain()

#endif
dispatchMain()

