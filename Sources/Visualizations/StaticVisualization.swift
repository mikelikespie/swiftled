//
//  IdentificationVisualization.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/1/16.
//
//

import Foundation

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


#if os(Linux)
    import Glibc
#else
    import Darwin
#endif


public class StaticVisualization : Visualization {
    let ledCount: Int
    let segmentLength: Int
    let segmentCount: Int
    let shapeProvider: Provider<MyShape>
    
    
    init(
        ledCount: TaggedProvider<LedCount>,
        segmentLength: TaggedProvider<SegmentLength>,
        segmentCount: TaggedProvider<SegmentCount>,
        shapeProvider: Provider<MyShape>) {
        self.ledCount = ledCount.get()
        self.segmentLength = segmentLength.get()
        self.segmentCount = segmentCount.get()
        
        self.shapeProvider = shapeProvider
    }
    
    
    let staticHalflife = SliderControl<Float>(bounds: 0.125..<50, defaultValue: 10, name: "Static Lambda")
    let smoothingHalflife = SliderControl<Float>(bounds: 0.01..<3, defaultValue: 1.15, name: "Smoothing Lambda")

    public var controls: Observable<[Control]> {
        return Observable.just([
            staticHalflife,
            smoothingHalflife,
        ])
    }
    
    
    public let name = "Static"
    
    public func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        let shape = shapeProvider.get()
        
        // Just
        var buf1 = [RGBFloat](repeating: .black, count: ledCount)
        var buf2 = buf1
        
        
        func withCurrentBuffer(closure: (
            _ currentBuffer: inout [RGBFloat],
            _ lastBuffer: inout [RGBFloat]) -> Void) {
            closure(&buf1, &buf2)
        }
        
        
        return ticker.subscribe(onNext: { context in
            shape.clear()
            let timeSinceLastSwitch = Float(context.tickContext.timeDelta)
            let staticLambda = self.staticHalflife.value
            let lambda = self.smoothingHalflife.value * staticLambda

            let writeBuffer = context.writeBuffer
            
            let flipProbability = exp(-staticLambda * timeSinceLastSwitch)
            
            let arc4Threshold = UInt32(Float(UInt32.max) * flipProbability)
            
            let mix = exp(-lambda * timeSinceLastSwitch)

            withCurrentBuffer { currentBuffer, lastBuffer in
                for i in currentBuffer.indices {
                    let currentColor = currentBuffer[i]
                    let newColor = currentColor.mix(other: lastBuffer[i], ratio: 1.0 - mix)
                    
                    writeBuffer[i] = newColor
                    lastBuffer[i] = newColor
                    
                    let shouldFlip = arc4random() > arc4Threshold
                    
                    if shouldFlip {
                        
                        var randomColor = HSV(
                            h: Float(arc4random()) / Float(UInt32.max),
                            s: 1.0,
                            v: Float(arc4random()) / Float(UInt32.max)
                        ).rgbFloat
                        
                        randomColor.g *= randomColor.g
                        
                        currentBuffer[i] = randomColor
                    }
                }
            }
        })
    }
}
