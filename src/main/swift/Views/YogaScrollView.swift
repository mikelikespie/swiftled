//
//  ContentView.swift
//  swiftled
//
//  Created by Michael Lewis on 7/19/17.
//
//

import Foundation
import UIKit
import yoga_YogaKit
import yoga_yoga

open class YogaScrollView : UIScrollView {
    public let container = ContentView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        container.frame = frame
        self.showsHorizontalScrollIndicator = true
        addSubview(container);
        self.backgroundColor = .white
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cellsByIndex = [UIView: Int]()
    private var _cells: [UIView] = []

    public var cells: [UIView] {
        set {
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
            
            let indexesToDelete = oldIndexes.values.sorted { $1 < $0 }
            let indexesToInsert = newIndexes.values.sorted()
            
            indexRemappings.sort { $0.1 < $1.1 }
            
            for idx in indexesToDelete {
                _cells[idx].removeFromSuperview()
            }
            
            for (from, to) in indexRemappings {
                container.exchangeSubview(at: from, withSubviewAt: to)
            }
            
            for idx in indexesToInsert {
                newValue[idx].configureLayout { (layout) in
                    layout.isEnabled = true
                }
                
                container.addSubview(newValue[idx])
            }
            
            _cells = newValue
            self.setNeedsLayout()
        }
        
        get {
            return _cells
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let minWidth = insetWidth
        
        let calcualedWidth = self.container.yoga.calculateLayout(with: CGSize(width: .nan, height: insetHeight)).width
        

        let newContentSize = CGSize(
            width: max(minWidth, calcualedWidth),
            height: insetHeight
        )
        
        if newContentSize != self.contentSize {
            self.contentSize = newContentSize
            container.frame.size = newContentSize
        }
    }
    
    var insetHeight: CGFloat {
        return bounds.height - contentInset.top - contentInset.bottom
    }
    
    var insetWidth: CGFloat {
        return bounds.size.width - contentInset.left - contentInset.right
    }
}

public class ContentView : UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureLayout { (layout) in
            layout.isEnabled = true

            layout.flexDirection = .row
        }
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.yoga.applyLayout(preservingOrigin: true)
    }
}
