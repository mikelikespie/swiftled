//
//  STimeVisualization.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/9/16.
//
//

import Foundation
import RxSwift
import Cleanse
import OPC

/// returns [0,1]
func triangle(x: Float) -> Float {
    return x - round(x)
}



func sawtooth(t: Float) -> Float {
    let t = t + 0.5
    return abs(t - Float(Int(t)) - 0.5)
}


public class STimeVisualization : Visualization {
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
    
    
    let lowerHueControl = SliderControl<Float>(bounds: 0..<2, defaultValue: 0, name: "Lower Hue")
    let upperHueControl = SliderControl<Float>(bounds: 0..<2, defaultValue: 1.0 / 6.0, name: "Upper Hue")
    
    let speed1 = SliderControl<Float>(bounds: -3..<10, defaultValue: 20, name: "Speed 1")
    
    public var controls: Observable<[Control]> {
        return Observable.just(
            [
                lowerHueControl,
                upperHueControl,
                speed1,
             ]
        )
    }
    
    
    public let name = "0-SxTime"
    
    public func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        let shape = shapeProvider.get()
        
        return ticker.subscribeNext { context in
            shape.clear()
            
            let rangeDelta = max(0, self.upperHueControl.value - self.lowerHueControl.value)
            let lowerHue = self.lowerHueControl.value
            
            for (vertexIndex, value) in (0..<12).enumerated() {
                shape.withEdges(adjacentToVertex: value) { edge, ptr in
                    let totalLength = self.segmentLength 
                    let timeOffset = context.tickContext.timeOffset * 0.125 * Double(self.speed1.value)
                    
                    for i in 0..<(ptr.count / 3) {
                        
                        let tt = (Float(i) / Float(totalLength) + Float(timeOffset) + (Float(vertexIndex) / 3))

                        let h = (lowerHue + sawtooth(t: tt) * rangeDelta).truncatingRemainder(dividingBy: 1.0)
                        
                        ptr[i] = HSV(
                            h: h,
                            s: 1.0,
                            v: 1.0
                            )
                            .rgbFloat
                            .with(alpha: 1.0)
                    }
                }
            }
            
            shape.copyToBuffer(buffer: context.writeBuffer)
        }
    }
}
