//
//  Shape.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/3/16.
//
//

import Foundation
import OPC
import Cleanse

private enum Direction {
    case Forward
    case Reverse
}

private let edgeToVertices : [(Int, Int)] = [
    (0, 1), // 0
    (0, 2),
    (0, 3),
    (0, 4),
    (0, 5), // 4
    
    (1, 2), // 5
    (2, 3),
    (3, 4),
    (4, 5),
    (5, 1), // 9

    (1, 6), // 10
    (2, 7),
    (3, 8),
    (4, 9),
    (5, 10), // 14
    
    (1, 10), // 15
    (2, 6),
    (3, 7),
    (4, 8),
    (5, 9), // 19
    
    (9, 10), // 20
    (10, 6),
    (6, 7),
    (7, 8),
    (8, 9), // 24

    (9, 10), // 25
    (10, 6),
    (6, 7),
    (7, 8),
    (8, 9), // 29
]


private let segmentMap: [(Direction, Int)] = [
    (.Forward, 0),
    (.Reverse, 2),
    (.Forward, 9),
    (.Reverse, 8),
    (.Forward, 3),
    
    (.Forward, 1),
    (.Forward, 17),
    (.Forward, 10),
    (.Reverse, 7),
    (.Forward, 4),
    
    (.Reverse, 15),
    (.Reverse, 28),
    (.Forward, 18),
    (.Forward, 11),
    (.Reverse, 6),
    
    (.Forward, 5),
    (.Reverse, 16),
    (.Reverse, 29),
    (.Forward, 19),
    (.Reverse, 12),
    
    (.Forward, 13),
    (.Forward, 14),
    (.Forward, 27),
    (.Reverse, 24),
    (.Forward, 20),
    
    (.Forward, 21),
    (.Reverse, 22),
    (.Reverse, 26),
    (.Forward, 25),
    (.Reverse, 23),
]

private let inverseSegmentMap = segmentMap
    .enumerated()
    .sorted { $0.1.1 < $1.1.1 }
    .map { ($0.1.0, $0.0) }

struct ShapeSegmentString : Collection {
    var startIndex: Int  {
        return 0
    }
    
    var endIndex: Int {
        return count - 1
    }
    
    var count: Int {
        return segmentLength * segmentIndexes.count
    }
    
    func index(after i: Int) -> Int {
        return i.advanced(by: 1)
    }
    
    let segmentIndexes: [Int]
    
    unowned let shape: MyShape
    
    let segmentLength: Int
    
    subscript(index: Int) -> RGBFloat {
        get {
            return shape.buffer[bufferIndex(segmentIndex: index)]
        }
        
        set {
            shape.buffer[bufferIndex(segmentIndex: index)] = newValue
        }
    }
    
    private func bufferIndex(segmentIndex: Int) -> Int {
        return segmentIndexes[segmentIndex / segmentLength] * segmentLength + segmentIndex % segmentLength
    }
}


final class MyShape {
    var buffer: [RGBFloat]
    
    let ledCount: Int
    let segmentLength: Int
    let segmentCount: Int
    
    public init(
        ledCount: TaggedProvider<LedCount>,
        segmentLength: TaggedProvider<SegmentLength>,
        segmentCount: TaggedProvider<SegmentCount>) {
        self.ledCount = ledCount.get()
        self.segmentLength = segmentLength.get()
        self.segmentCount = segmentCount.get()
        
        self.buffer = Array(repeating: .black, count: self.ledCount)
    }
    
    func clear() {
        self.buffer.withUnsafeMutableBufferPointer { ptr in
            let ptr = ptr
            applyOverRange(ptr.indices) { bounds in
                for i in bounds {
                    ptr[i] = .black
                }
            }
        }
    }
    
    private func remapLed(_ index: Int) -> Int {
        let virtualSegment = index / segmentLength
        
        let mapping = inverseSegmentMap[virtualSegment]
        
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
    
    
    func withSegment(segment: Int, closure: @noescape (  ptr:  inout UnsafeMutableBufferPointer<RGBFloat>) -> () ) {
        let segmentOffset = segment * segmentLength
        self
            .buffer[segmentOffset..<(segmentOffset + segmentLength)]
            .withUnsafeMutableBufferPointer { ( ptr: inout UnsafeMutableBufferPointer<RGBFloat>) -> () in
                closure(ptr: &ptr)
                
                return ()
        }
    }
    
    
    func withGroup(group: Int, closure: @noescape (  ptr:  inout UnsafeMutableBufferPointer<RGBFloat>) -> () ) {
        let segmentOffset = group * 5 * segmentLength
        self
            .buffer[segmentOffset..<(segmentOffset + segmentLength * 5)]
            .withUnsafeMutableBufferPointer { ( ptr: inout UnsafeMutableBufferPointer<RGBFloat>) -> () in
                closure(ptr: &ptr)
                
                return ()
        }
    }

    
    func withSegments(closure: @noescape (  segment: Int, ptr:  inout UnsafeMutableBufferPointer<RGBFloat>) -> () ) {
        for segment in 0..<segmentCount {
            withSegment(segment: segment) {
                closure(segment: segment, ptr: &$0)
            }
        }
    }
    
    func copyToBuffer(buffer: UnsafeMutableBufferPointer<RGBFloat>) {
        self.buffer.withUnsafeBufferPointer { ptr in
            applyOverRange(buffer.indices) { bounds in
                var buffer = buffer
                
                for idx in bounds {
                    buffer[idx] = ptr[self.remapLed(idx)]
                }
            }
        }
    }
    
    struct Module : Cleanse.Module {
        static func configure<B : Binder>(binder: B) {
            binder.bind().to(factory: MyShape.init)
        }
    }
}
