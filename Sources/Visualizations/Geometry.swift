//
//  Geometry.swift
//  swiftled-2
//
//  Created by Michael Lewis on 8/1/16.
//
//
#if false
import Foundation

#if os(Linux)
import OPC
#else
    import simd
#endif

let icosohedronPoints: [float3] = [
    .init(0.000,  0.000,  1.000),
    .init(0.894,  0.000,  0.447),
    .init(0.276,  0.851,  0.447),
    .init(-0.724,  0.526,  0.447),
    .init(-0.724, -0.526,  0.447),
    .init(0.276, -0.851,  0.447),
    .init(0.724,  0.526, -0.447),
    .init(-0.276,  0.851, -0.447),
    .init(-0.894,  0.000, -0.447),
    .init(-0.276, -0.851, -0.447),
    .init(0.724, -0.526, -0.447),
    .init(0.000,  0.000, -1.000),
]


let icosohedronFaces: [Face] = [
    (0,1,2),
    (0,2,3),
    (0,3,4),
    (0,4,5),
    (0,5,1),
    (11,6,7),
    (11,7,8),
    (11,8,9),
    (11,9,10),
    (11,10,6),
    (1,2,6),
    (2,3,7),
    (3,4,8),
    (4,5,9),
    (5,1,10),
    (6,7,2),
    (7,8,3),
    (8,9,4),
    (9,10,5),
    (10,6,1),
]

func makeIcosohedronPoints(edgeLength: Int) -> [float3] {
    var result = [float3]()
    result.reserveCapacity(edgeLength * 30)
    
    iterateIcosohedronEdges { (a, b) in
        doInterpolate(a: a, b: b, steps: edgeLength, out: &result)
    }
    
    return result
}

private func iterateIcosohedronEdges(iterator: @noescape (a: float3, b: float3) -> ()) {
    var seenEdges = Set<Edge>()
    
    for face in icosohedronFaces {
        iterateFaceEdges(face: face) { edge in
            if seenEdges.contains(edge) {
                return
            }
            defer { seenEdges.insert(edge) }
            
            iterator(a: icosohedronPoints[edge.a], b: icosohedronPoints[edge.b])
        }
    }
}

private func iterateFaceEdges(face: Face, block: @noescape (Edge) -> ()) {
    block(Edge(a: face.0, b: face.1))
    block(Edge(a: face.1, b: face.2))
    block(Edge(a: face.2, b: face.0))
}

private func doInterpolate(a: float3, b: float3, steps: Int, out: inout [float3]) {
    let floatSteps = Float(steps)
    for i in 0..<steps {
        out.append(mix(a, b, t: Float(i) / floatSteps))
    }
}

#endif
