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
    
    var complement: Direction {
        switch self {
        case .Forward:
            return .Reverse
        case .Reverse:
            return .Forward
        }
    }
}

// Edge in a directional graph
struct Edge : DelegatedHashable {
    var a: Int
    var b: Int
    
    init(a: Int, b: Int) {
        self.a = a
        self.b = b
    }
    
    var hashable: CombinedHashable<Int, Int> {
        return CombinedHashable(a, b)
    }
    
    var complement: Edge {
        return Edge(a: b, b: a)
    }
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

    (9, 11), // 25
    (10, 11),
    (6, 11),
    (7, 11),
    (8, 11), // 29
]

private let edgeToSegmentMappingIndex: [Edge: Int] = {
    var result = [Edge: Int]()
    
    for (i, (a, b)) in edgeToVertices.enumerated() {
        result[Edge(a: a, b: b)] = i
    }
    
    return result
}()

struct Face: DelegatedHashable {
    let a: Int
    let b: Int
    let c: Int
    
    var hashable: CombinedHashable<CombinedHashable<Int, Int>, Int> {
        return CombinedHashable(CombinedHashable(a, b), c)
    }
    
    init(a: Int, b: Int, c: Int) {
        let minVertex = min(a, b, c)
        
        switch minVertex {
        case a:
            self.a = a
            self.b = b
            self.c = c
        case b:
            self.a = b
            self.b = c
            self.c = a
        case c:
            self.a = c
            self.b = a
            self.c = b
        default:
            fatalError()
        }
    }
    var edges: (a: Edge, b: Edge, c: Edge) {
        return (
            Edge(a: a, b: b),
            Edge(a: b, b: c),
            Edge(a: c, b: a)
        )
    }
}


private let allEdges: Set<Edge> = {
    var edges = Set<Edge>(minimumCapacity: edgeToVertices.count * 2)
    
    for e in edgeToVertices {
        let e1 = Edge(a: e.0, b: e.1)
        let e2 = e1.complement
        edges.insert(e1)
        edges.insert(e2)
    }

    return edges
}()

private let edgesByOriginatingVertex: [Set<Int>] = {
    var result = [Set<Int>](repeating: [], count: 12)
    
    for e in allEdges {
        result[e.a].insert(e.b)
    }
    return result
}()


private func calculateAllFaces(edgeToVertices: [(Int, Int)]) -> Set<Face> {
    var result = Set<Face>(minimumCapacity: 40)
    
    for (v_a, edges) in edgesByOriginatingVertex.enumerated() {
        for v_b in edges {
            for v_c in edgesByOriginatingVertex[v_b] {
                guard edgesByOriginatingVertex[v_c].contains(v_a) else {
                    continue
                }
                
                result.insert(Face(a: v_a, b: v_b, c: v_c))
            }
        }
    }
    
    return result
}

private let allFaces = calculateAllFaces(edgeToVertices: edgeToVertices)


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


private func segment(edge: Edge) -> (Direction, Int) {
    let direction: Direction
    let segmentMappingIndex: Int
    
    if let mappingIndex = edgeToSegmentMappingIndex[edge] {
        segmentMappingIndex = mappingIndex
        direction = .Forward
    } else {
        segmentMappingIndex = edgeToSegmentMappingIndex[edge.complement]!
        direction = .Reverse
    }
    
    return (direction, segmentMappingIndex)
}

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
    let faces: [Face]
    
    var faceBuffer: [RGBAFloat]
    var edgeBuffer: [RGBAFloat]
    
    public init(
        ledCount: TaggedProvider<LedCount>,
        segmentLength: TaggedProvider<SegmentLength>,
        segmentCount: TaggedProvider<SegmentCount>) {
        self.ledCount = ledCount.get()
        self.segmentLength = segmentLength.get()
        self.segmentCount = segmentCount.get()
        
        self.buffer = Array(repeating: .black, count: self.ledCount)
        
        self.faceBuffer = Array(repeating: .clear, count: self.segmentLength * 3)
        self.edgeBuffer = Array(repeating: .clear, count: self.segmentLength)
        
        self.faces = Array(allFaces)
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
    
    func withSegment(segment: Int, closure: (  _ ptr:  inout UnsafeMutableBufferPointer<RGBFloat>) -> () ) {
        let segmentOffset = segment * segmentLength
        self
            .buffer[segmentOffset..<(segmentOffset + segmentLength)]
            .withUnsafeMutableBufferPointer { ( ptr: inout UnsafeMutableBufferPointer<RGBFloat>) -> () in
                closure(&ptr)
                
                return ()
        }
    }
    
    
    func withGroup(group: Int, closure: (  _ ptr:  inout UnsafeMutableBufferPointer<RGBFloat>) -> () ) {
        let segmentOffset = group * 5 * segmentLength
        self
            .buffer[segmentOffset..<(segmentOffset + segmentLength * 5)]
            .withUnsafeMutableBufferPointer { ( ptr: inout UnsafeMutableBufferPointer<RGBFloat>) -> () in
                closure(&ptr)
                
                return ()
        }
    }

    func withFace(face: Int, closure: (  _ ptr:  inout UnsafeMutableBufferPointer<RGBAFloat>) -> () ) {
        faceBuffer.replaceSubrange(0..<faceBuffer.count, with: repeatElement(.clear, count: faceBuffer.count))
        
        faceBuffer
            .withUnsafeMutableBufferPointer { ptr in
                closure(&ptr)
        }
        
        let face = self.faces[face]
        
        let (edgeA, edgeB, edgeC) = face.edges

        for (i, edge) in [edgeA, edgeB, edgeC].enumerated() {
            let (direction, segmentIndex) = segment(edge: edge)
            
            let bufferRange = range(segment: segmentIndex)
            let faceBufferRange = range(segment: i)

//            buffer.withUnsafeMutableBufferPointer { ptr in
//                ptr[bufferRange].merge(other: faceBuffer[faceBufferRange])
            //            }
            switch direction {
            case .Forward:
                for (bi, fbi) in zip(bufferRange, faceBufferRange) {
                    buffer[bi] += faceBuffer[fbi]
                }
            case .Reverse:
                for (bi, fbi) in zip(bufferRange, faceBufferRange.reversed()) {
                    buffer[bi] += faceBuffer[fbi]
                }
            }
        }
    }
    
    private func range(segment: Int) -> CountableRange<Int> {
        let segmentStart = segment * segmentLength
        return segmentStart..<(segmentStart + segmentLength)
    }
    
    func withSegments(closure: (  _ segment: Int, _ ptr:  inout UnsafeMutableBufferPointer<RGBFloat>) -> () ) {
        for segment in 0..<segmentCount {
            withSegment(segment: segment) {
                closure(segment, &$0)
            }
        }
    }
    
    
    func withEdges(adjacentToVertex vertex: Int, closure: (_ edge: Edge, _ ptr: inout UnsafeMutableBufferPointer<RGBAFloat>) -> ()) {
        let adjacentVertices = edgesByOriginatingVertex[vertex]
        
        
        for b in adjacentVertices {
            let edge = Edge(a: vertex, b: b)
            
            withEdge(edge: edge) { ptr in
                closure(edge, &ptr)
            }
        }
    }
    func withEdge(edge: Edge, closure: (_ ptr: inout UnsafeMutableBufferPointer<RGBAFloat>) -> ()) {
        edgeBuffer.replaceSubrange(0..<edgeBuffer.count, with: repeatElement(.clear, count: edgeBuffer.count))
        
        edgeBuffer
            .withUnsafeMutableBufferPointer { ptr in
                closure(&ptr)
        }

        let (direction, segmentIndex) = segment(edge: edge)
        
        let bufferRange = range(segment: segmentIndex)

        switch direction {
        case .Forward:
            for (bi, fbi) in zip(bufferRange, edgeBuffer.indices) {
                buffer[bi] += edgeBuffer[fbi]
            }
        case .Reverse:
            for (bi, fbi) in zip(bufferRange, edgeBuffer.indices.reversed()) {
                buffer[bi] += edgeBuffer[fbi]
            }
        }
    }
    
    func copyToBuffer(buffer: UnsafeMutableBufferPointer<RGBFloat>) {
        self.buffer.withUnsafeBufferPointer { ptr in
            applyOverRange(buffer.indices) { bounds in
                let buffer = buffer
                
                for idx in bounds {
                    buffer[idx] = ptr[self.remapLed(idx)]
                }
            }
        }
    }
    
    struct Module : Cleanse.Module {
        static func configure(binder: Binder<Unscoped>) {
            binder.bind().to(factory: MyShape.init)
        }
    }
}
