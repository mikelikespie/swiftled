import OPC
import RxSwift
import Foundation
import Dispatch
import Cleanse
import Visualizations

let compositeDisposable = CompositeDisposable()

let segmentLength = 18
let segmentCount = 30
let ledCount =  segmentLength * segmentCount

let serialQueue = DispatchQueue(label: "MyQueue", attributes: .serial, target: nil)

let defaultScheduler = SerialDispatchQueueScheduler(queue: serialQueue, internalSerialQueueName: "MyQueue")



try! ComponentFactory
    .of(SwiftLedComponent.self)
    .build(seed: LedConfiguration(segmentLength: 18, segmentCount: 30))
    .run()
