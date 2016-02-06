import OPC
import RxSwift
import Darwin
import Foundation

let compositeDisposable = CompositeDisposable()

let segmentLength = 18
let segmentCount = 30
let ledCount =  segmentLength * segmentCount

func doStuff(conn: ClientConnection) {
    interval(1.0/600, MainScheduler.sharedInstance)
        //.debug()
        .subscribeNext { t in
            conn.applyColor { i, now  -> HSV in
                let hue: Float = (Float(now / 5) + Float(i * 2) / Float(ledCount)) % 1.0
					let value = 0.5 + 0.5 * sin(Float(now * 2) + Float(M_PI * 2) * Float(i % segmentLength) / Float(segmentLength))
                return HSV(h: hue, s: 1, v: value * value)
            }
            
    }
}


let disposable = getaddrinfoSockAddrsAsync("raspberrypi.local", servname: "7890")
    .debug()
    .flatMap { sa in
        return sa.connect().catchError { _ in empty() }
    }
    .take(1)
    .subscribe(
        onNext: { sock in
            let connection = ClientConnection(fd: sock, ledCount: ledCount)
            doStuff(connection)
            
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
dispatch_main()

