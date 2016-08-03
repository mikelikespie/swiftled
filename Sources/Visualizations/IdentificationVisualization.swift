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
    
    public var controls: Observable<[Control]> {
        return Observable.just([])
    }
    
    public init(
        ledCount: TaggedProvider<LedCount>,
        segmentLength: TaggedProvider<SegmentLength>,
        segmentCount: TaggedProvider<SegmentCount>) {
        self.ledCount = ledCount.get()
        self.segmentLength = segmentLength.get()
        self.segmentCount = segmentCount.get()
        
        print(makeIcosohedronPoints(edgeLength: 18))
    }
    
    public let name = "Identification"
    
    enum Direction {
        case Forward
        case Reverse
    }
    
    let segmentMap: [Int: (Direction, Int)] = [
        0: (.Forward, 0),
        1: (.Reverse, 2),
        2: (.Forward, 9),
        3: (.Reverse, 8),
        4: (.Forward, 3),
        
        5: (.Forward, 1),
        6: (.Forward, 17),
        7: (.Forward, 10),
        8: (.Reverse, 7),
        9: (.Forward, 4),
        
        10: (.Reverse, 15),
        11: (.Reverse, 28),
        12: (.Forward, 18),
        13: (.Forward, 11),
        14: (.Reverse, 6),
        
        15: (.Forward, 5),
        16: (.Reverse, 16),
        17: (.Reverse, 29),
        18: (.Forward, 19),
        19: (.Reverse, 12),

        20: (.Forward, 13),
        21: (.Forward, 14),
        22: (.Forward, 27),
        23: (.Reverse, 24),
        24: (.Forward, 20),

        25: (.Reverse, 23),
        26: (.Forward, 21),
        27: (.Reverse, 22),
        28: (.Reverse, 26),
        29: (.Forward, 25),
    ]
    
    private func remapLed(_ index: Int) -> Int? {
        let virtualSegment = index / segmentLength
        
        
        guard let mapping = segmentMap[virtualSegment] else {
            return nil
        }
        
        let segmentOffset: Int
        let physicalSegment: Int
        
        switch mapping {
        case let (.Forward, physicalSegment_):
            physicalSegment = physicalSegment_
            segmentOffset = index % segmentLength
        case let (.Reverse, physicalSegment_):
            physicalSegment = physicalSegment_
            segmentOffset = segmentLength - (index % segmentLength) - 1
        }
        
        
        return physicalSegment * segmentLength + segmentOffset
    }
    
    public func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        let segmentLength = self.segmentLength
        
        return ticker.subscribeNext { context in
            let writeBuffer = context.writeBuffer
            
            let segmentToIdentify = 0
            
//            let segmentToIdentify = context.tickContext.tickIndex % self.segmentCount
//            let segmentToIdentify = 28
            
            applyOverRange(writeBuffer.startIndex..<writeBuffer.endIndex) { bounds in
                for i in bounds {
                    
                    let i2 = (Int(context.tickContext.timeOffset * 50) + i) % self.ledCount
                    
                    let segment = i2 / segmentLength
                    let segmentOffset = i2 % segmentLength
                    
                    let color: RGBFloat
                    if segment == segmentToIdentify {
                        if segmentOffset < self.segmentLength / 4 {
                            color = RGBFloat(r: 0.1, g: 0.0, b: 0.05)
                        } else if segmentOffset > self.segmentLength * 3 / 4 {
                            color = RGBFloat(r: 0.1, g: 0.0, b: 0)

                        } else {
                            color = .black
                        }
                    } else if segment == 9 && segmentOffset == 8 {
                        color = RGBFloat(r: 0, g: 0, b: 0.4)
                    } else if segment == 19 && segmentOffset == 8 {
                        color = RGBFloat(r: 0, g: 0.2, b: 0.0)
                    }else if segment < segmentToIdentify {
                        color = RGBFloat(r: 0.2, g: 0.2, b: 0.2)
                    } else {
                        color = .black
                    }
                    
                    if let remapped = self.remapLed(i) {
                        writeBuffer[remapped] = color
                    } else if self.segmentMap.values.filter({$0.1 == segment}).first == nil {
                        writeBuffer[i] = color
                    }
                }
            }
        }
    }
}
