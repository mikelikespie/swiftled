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
    let visualization: BaseVisualization
    let configuration: LedConfiguration
    
    private func doStuff() -> Disposable {
        return ledRunner.startVisualization(visualization, fps: 400)
    }
    
    func start() -> Disposable {
        return doStuff()
    }
}

