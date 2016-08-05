//: Playground - noun: a place where people can play

import Visualizations
import OPC
import PlaygroundSupport
import RxSwift
import Darwin
import Cleanse
import Dispatch

var str = "Hello, playground"


PlaygroundPage.current.needsIndefiniteExecution = true


let compositeDisposable = CompositeDisposable()

let serialQueue = DispatchQueue(label: "MyQueue", attributes: [], target: nil)

let defaultScheduler = SerialDispatchQueueScheduler(queue: serialQueue, internalSerialQueueName: "MyQueue")

try! ComponentFactory
    .of(SwiftLedComponent.self)
    .build(seed: LedConfiguration(segmentLength: 18, segmentCount: 30))
    .run()
