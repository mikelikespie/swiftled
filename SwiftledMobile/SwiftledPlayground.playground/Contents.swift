//: Playground - noun: a place where people can play

import UIKit
import OPC
import XCPlayground
import RxSwift
import Darwin


var str = "Hello, playground"


let page = XCPlayground.XCPlaygroundPage.currentPage
page.needsIndefiniteExecution = true

let compositeDisposable = CompositeDisposable()

let segmentLength = 18
let segmentCount = 30
let ledCount =  segmentLength * segmentCount

func doStuff(conn: ClientConnection) {
    interval(1.0/20.0, MainScheduler.sharedInstance)
        .debug()
        .subscribeNext { t in
            conn.applyColor { i, now  -> HSV in
                let hue: Float = (Float(now / 15) + Float(i) / Float(ledCount)) % 1.0
                return HSV(h: hue, s: 1, v: 1)
            }
            
    }
}

M_PI_2
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
