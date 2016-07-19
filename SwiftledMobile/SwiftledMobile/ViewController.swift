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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[(indexPath as NSIndexPath).row]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepare(for: segue, sender: sender)
    }
    
    private var collapseDetailViewController = true

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        collapseDetailViewController = false
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}


class SliderCell : UITableViewCell {
    var slider: UISlider!
    var label: UILabel!
    var name: String
    
    private var disposeBag = DisposeBag()
    
    init(bounds: ClosedRange<Float>, defaultValue: Float, name: String) {
        self.name = name
        super.init(style: .default, reuseIdentifier: nil)
        
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        slider = UISlider()
        
        slider.minimumValue = bounds.lowerBound
        slider.maximumValue = bounds.upperBound

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
            NSLayoutConstraint(item: slider, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slider, attribute: .bottom, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0),
            ] + ([label, slider] as [UIView]).flatMap {
                [
                    NSLayoutConstraint(item: $0, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leadingMargin, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: $0, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailingMargin, multiplier: 1, constant: 0),
                ]
        }
        
        NSLayoutConstraint.activate(constraints)
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
    
    init(bounds: ClosedRange<Float>, defaultValue: Float, name: String) {
        self.name = name
        self.sliderCell = SliderCell(bounds: bounds, defaultValue: defaultValue, name: name)
        
    }
    
    func run(_ ticker: Observable<TickContext>) -> Disposable {
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
    
    func bind(_ ticker: Observable<WriteContext>) -> Disposable {
        
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
                    
                    let hue: Float = hueNumerator.truncatingRemainder(dividingBy:  1.0)
                    let portion = Float(i % segmentLength) / Float(segmentLength)
                    let value = 0.5 + 0.5 * sin(Float(now * 2) + Float(M_PI * 2) * portion)
                    writeBuffer[i] = HSV(h: hue, s: 1, v: value).rgbFloat.gammaAdjusted(self.gammaControl.value) * pow(self.brightnessControl.value, 2)
                }
            }
        }
    }
}
