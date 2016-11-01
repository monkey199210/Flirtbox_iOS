//
//  TemperatureView.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 14.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
protocol TemperatureViewDelegate {
    func temperatureChanged(temperature: Double)
    func temperaturePressed(isPressed: Bool)
}
@IBDesignable class TemperatureView: UIView {
    @IBInspectable var temperature: Double = 34.0 {
        didSet{
            temperature = min(temperature, 100.0)
            temperature = max(temperature, 0.0)
            self.setNeedsDisplay()
        }
    }
    var delegate: TemperatureViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
    }
    private let kLineWidth: CGFloat = 20.0
    private let minAngle = -CGFloat(2.4*M_PI_2)
    private let maxAngle = CGFloat(0.4*M_PI_2)
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextAddEllipseInRect(ctx, CGRectMake(kLineWidth, kLineWidth, rect.size.width - 2.0 * kLineWidth, rect.size.height - 2.0 * kLineWidth))
        CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.0)
        CGContextFillPath(ctx)
        
        CGContextBeginPath(ctx)
        CGContextSetLineWidth(ctx, kLineWidth)
        CGContextSetStrokeColorWithColor(ctx, UIColor(red:0.38, green:0.4, blue:0.42, alpha:1).CGColor)
        CGContextAddArc(ctx, rect.size.width/2.0, rect.size.height/2.0, rect.size.width/2.0 - kLineWidth/2.0, minAngle, maxAngle, 0)
        CGContextSetLineCap(ctx, CGLineCap.Round)
        CGContextStrokePath(ctx)
        
        let temperatureSign = "°"
        let text: NSString = String(Int(temperature)) + temperatureSign
        let font = UIFont(name: "Roboto", size: 44.0)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        if let actualFont = font {
            let textFontAttributes = [
                NSFontAttributeName: actualFont,
                NSForegroundColorAttributeName: UIColor(red:0.38, green:0.4, blue:0.42, alpha:1),
                NSParagraphStyleAttributeName: textStyle
            ]
            let textSize = actualFont.sizeOfString(text, constrainedToWidth: DBL_MAX)
            let tempSignSize = actualFont.sizeOfString(temperatureSign, constrainedToWidth: DBL_MAX)
            text.drawInRect(CGRectMake(tempSignSize.width/2.0, self.bounds.height/2.0-textSize.height/2.0, self.frame.size.width, self.frame.size.height), withAttributes: textFontAttributes)
        }
        
        //Gradient
        CGContextSaveGState(ctx)
        let size = rect.size
        let percent: Double = temperature / 100.0
        //3.6 - 100%
        //6.4 - 0
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let imageCtx = UIGraphicsGetCurrentContext()
        CGContextBeginPath(imageCtx)
        CGContextSetLineWidth(imageCtx, kLineWidth)
        CGContextSetStrokeColorWithColor(imageCtx, UIColor(red:0.38, green:0.4, blue:0.42, alpha:1).CGColor)
        CGContextAddArc(imageCtx, rect.size.width/2.0, rect.size.height/2.0, rect.size.width/2.0 - kLineWidth/2.0, CGFloat(2.4*M_PI_2), CGFloat((6.4-2.8 * percent) * M_PI_2), 1)
        CGContextSetLineCap(imageCtx, CGLineCap.Round)
        CGContextDrawPath(imageCtx, .Stroke)
        let drawMask: CGImageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext())!
        UIGraphicsEndImageContext()
        CGContextSaveGState(ctx)
        CGContextClipToMask(ctx, bounds, drawMask)
        let colors = [UIColor(red:0.58, green:0.83, blue:0.83, alpha:1).CGColor, UIColor(red:0.93, green:0.89, blue:0.27, alpha:1).CGColor, UIColor(red:0.85, green:0.31, blue:0.27, alpha:1).CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 0.5, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(rect.size.width, 0), .DrawsBeforeStartLocation)
        CGContextRestoreGState(ctx)
        
        let endCircleDiff: CGFloat = 6.0
        let endCircleWidth: CGFloat = kLineWidth - endCircleDiff
        let halfX = bounds.size.width/2.0 - endCircleWidth/2.0
        let angle = minAngle + CGFloat(percent) * (maxAngle - minAngle)
        let endPoint = CGPoint(x: (cos(angle) * (halfX - endCircleDiff/2.0)) + halfX, y: (sin(angle) * (halfX - endCircleDiff/2.0)) + halfX)
        CGContextAddEllipseInRect(ctx, CGRectMake(endPoint.x, endPoint.y, endCircleWidth, endCircleWidth))
        CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0)
        CGContextFillPath(ctx)
    }
    
    // MARK: - Touch events
    private let kMinDistance: CGFloat = 50.0
    private var isDragging = false
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            let percent: Double = temperature / 100.0
            let halfX = bounds.size.width/2.0
            let angle = minAngle + CGFloat(percent) * (maxAngle - minAngle)
            let endPoint = CGPoint(x: (cos(angle) * (halfX)) + halfX, y: (sin(angle) * (halfX)) + halfX)
            let distance = distanceBetween(touchLocation, p2: endPoint)
            if distance < kMinDistance {
                isDragging = true
            }
        }
        self.delegate?.temperaturePressed(true)
    }
    private func distanceBetween(p1: CGPoint, p2: CGPoint) -> CGFloat{
        return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2))
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first where isDragging {
            let min = CGFloat(0.8 * M_PI)
            let max = CGFloat(2.2 * M_PI)
            let touchLocation = touch.locationInView(self)
            
            let percent: Double = temperature / 100.0
            let halfX = bounds.size.width/2.0
            let angleForDistance = minAngle + CGFloat(percent) * (maxAngle - minAngle)
            let endPoint = CGPoint(x: (cos(angleForDistance) * (halfX)) + halfX, y: (sin(angleForDistance) * (halfX)) + halfX)
            let distance = distanceBetween(touchLocation, p2: endPoint)
            if distance < 1.4 * kMinDistance {
                let middle = CGPointMake(self.bounds.width/2.0, self.bounds.height/2.0)
                let v1 = CGVector(dx: touchLocation.x - middle.x, dy: touchLocation.y - middle.y)
                var angle = atan2(v1.dy, v1.dx)
                if angle < 0 { angle += CGFloat(2 * M_PI) }
                if angle < CGFloat(M_PI_2) {
                    angle += CGFloat(2 * M_PI)
                }
                if angle > max {
                    angle = max
                }else if angle < min {
                    angle = min
                }
                let percent = (angle - min) / (max - min)
                var percent100 = Double(percent * 100.0)
                if percent100 < 0.01 {
                    percent100 = 0.01
                }
                self.temperature = percent100
            }
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isDragging = false
        self.delegate?.temperatureChanged(self.temperature)
        self.delegate?.temperaturePressed(false)
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isDragging = false
        self.delegate?.temperaturePressed(false)
    }
}
