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
    
    
    public static func configureRoot(binder bind: ReceiptBinder<BaseVisualization>) -> BindingReceipt<BaseVisualization> {
        return bind.to(factory: IdentificationVisualization.init)
    }

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
    
    
    let segmentControls = (0..<6).map { SliderControl<Int>(bounds: 0..<30, defaultValue: 5 * $0, name: "Segment \($0)") }
    let faceControl = SliderControl<Int>(bounds: 0..<40, defaultValue: 0, name: "Face")
    let vertexControls = (0..<3).map { SliderControl<Int>(bounds: 0..<12, defaultValue: $0 * 4, name: "Vertex \($0)") }
    let groupControl = SliderControl<Int>(bounds: 0..<6, defaultValue: 0, name: "Group")
    
    let speed1 = SliderControl<Float>(bounds: -3..<3, defaultValue: 1.1, name: "Speed 1")
    let speed2 = SliderControl<Float>(bounds: -3..<3, defaultValue: 1.0, name: "Speed 2")
    
    public var controls: Observable<[Control]> {
        return Observable.just(
            segmentControls.map { $0 as Control } as [Control]
                + [
                    faceControl,
                    groupControl,
                    ] as [Control]
                + (vertexControls.map { $0 as Control } as [Control])
                + ([
                    speed1,
                    speed2,
            ] as [Control])
        )
    }
    
    
    public let name = "Identification"
    
    public func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        let shape = shapeProvider.get()
        
        return ticker.subscribe(onNext: {context in
            shape.clear()
            
            for (i, c) in self.segmentControls.enumerated() {
                shape.withSegment(segment: c.value, closure: { (ptr) in
                    let hue = Float(i) / Float(self.segmentControls.count)
                    ptr.merge(other: ptr.indices.map {
                        HSV(h: hue, s: 1, v: 1).rgbFloat.with(alpha: Float($0) / Float(ptr.count) * 0.4)
                    })
                })
            }
            
//            shape.withFace(face: self.faceControl.value) { ptr in
//                let totalLength = self.segmentLength * 3
//                let timeOffset = context.tickContext.timeOffset
//                
//                for i in ptr.indices {
//                    ptr[i] = HSV(
//                        h: (Float(i) / Float(totalLength) + Float(timeOffset))
//                            .truncatingRemainder(dividingBy: 1.0),
//                        s: 1.0,
//                        v: 1.0
//                        )
//                        .rgbFloat
//                        .with(alpha: 0.3)
//                }
//            }
            
            for (vertexIndex, value) in self.vertexControls.map({ $0.value }).enumerated() {
                shape.withEdges(adjacentToVertex: value) { edge, ptr in
                    let totalLength = self.segmentLength * 3
                    let timeOffset = context.tickContext.timeOffset * 0.125
                    
                    for i in 0..<(ptr.count / 3) {
                        ptr[i] = HSV(
                            h: (Float(i) / Float(totalLength) + Float(timeOffset) + (Float(vertexIndex) / 3))
                                .truncatingRemainder(dividingBy: 1.0),
                            s: 1.0,
                            v: 0.8
                            )
                            .rgbFloat
                            .with(alpha: 1.0)
                    }
                }
            }

            shape.copyToBuffer(buffer: context.writeBuffer)
        })
    }
}
