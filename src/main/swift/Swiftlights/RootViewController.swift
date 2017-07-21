//
//  ViewController.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//

import UIKit
import RxSwift
//import RxCocoa
import Foundation
import Visualizations
import Cleanse
import yoga_YogaKit
import Views

class RootViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    private var typedView: ContentView {
        return scrollView.container
    }
    
    let rootView: Provider<RootView>
    
    init(rootView: Provider<RootView>) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
        self.title = "Swiftlights"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var scrollView: YogaScrollView = self.rootView.get()
    
    override func loadView() {
        self.view = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typedView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        scrollView.addSubview(typedView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
