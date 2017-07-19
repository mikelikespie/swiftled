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

private let segmentLength = 18
private let segmentCount = 30
private let ledCount =  segmentLength * segmentCount

class ViewController: UITableViewController, UISplitViewControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    var cellsByIndex = [UITableViewCell: Int]()
    private var cells = [UITableViewCell]() {
        willSet {
            var oldIndexes = cellsByIndex
            cellsByIndex.removeAll()
            
            for (i, cell) in newValue.enumerated() {
                cellsByIndex[cell] = i
            }
            
            var newIndexes = cellsByIndex
            
            var indexRemappings = [(Int, Int)]()
            
            for (oldIndex, cell) in cells.enumerated() {
                if let newIndex = newIndexes[cell] {
                    indexRemappings.append((oldIndex, newIndex))
                    
                    newIndexes[cell] = nil
                    oldIndexes[cell] = nil
                }
            }

            tableView.beginUpdates()
            
            let indexesToDelete = oldIndexes.values.sorted { $1 < $0 }
            let indexesToInsert = newIndexes.values.sorted()
            
            indexRemappings.sort { $0.1 < $1.1 }
            
            
            tableView.deleteRows(at: indexesToDelete.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            indexRemappings
                .lazy
                .map { (IndexPath(row: $0, section: 0), IndexPath(row: $1, section: 0)) }
                .forEach(tableView.moveRow)
            tableView.insertRows(at: indexesToInsert.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            
        }
        
        didSet {
            
            tableView.endUpdates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.splitViewController?.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
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
                self.cells = cells
//                self.tableView.reloadData()
            })
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
    
    private var collapseDetailViewController = true

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        collapseDetailViewController = false
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}

