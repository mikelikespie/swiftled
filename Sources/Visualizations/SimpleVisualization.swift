//
//  SimpleVisualization.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import RxSwift
import Cleanse
import OPC

public class SimpleVisualization : Visualization {
    let brightnessControl = SliderControl(bounds: 0.0...1.0, defaultValue: 1.0, name: "Brightness")
    let gammaControl = SliderControl(bounds: 1.0...4.0, defaultValue: 2.4, name: "Gamma")
    let timeMultiplier = SliderControl(bounds: -10...10.0, defaultValue: 1, name: "Time Multiplier")
    
    let ledCount: Int
    let segmentLength: Int
    
    public var controls: Observable<[Control]> {
        return Observable.just([
            brightnessControl,
            gammaControl,
            timeMultiplier,
            ])
    }
    
    public init(
        ledCount: TaggedProvider<LedCount>,
        segmentLength: TaggedProvider<SegmentLength>) {
        self.ledCount = ledCount.get()
        self.segmentLength = segmentLength.get()
    }
    
    public let name = Observable<String>.just("Simple visualization")
    
    public func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        
        let ledCount = self.ledCount
        let segmentLength = self.segmentLength
        var offset = 0.0
        return ticker.subscribeNext { context in
            let writeBuffer = context.writeBuffer
            
            offset += context.tickContext.timeDelta * Double(self.timeMultiplier.value)
            let now = offset
            
            applyOverRange(writeBuffer.startIndex..<writeBuffer.endIndex) { bounds in
                for i in bounds {
                    var hueNumerator =  -((Float(now / -30) - Float(i) * 0.25 / Float(ledCount)))
                    
                    if hueNumerator < 0 {
                        hueNumerator += -floor(hueNumerator)
                        precondition(hueNumerator >= 0)
                    }
                    
                    let hue: Float = hueNumerator.truncatingRemainder(dividingBy:  1.0)
                    let portion = Float(i % segmentLength) / Float(segmentLength)
                    let value = 0.5 + 0.5 * sin(Float(now * 2) + Float(M_PI * 2) * portion)
                    writeBuffer[i] = HSV(h: hue, s: 1, v: value).rgbFloat.gammaAdjusted(self.gammaControl.value) * pow(self.brightnessControl.value, 2)
                }
            }
        }
    }
}
