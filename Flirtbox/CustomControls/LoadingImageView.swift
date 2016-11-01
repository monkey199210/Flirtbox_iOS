//
//  LoadingImageView.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 07.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import Bond

class LoadingImageView: UIImageView {
    private var progress: KDCircularProgress?
    override var image: UIImage? {
        didSet {
            if let loadingImage = image as? LoadingImage {
                if progress == nil {
                    let size: CGFloat = 60
                    self.progress = KDCircularProgress(frame: CGRect(x: self.frame.size.width/2.0 - size/2.0, y: self.frame.size.height/2.0 - size/2.0, width: size, height: size))
                    self.progress!.startAngle = -90
                    self.progress!.progressThickness = 0.2
                    self.progress!.trackThickness = 0.6
                    self.progress!.clockwise = true
                    self.progress!.gradientRotateSpeed = 2
                    self.progress!.roundedCorners = true
                    self.progress!.glowMode = .Forward
                    self.progress!.glowAmount = 0.1
                    self.progress!.setColors(UIColor.whiteColor())
                    self.progress!.center = CGPoint(x: self.center.x, y: self.center.y)
                    self.addSubview(self.progress!)
                    self.addAnimation()
                }else{
                    progress?.hidden = false
                    self.addAnimation()
                }
                if loadingImage.loadProgress == 1.0 {
                    self.progress?.hidden = true
                    self.progress?.layer.removeAllAnimations()
                }
                loadingImage.loadingChecker.append({ [weak self, unowned loadingImage] loadingProgress in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if loadingImage.loadProgress != 1.0 {
                            self?.progress?.hidden = false
                            self?.addAnimation()
                        }
                        var prevousAngle = 0
                        if let prev = self?.progress?.angle {
                            prevousAngle = prev
                        }
                        let angle = 360.0 * loadingProgress
                        self?.progress?.animateFromAngle(prevousAngle, toAngle: Int(angle), duration: 0.3, completion: { (_) -> Void in
                            if loadingImage.loadProgress == 1.0 {
                                self?.progress?.hidden = true
                                self?.progress?.layer.removeAllAnimations()
                            }
                        })
                        self?.setNeedsDisplay()
                    })
                    })
            }else{
                progress?.hidden = true
                self.progress?.layer.removeAllAnimations()
            }
        }
    }
    private func addAnimation() {
        if let progress = self.progress {
            progress.layer.removeAllAnimations()
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = M_PI * 2.0
            rotationAnimation.duration = 1.0
            rotationAnimation.repeatCount = .infinity
            progress.layer.addAnimation(rotationAnimation, forKey: nil)
        }
    }
}
