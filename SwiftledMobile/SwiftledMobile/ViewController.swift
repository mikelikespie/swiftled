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
import RxSwift
import Darwin
import Foundation

let compositeDisposable = CompositeDisposable()

let segmentLength = 27
let segmentCount = 20
let ledCount =  segmentLength * segmentCount


class ViewController: UITableViewController, UISplitViewControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    private var cells = [UITableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.splitViewController?.delegate = self
        
        
        let rootVisualization = SimpleVisualization()
        startVisualization(rootVisualization, fps: 400)
            .addDisposableTo(disposeBag)
        
        rootVisualization
            .controls
            .map { Array($0.map { $0.cells }.flatten()) }
            .subscribeNext { [unowned self] cells in
                self.cells = cells
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    
    private var collapseDetailViewController = true

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseDetailViewController = false
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}


class SliderCell : UITableViewCell {
    var slider: UISlider!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        slider = UISlider(frame: contentView.bounds)
        
        contentView.addSubview(slider)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SliderControl : Control {
    let name: String
    
    let sliderCell = SliderCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
    
    
    var value: Float {
        return sliderCell.slider.value
    }
    
    var cells: [UITableViewCell] {
        return [sliderCell]
    }
    
    init(bounds: ClosedInterval<Float>, defaultValue: Float, name: String) {
        self.name = name
        sliderCell.slider.minimumValue = bounds.start
        sliderCell.slider.maximumValue = bounds.end
        sliderCell.slider.value = defaultValue
    }
    
    func run(ticker: Observable<TickContext>) -> Disposable {
        return NopDisposable.instance
    }
}

class SimpleVisualization : Visualization {
    let brightnessControl = SliderControl(bounds: 0.0...1.0, defaultValue: 1.0, name: "Brightness")
    let gammaControl = SliderControl(bounds: 1.0...4.0, defaultValue: 2.4, name: "Gamma")
    let timeMultiplier = SliderControl(bounds: -10...10.0, defaultValue: 1, name: "Time Multiplier")
    
    var controls: Observable<[Control]> {
        return Observable.just([
            brightnessControl,
            gammaControl,
            timeMultiplier,
        ])
    }
    
    let name = Observable<String>.just("Simple visualization")
    
    func bind(ticker: Observable<WriteContext>) -> Disposable {
        
        var offset = 0.0
        return ticker.subscribeNext { context in
            let writeBuffer = context.writeBuffer
            
            offset += context.tickContext.timeDelta * Double(self.timeMultiplier.value)
            let now = offset
            
            applyOverRange(writeBuffer.startIndex..<writeBuffer.endIndex) { bounds in
                for i in bounds {
                    var hueNumerator =  -((Float(now / -30) - Float(i) * 0.25 / Float(ledCount)))
                    
                    if hueNumerator < 0 {
                        hueNumerator += -floor(hueNumerator)
                        precondition(hueNumerator >= 0)
                    }
                    let hue: Float = hueNumerator % 1.0
                    let value = 0.5 + 0.5 * sin(Float(now * 2) + Float(M_PI * 2) * Float(i % segmentLength) / Float(segmentLength))
                    writeBuffer[i] = HSV(h: hue, s: 1, v: value * self.brightnessControl.value).rgbFloat.gammaAdjusted(self.gammaControl.value)
                }
            }
        }
    }
}
