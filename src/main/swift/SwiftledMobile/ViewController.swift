//
//  ViewController.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//

import UIKit
import RxSwift
import OPC
//import RxCocoa
import Foundation
import Visualizations
import Cleanse
import yoga_YogaKit

private let segmentLength = 18
private let segmentCount = 30
private let ledCount =  segmentLength * segmentCount

class ViewController: UIViewController, UISplitViewControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    private var typedView: ContentView {
        return scrollView.container
    }
    private lazy var scrollView: YogaScrollView = YogaScrollView()

    override func loadView() {
        self.view = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typedView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        scrollView.addSubview(typedView)

        self.splitViewController?.delegate = self
        
        let root = try! ComponentFactory
            .of(SwiftLedComponent.self)
            .build(LedConfiguration(
                segmentLength: segmentLength,
                segmentCount: segmentCount
            ))
        
        root
            .entryPoint
            .start()
            .addDisposableTo(disposeBag)
        
        root.rootVisualization
            .controls
            .map { Array($0.map { $0.cells }.joined()) }
            .subscribe(onNext: { [unowned self] cells in
                self.scrollView.cells = cells
             })
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
