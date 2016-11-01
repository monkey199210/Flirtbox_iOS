//
//  RangeSelector.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
protocol RangeSelectorDelegate: class {
    func positionsChanged(rangeSelector: RangeSelector, firstPosition: CGFloat, secondPosition: CGFloat)
    func rangeSelected(rangeSelector: RangeSelector, firstPosition: CGFloat, secondPosition: CGFloat)
}
class RangeSelector: UIView {
    weak var delegate: RangeSelectorDelegate?
    @IBInspectable var minValue: CGFloat = 16 {
        didSet{
            rePosition()
        }
    }
    @IBInspectable var maxValue: CGFloat = 120 {
        didSet{
            rePosition()
        }
    }
    @IBInspectable var firstPosition: CGFloat = 18 {
        didSet{
            rePosition()
        }
    }
    @IBInspectable var secondPosition: CGFloat = 60 {
        didSet{
            rePosition()
        }
    }
    private func checkValues() {
        if minValue < 0 {
            minValue = 0.0
        }
        if maxValue < minValue {
            maxValue = minValue + 30
        }
        if firstPosition < 0 {
            firstPosition = 0.0
        }
        if secondPosition < firstPosition {
            secondPosition = firstPosition
        }
    }
    private func rePosition(){
        checkValues()
        
        let width = self.bounds.size.width
        let duration = maxValue - minValue
        var firstOffset = (firstPosition / duration) * width - 12.0
        var secondOffset = (secondPosition / duration) * width - 12.0
        if firstOffset < 0 {
            firstOffset = 0.0
        }
        if secondOffset < 0 {
            secondOffset = 0.0
        }
        if secondOffset - firstOffset < 12.0 {
            secondOffset = firstOffset + 12.0
        }
        firstPositionLeading?.constant = firstOffset
        secondPositionLeading?.constant = secondOffset
        layoutIfNeeded()
        
        delegate?.positionsChanged(self, firstPosition: firstPosition + minValue, secondPosition: secondPosition + minValue)
    }
    private var firstPositionLeading: NSLayoutConstraint?
    private var secondPositionLeading: NSLayoutConstraint?
    private var firstDot: UIImageView?
    private var secondDot: UIImageView?
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
        
        secondDot = UIImageView(image: UIImage(named: "rangeSelectorDot"))
        secondDot!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(secondDot!)
        secondPositionLeading = NSLayoutConstraint(item: secondDot!, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        self.addConstraint(secondPositionLeading!)
        self.addConstraint(NSLayoutConstraint(item: secondDot!, attribute: .CenterY, relatedBy: .Equal, toItem: lineImage, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        let selectedLine = UIImageView(image: UIImage(named: "rangeSelectorSelectedLine"))
        selectedLine.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(selectedLine)
        self.addConstraint(NSLayoutConstraint(item: selectedLine, attribute: .CenterY, relatedBy: .Equal, toItem: lineImage, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: selectedLine, attribute: .Leading, relatedBy: .Equal, toItem: firstDot, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: selectedLine, attribute: .Trailing, relatedBy: .Equal, toItem: secondDot, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        
        rePosition()
    }
    
    // MARK: - Touch events
    private let kMinDistance: CGFloat = 50.0
    private var selectedDot: UIImageView?
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            let distance1 = distanceBetween(touchLocation, p2: firstDot!.center)
            let distance2 = distanceBetween(touchLocation, p2: secondDot!.center)
            if distance1 < distance2 {
                if distance1 < kMinDistance {
                    selectedDot = firstDot
                }
            }else{
                if distance2 < kMinDistance {
                    selectedDot = secondDot
                }
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
                
                if selectedDot == firstDot {
                    firstPosition = offset
                }else{
                    secondPosition = offset
                }
            }
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.rangeSelected(self, firstPosition: firstPosition + minValue, secondPosition: secondPosition + minValue)
        selectedDot = nil
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        selectedDot = nil
    }
}
