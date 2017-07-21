//
//  LayoutDirtier.swift
//  swiftled
//
//  Created by Michael Lewis on 7/20/17.
//
//

import UIKit
import RxSwift

public class LayoutDirtier {
    public init() {
    }
    
    public var observable: Observable<Void> {
        return subject
    }
    
    private let subject = PublishSubject<Void>()
    
    public func markAsDirty() {
        subject.onNext()
    }
}
