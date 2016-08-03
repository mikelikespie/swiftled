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

class SimpleVisualization : Visualization {
    let brightnessControl: BrightnessControl.Element
    
    let gammaControl = SliderControl<Float>(bounds: 1.0..<4.0, defaultValue: 2.4, name: "Gamma")
    let timeMultiplier = SliderControl<Float>(bounds: -10.0..<10.0, defaultValue: 1, name: "Time Multiplier")
    
    let ledCount: Int
    let segmentLength: Int
    
    public var controls: Observable<[Control]> {
        return Observable.just([
            brightnessControl,
            gammaControl,
            timeMultiplier,
            ])
    }
    
    init(
        ledCount: TaggedProvider<LedCount>,
        segmentLength: TaggedProvider<SegmentLength>,
        brightnessControl: TaggedProvider<BrightnessControl>) {
        self.ledCount = ledCount.get()
        self.segmentLength = segmentLength.get()
        self.brightnessControl = brightnessControl.get()
    }
    
    public let name = "Simple"
    
    public func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        let ledCount = self.ledCount
        let segmentLength = self.segmentLength
        var offset = 0.0
        
        
        return ticker.subscribeNext { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            
            let gammaControlValue = self.gammaControl.value
            let brightnessControlValue = self.brightnessControl.value
            
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
                    writeBuffer[i] = HSV(
                        h: hue,
                        s: 1,
                        v: value
                        )
                        .rgbFloat
                        .gammaAdjusted(gammaControlValue) * pow(brightnessControlValue, 2)
                }
            }
        }
    }
}
