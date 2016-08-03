//
//  SwiftLedEntryPoint.swift
//  swiftled-2
//
//  Created by Michael Lewis on 7/29/16.
//
//

import Foundation
import OPC
import RxSwift
import Cleanse

struct SwiftLedEntryPoint : EntryPoint {
    let ledRunner: VisualizationRunner
    let visualization: Visualization
    let configuration: LedConfiguration
    
    private func doStuff() -> Disposable {
        return ledRunner.startVisualization(visualization, fps: 200)
    }
    
    func start() -> Disposable {
        return doStuff()
    }
}

