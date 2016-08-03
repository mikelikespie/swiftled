import OPC
import RxSwift
import Foundation
import Dispatch
import Cleanse
import Visualizations

let compositeDisposable = CompositeDisposable()

private let segmentLength = 18
private let segmentCount = 30
private let ledCount =  segmentLength * segmentCount

let serialQueue = DispatchQueue(label: "MyQueue", attributes: .serial, target: nil)

let defaultScheduler = SerialDispatchQueueScheduler(queue: serialQueue, internalSerialQueueName: "MyQueue")

try! ComponentFactory
    .of(SwiftLedComponent.self)
    .build(seed: LedConfiguration(segmentLength: segmentLength, segmentCount: segmentCount))
    .run()


dispatchMain()
