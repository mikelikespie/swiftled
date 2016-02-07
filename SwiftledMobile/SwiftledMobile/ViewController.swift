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
import RxCocoa
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
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
    var label: UILabel!
    var name: String
    
    private var disposeBag = DisposeBag()
    
    init(bounds: ClosedInterval<Float>, defaultValue: Float, name: String) {
        self.name = name
        super.init(style: .Default, reuseIdentifier: nil)
        
        label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        slider = UISlider()
        
        slider.minimumValue = bounds.start
        slider.maximumValue = bounds.end

        label.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(slider)
        contentView.addSubview(label)
        
        slider.value = defaultValue
        slider
            .rx_value
            .subscribeNext { [unowned self] value in
                self.label.text = "\(self.name): \(value)"
            }
            .addDisposableTo(disposeBag)
        
        let constraints = [
            NSLayoutConstraint(item: slider, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slider, attribute: .Bottom, relatedBy: .Equal, toItem: label, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0),
            ] + ([label, slider] as [UIView]).flatMap {
                [
                    NSLayoutConstraint(item: $0, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: $0, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .TrailingMargin, multiplier: 1, constant: 0),
                ]
        }
        
        NSLayoutConstraint.activateConstraints(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SliderControl : Control {
    let name: String
    
    let sliderCell: SliderCell
    
    var value: Float {
        return sliderCell.slider.value
    }
    
    var cells: [UITableViewCell] {
        return [sliderCell]
    }
    
    init(bounds: ClosedInterval<Float>, defaultValue: Float, name: String) {
        self.name = name
        self.sliderCell = SliderCell(bounds: bounds, defaultValue: defaultValue, name: name)
        
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
                    writeBuffer[i] = HSV(h: hue, s: 1, v: value).rgbFloat.gammaAdjusted(self.gammaControl.value) * pow(self.brightnessControl.value, 2)
                }
            }
        }
    }
}
