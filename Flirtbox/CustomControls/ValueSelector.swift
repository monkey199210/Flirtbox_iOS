//
//  ValueSelector.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 12.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
protocol ValueSelectorDelegate: class {
    func valueChanged(valueSelector: ValueSelector, value: CGFloat)
    func valueSelected(valueSelector: ValueSelector, value: CGFloat)
}
class ValueSelector: UIView {
    weak var delegate: ValueSelectorDelegate?
    @IBInspectable var minValue: CGFloat = 0 {
        didSet{
            rePosition()
        }
    }
    @IBInspectable var maxValue: CGFloat = 18000 {
        didSet{
            rePosition()
        }
    }
    @IBInspectable var value: CGFloat = 5000 {
        didSet{
            rePosition()
        }
    }
    private func checkValues() {
        if minValue < 0 {
            minValue = 0.0
        }
        if maxValue < minValue {
            maxValue = minValue + 1000
        }
        if value < minValue {
            value = minValue
        }
        if value > maxValue {
            value = maxValue
        }
    }
    private func rePosition(){
        checkValues()
        
        let width = self.bounds.size.width
        let duration = maxValue - minValue
        var firstOffset = (value / duration) * width - 12.0
        if firstOffset < 0.0 {
            firstOffset = 0.0
        }else if firstOffset > self.bounds.size.width - 12.0 {
            firstOffset = self.bounds.size.width - 12.0
        }
        firstPositionLeading?.constant = firstOffset
        layoutIfNeeded()
        
        delegate?.valueChanged(self, value: self.value + minValue)
    }
    private var firstPositionLeading: NSLayoutConstraint?
    private var firstDot: UIImageView?
    override func awakeFromNib() {
        super.awakeFromNib()
        let lineImage = UIImageView(image: UIImage(named: "rangeSelectorLine"))
        lineImage.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lineImage)
        self.addConstraint(NSLayoutConstraint(item: lineImage, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: lineImage, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: lineImage, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        firstDot = UIImageView(image: UIImage(named: "rangeSelectorDot"))
        firstDot!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(firstDot!)
        firstPositionLeading = NSLayoutConstraint(item: firstDot!, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        self.addConstraint(firstPositionLeading!)
        self.addConstraint(NSLayoutConstraint(item: firstDot!, attribute: .CenterY, relatedBy: .Equal, toItem: lineImage, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        let selectedLine = UIImageView(image: UIImage(named: "rangeSelectorSelectedLine"))
        selectedLine.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(selectedLine)
        self.addConstraint(NSLayoutConstraint(item: selectedLine, attribute: .CenterY, relatedBy: .Equal, toItem: lineImage, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: selectedLine, attribute: .Leading, relatedBy: .Equal, toItem: lineImage, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: selectedLine, attribute: .Trailing, relatedBy: .Equal, toItem: firstDot, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        
        rePosition()
    }
    
    // MARK: - Touch events
    private let kMinDistance: CGFloat = 50.0
    private var selectedDot: UIImageView?
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            let distance1 = distanceBetween(touchLocation, p2: firstDot!.center)
            if distance1 < kMinDistance {
                selectedDot = firstDot
            }
        }
    }
    private func distanceBetween(p1: CGPoint, p2: CGPoint) -> CGFloat{
        return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2))
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            var touchLocation = touch.locationInView(self)
            if touchLocation.x < 0 {
                touchLocation.x = 0
            }
            if touchLocation.x > self.bounds.size.width {
                touchLocation.x = self.bounds.size.width
            }
            if selectedDot != nil {
                let width = self.bounds.size.width
                let duration = maxValue - minValue
                let offset = touchLocation.x * (duration / width)
                value = offset
            }
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.valueSelected(self, value: self.value + minValue)
        selectedDot = nil
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        selectedDot = nil
    }
}
