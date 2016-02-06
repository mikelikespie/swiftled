//
//  ViewController.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//

import UIKit
import RxSwift
import OPC
import RxSwift
import Darwin
import Foundation

let compositeDisposable = CompositeDisposable()

let segmentLength = 27
let segmentCount = 20
let ledCount =  segmentLength * segmentCount



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let disposable = getaddrinfoSockAddrsAsync("raspberrypi.local", servname: "7890")
            .debug()
            .flatMap { sa in
                return sa.connect().catchError { _ in empty() }
            }
            .take(1)
            .subscribe(
                onNext: { sock in
                    let connection = ClientConnection(fd: sock, ledCount: ledCount)
                    self.doStuff(connection)
                    
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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    class Ticker {
        let subject = PublishSubject<Void>()
        
        typealias E = Void
        
        init() {
        }
        
        deinit {
            
        }
        
        @objc func tick() {
            self.subject.onNext()
        }
    }
    
    func ticker(timeInterval: NSTimeInterval) -> Observable<Void> {
        return create { observer in
            let ticker = Ticker()
            let timer = NSTimer(timeInterval: timeInterval, target: ticker, selector: Selector("tick"), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            
            let disposable = ticker.subject.subscribe(observer.on)

            return AnonymousDisposable {
                timer.invalidate()
                disposable.dispose()
                _ = ticker
            }
        }
        
    }
    
    func doStuff(conn: ClientConnection) {
        
//        let ticker = Ticker()
//        let timer = NSTimer.scheduledTimerWithTimeInterval(1.0/60.0, target: ticker, selector: Selector(tick), userInfo: <#T##AnyObject?#>, repeats: <#T##Bool#>)
//        interval(1.0/60, MainScheduler.sharedInstance)
        ticker(1.0/400)
            .flatMap { _ in
                return conn.applyColor { i, now  -> HSV in
                    if i == 0 {
//                        NSLog("Now: \(now)")
                    }
                    let hue: Float = -((Float(now / -30) - Float(i) * 0.25 / Float(ledCount)) % 1.0)
                    let value = 0.5 + 0.5 * sin(Float(now * 2) + Float(M_PI * 2) * Float(i % segmentLength) / Float(segmentLength))
                    return HSV(h: hue, s: 1, v: pow(value, 3))
                }
            }
            .subscribeNext { t in
                
        }
    }

}

//dispatch_main()

