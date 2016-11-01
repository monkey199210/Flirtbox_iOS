//
//  RadarViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 16.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
class UserData {
    var username: String!
    var imageUrl: String!
    var x: CGFloat!
    var y: CGFloat!
    var distance: CGFloat!
    var isGrouped = false
    init(username: String, imageUrl: String, x: CGFloat, y: CGFloat){
        self.username = username
        self.imageUrl = imageUrl
        self.x = x
        self.y = y
        self.distance = FBRadarViewController.distanceBetween(CGPointZero, p2: CGPointMake(x, y))
    }
}
protocol FBRadarViewControllerDelegate : class {
	func groupTapped(userIds: [String], reset: Bool)
    func pinched(scale: CGFloat)
}
class FBRadarViewController: UIViewController {

    weak var delegate: FBRadarViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.runSpinAnimation()
    }

    // MARK: - Outlets
    @IBOutlet weak var radarLine: UIImageView!
    @IBOutlet var circles: [UIImageView]!
    
    private var lastPinch: CGFloat = 1.0
    @IBAction func pinchAction(sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            lastPinch = 1.0
        }else{
            self.delegate?.pinched(sender.scale - lastPinch)
            lastPinch = sender.scale
        }
    }
    
    // MARK: - Helper methods
    private let kGroupWidth: CGFloat = 40.0
    let kIconWidth: CGFloat = 84.0
    let kCenterAvatarWidth: CGFloat = 70.0
    let kMaxWidth: CGFloat = 170.0
    var allUsers: [UserData] = [] {
        didSet {
            self.allowedUsers = allUsers.count
        }
    }
    private var users: [UserData] = []
    var allowedUsers: Int = 0 {
        didSet {
            if allowedUsers > 0 && allowedUsers <= self.allUsers.count {
                self.users = Array(self.allUsers[0..<allowedUsers])
                if self.users.count > 0 {
                    self.distance = users.last!.distance
                }
                self.clear()
                self.createContent()
            }
        }
    }
	var groups: [[UserData]] = []
	var buttons : [UIButton] = []
    var userImageViews: [String:UIImageView] = [:]
    var userImageViewsX: [String:NSLayoutConstraint] = [:]
    var userImageViewsY: [String:NSLayoutConstraint] = [:]
    var distance: CGFloat = 0.0
    func clear() {
        for (_,imageView) in self.userImageViews {
            imageView.removeFromSuperview()
        }
        self.userImageViews.removeAll()
        self.userImageViewsX.removeAll()
        self.userImageViewsY.removeAll()
        self.groups.removeAll()
    }
    func createContent() {
        let viewMaxDistance = kMaxWidth - kCenterAvatarWidth
        let minDistance = (distance * kIconWidth) / viewMaxDistance
        let allUsers = users.sort({ (first, second) -> Bool in
            first.isGrouped = false
            second.isGrouped = false
            return first.distance < second.distance
        })
        if groups.count == 0 && users.count > 0 {
            //create groups
            var currentUser: UserData?
            for user in allUsers {
                if currentUser == nil {
                    currentUser = user
                    groups.append([currentUser!])
                }else{
                    let distanceBetweenUsers = FBRadarViewController.distanceBetween(CGPointMake(user.x, user.y), p2: CGPointMake(currentUser!.x, currentUser!.y))
                    if distanceBetweenUsers < minDistance {
                        var lastArray = groups.last!
                        lastArray.append(user)
                        groups.removeLast()
                        groups.append(lastArray)
                    }else{
                        currentUser = user
                        groups.append([currentUser!])
                    }
                }
            }
        }else if groups.count > 0 && users.count > 0 {
            //change groups
            
        }
        var groupIndex = 0
        for group in groups {
            let x = group[0].x
            let y = group[0].y
            let id = group[0].username
            var imageUrl: String? = nil
            if group.count == 1 {
                imageUrl = group[0].imageUrl
            }
            let distance = FBRadarViewController.distanceBetween(CGPointZero, p2: CGPointMake(x, y))
            if self.distance > distance {
                var imageView: UIImageView
                var xConstraint: NSLayoutConstraint
                var yConstraint: NSLayoutConstraint
                var needUpdateImmediately = false
                if let imgV = userImageViews[id] {
                    imageView = imgV
                    xConstraint = userImageViewsX[id]!
                    yConstraint = userImageViewsY[id]!
                }else{
                    imageView = UIImageView(frame: CGRectMake(0, 0, kIconWidth, kIconWidth))
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    view.addSubview(imageView)
                    if let imageUrl = imageUrl {
                        imageView.layer.borderWidth = 2.0
                        imageView.layer.masksToBounds = false
                        imageView.layer.borderColor = UIColor.whiteColor().CGColor
                        imageView.layer.cornerRadius = imageView.frame.size.width/2.0
                        imageView.clipsToBounds = true
                        if let url = NSURL(string: imageUrl) {
                            imageView.nk_cancelLoading()
                            imageView.nk_setImageWith(url)
                        }
                        Restraint(imageView, .Width,  .Equal, kIconWidth).addToView(imageView)
                        Restraint(imageView, .Height,  .Equal, kIconWidth).addToView(imageView)
                    }else{
                        imageView.image = UIImage(named: R.AssetsAssets.radarEl2.takeUnretainedValue() as String)
                        Restraint(imageView, .Width,  .Equal, kGroupWidth).addToView(imageView)
                        Restraint(imageView, .Height,  .Equal, kGroupWidth).addToView(imageView)
                        
                        let label = UILabel()
                        label.text = String(group.count)
                        label.font = UIFont(name: "Roboto", size: 15)
                        label.textColor = UIColor.whiteColor()
                        label.backgroundColor = UIColor.clearColor()
                        label.translatesAutoresizingMaskIntoConstraints = false
                        imageView.addSubview(label)
                        Restraint(imageView, .CenterX, .Equal, label, .CenterX).addToView(imageView)
                        Restraint(imageView, .CenterY, .Equal, label, .CenterY, 1.0, 5.0).addToView(imageView)
                    }
                    imageView.transform = CGAffineTransformMakeRotation(CGFloat(lastAngle))
                    xConstraint = NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0)
                    view.addConstraint(xConstraint)
                    yConstraint = NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0)
                    view.addConstraint(yConstraint)
                    userImageViewsX[id] = xConstraint
                    userImageViewsY[id] = yConstraint
                    userImageViews[id] = imageView
                    
                    imageView.userInteractionEnabled = true
                    let button = UIButton(type: .Custom)
                    button.frame = imageView.bounds
                    button.tag = groupIndex
                    button.addTarget(self, action: #selector(FBRadarViewController.openBottomList(_:)), forControlEvents: .TouchUpInside)
                    imageView.addSubview(button)
                    self.buttons.append(button)
                    needUpdateImmediately = true
                }
                let minDistanceX = x < 0 ? -kCenterAvatarWidth: kCenterAvatarWidth
                let minDistanceY = y < 0 ? -kCenterAvatarWidth: kCenterAvatarWidth
                let viewX = (x / self.distance) * viewMaxDistance + fabs(x/distance) * minDistanceX
                let viewY = -(y / self.distance) * viewMaxDistance - fabs(y/distance) * minDistanceY
                xConstraint.constant = viewX
                yConstraint.constant = viewY
                
                if needUpdateImmediately {
                    self.view.layoutIfNeeded()
                    imageView.alpha = 0.0
                    UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                        imageView.alpha = 1.0
                        }, completion:{(_) -> Void in
                    })
                }else{
                    UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                        }, completion:{(_) -> Void in
                    })
                }
            }else if let imgV = userImageViews[id]{
                imgV.removeFromSuperview()
                userImageViews[id] = nil
                userImageViewsX[id] = nil
                userImageViewsY[id] = nil
            }
            groupIndex += 1
        }
        resizeObjects()
    }
    private func resizeObjects() {
        for group in groups {
            if group.count == 1 {
                let id = group[0].username
                if let imgV = userImageViews[id] {
                    let xConstraint = userImageViewsX[id]!
                    let yConstraint = userImageViewsY[id]!
                    let distance = FBRadarViewController.distanceBetween(CGPointZero, p2: CGPointMake(xConstraint.constant, yConstraint.constant))
                    UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                        let rotate = CGAffineTransformMakeRotation(self.lastAngle)
                        if distance < self.kCenterAvatarWidth * 1.7 || distance > self.kMaxWidth - self.kIconWidth/2.0 {
                            imgV.alpha = 0.5
                            let scale = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)
                            imgV.transform = CGAffineTransformConcat(rotate, scale)
                        }else{
                            imgV.superview?.bringSubviewToFront(imgV)
                            imgV.alpha = 1.0
                            let scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
                            imgV.transform = CGAffineTransformConcat(rotate, scale)
                        }
                        }, completion:{(_) -> Void in
                    })
                }
            }
        }
    }
    private var lastAngle: CGFloat = 0.0
    func rotateImages(angle: CGFloat) {
        lastAngle = angle
        for imageView in userImageViews {
            if imageView.1.alpha != 1.0 {
                let rotate = CGAffineTransformMakeRotation(CGFloat(angle))
                let scale = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)
                imageView.1.transform = CGAffineTransformConcat(rotate, scale)
            }else{
                imageView.1.transform = CGAffineTransformMakeRotation(CGFloat(angle))
            }
        }
    }
    func addSearchView(view: UIView) {
        
    }
    class func distanceBetween(p1: CGPoint, p2: CGPoint) -> CGFloat{
        return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2))
    }
    func animateWaves() {
        if !isAnimationg {
            isAnimationg = true
            
            FBoxHelper.delay(0.3, closure: { () -> () in
                self.runPulseAnimationExpand(self.radarLine)
            })
            for view in circles {
                FBoxHelper.delay(Double(view.tag - 1) * 0.1, closure: { () -> () in
                    self.runPulseAnimationExpand(view)
                })
            }
            FBoxHelper.delay(1.5, closure: { () -> () in
                self.isAnimationg = false
            })
        }
    }
    func runSpinAnimation() {
        runSpinAnimationOnView(radarLine, duration: 4.0)
    }
    private func runSpinAnimationOnView(view: UIView, duration: Double) {
        view.layer.removeAnimationForKey("rotationAnimation")
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = M_PI * 2.0
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = .infinity
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    private var isAnimationg = false
    private func runPulseAnimationExpand(view: UIView) {
        UIView.animateWithDuration(1.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)
            }, completion:{(_) -> Void in
                self.runPulseAnimationShrink(view)
        })
    }
    private func runPulseAnimationShrink(view: UIView) {
        UIView.animateWithDuration(1.5, delay: 0.05, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
            }, completion:{(_) -> Void in
                
        })
    }
    
    private var selectedImageView: UIImageView?
	private var selectedButtonTag: Int = -1;
    func openBottomList(button: UIButton) {
		var shouldReset = false;
		if(self.selectedButtonTag == button.tag){
			shouldReset = true;
		}
		self.selectedButtonTag = button.tag;
		if button.tag < groups.count {
			let selectedGroup = groups[button.tag];
			var userIds: [String] = [];
			for userData in selectedGroup {
				userIds.append(userData.username);
			}
			if let imageView = button.superview as? UIImageView where selectedGroup.count > 1 {
				selectedImageView = imageView
				
				imageView.image = shouldReset ?
					UIImage(named: R.AssetsAssets.radarEl2.takeUnretainedValue() as String) :
					UIImage(named: R.AssetsAssets.radarEl1.takeUnretainedValue() as String) ;
			}
			for groupButton in self.buttons{
				if(groupButton.tag == button.tag ||
					groups[groupButton.tag].count <= 1)
				{
					continue;
				}
				if let imageView = groupButton.superview as? UIImageView {
					imageView.image = UIImage(named: R.AssetsAssets.radarEl2.takeUnretainedValue() as String)
				}
			}
			self.delegate?.groupTapped(userIds, reset: shouldReset);
		}
    }
}
