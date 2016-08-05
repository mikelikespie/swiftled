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

public class IdentificationVisualization : Visualization {
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
        
        print(makeIcosohedronPoints(edgeLength: 18))
    }
    
    
    let segmentControls = (0..<6).map { SliderControl<Int>(bounds: 0..<30, defaultValue: 5 * $0, name: "Segment \($0)") }
    let groupControl = SliderControl<Int>(bounds: 0..<6, defaultValue: 0, name: "Group")
    
    let speed1 = SliderControl<Float>(bounds: -3..<3, defaultValue: 1.1, name: "Speed 1")
    let speed2 = SliderControl<Float>(bounds: -3..<3, defaultValue: 1.0, name: "Speed 2")

    public var controls: Observable<[Control]> {
        return Observable.just(
            segmentControls.map { $0 as Control } +
                [
            groupControl,
            speed1,
            speed2,
            ])
    }
    
    
    public let name = "Identification"
    
    public func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        let shape = shapeProvider.get()
        
        return ticker.subscribeNext { context in
            shape.clear()
            
            
            for (i, c) in self.segmentControls.enumerated() {
                shape.withSegment(segment: c.value, closure: { (ptr) in
                    let hue = Float(i) / Float(self.segmentControls.count)
                    ptr.merge(other: ptr.indices.map {
                        HSV(h: hue, s: 1, v: 1).rgbFloat.with(alpha: Float($0) / Float(ptr.count) * 0.75)
                    })
                })
            }
//            shape
//                .withGroup(group: 1) { ptr in
//                let doubleCnt = TimeInterval(ptr.count)
//                let tOffset = (context.tickContext.timeOffset * Double(self.speed1.value) ).truncatingRemainder(dividingBy: 1.0)
//                
//                for idx in ptr.indices {
//                    let offset = Double(idx) / doubleCnt
//                    
//                    let distance = Float(
//                        min(
//                            min(
//                                abs(offset - tOffset),
//                                abs(offset - (tOffset + 1.0))
//                                ) as Double,
//                            abs((offset + 1.0) - tOffset)
//                        )
//                    )
//                    
//                    let brightness = min(1.0, 0.0001 * distance / (distance * distance * distance))
//                    
//                    ptr[idx] += RGBFloat.red.with(alpha: brightness)
//                }
//            }
//
//            shape.withGroup(group: 4) { ptr in
//                let doubleCnt = TimeInterval(ptr.count)
//                let tOffset = (context.tickContext.timeOffset * Double(self.speed2.value) ).truncatingRemainder(dividingBy: 1.0)
//                
//                for idx in ptr.indices {
//                    let offset = Double(idx) / doubleCnt
//                    
//                    let distance = Float(
//                        min(
//                            min(
//                                abs(offset - tOffset),
//                                abs(offset - (tOffset + 1.0))
//                                ) as Double,
//                            abs((offset + 1.0) - tOffset)
//                        )
//                    )
//                    
//                    let brightness = min(1.0, 0.0001 * distance / (distance * distance * distance))
//                    
//                    ptr[idx] += RGBFloat(r: 0.5, g: 0, b: 1).with(alpha: brightness)
//                }
//                
//            }
            
            shape.copyToBuffer(buffer: context.writeBuffer)
        }
    }
}
