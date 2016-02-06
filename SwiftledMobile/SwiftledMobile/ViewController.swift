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



class ViewController: UISplitViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startVisualization(SimpleVisualization(), fps: 400)
            .addDisposableTo(disposeBag)
    }
}

class SimpleVisualization : Visualization {
    let controls = Observable<[Control]>.empty()
    let name = Observable<String>.just("Simple visualization")
    
    func bind(ticker: Observable<WriteContext>) -> Disposable {
        return ticker.subscribeNext { context in
            let writeBuffer = context.writeBuffer
            
            let now = context.tickContext.timeOffset
            
            for i in writeBuffer.startIndex..<writeBuffer.endIndex {
                let hue: Float = -((Float(now / -30) - Float(i) * 0.25 / Float(ledCount)) % 1.0)
                let value = 0.5 + 0.5 * sin(Float(now * 2) + Float(M_PI * 2) * Float(i % segmentLength) / Float(segmentLength))
                writeBuffer[i] = HSV(h: hue, s: 1, v: pow(value, 3)).rgbFloat
            }
        }
    }
}
