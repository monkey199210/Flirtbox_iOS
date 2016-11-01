//
//  MainViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 05.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import FirebaseInstanceID

class MainViewController: UIViewController, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Lifecycle
	//pre-defined set of menu items
	var menuItems : [MenuItem] = [MenuItem.OnlineItem,
	                           MenuItem.RadarItem,
	                           MenuItem.SearchItem,
	                           MenuItem.SexyItem,
//	                           MenuItem.ProfileItem,
	                           MenuItem.MessagesItem,
	                           MenuItem.MeetingsItem,
	                           MenuItem.VisitorsItem,
	                           MenuItem.FavsItem,
	                           MenuItem.BlockedItem,
	                           MenuItem.PremiumItem,
	                           MenuItem.SettingsItem,
	                           MenuItem.FeedbackItem,
	                           MenuItem.AboutItem,
	                           MenuItem.LogoutItem
	                         ];
	
	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
		self.menuHeader = NSBundle.mainBundle().loadNibNamed("MenuHeader", owner: self, options: [:]).first as! MenuHeader;
		self.tableView.tableHeaderView = self.menuHeader;
        super.viewDidLoad()
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.tableFooterView = UIView();
		self.tableView.registerClass(MenuCell.self, forCellReuseIdentifier: "MenuCell");
        FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if !isAuthenticated {
                    self.openController("ProfileViewController", storyboardName: "Main", moduleName: "ProfileViewController")
                    self.menuBg.image = nil
                    self.menuHeader.usernameLabel.text = ""
                    self.addSignUp()
                }else{
                    self.updateUserInfo()
                    self.closeSignUp()
                }
            })
        }
		
        openController("ProfileViewController", storyboardName: "Main", moduleName: "ProfileViewController")
        
		self.menuBg = UIImageView(frame: self.view.bounds);
        self.menuBg.image = nil
        self.menuHeader.userImageView.image = nil
        self.menuHeader.usernameLabel.text = " "
        self.updateMainImage()
        FBEvent.onMainPictChanged().listen(self) { [unowned self] (_) -> Void in
            self.updateMainImage()
        }
        
        if !AuthMe.isAuthenticated() {
            addSignUp()
        }else{
            self.updateUserInfo()
        }
		let headerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.handleTap(_:)));
		
		headerTapRecognizer.cancelsTouchesInView = true;
		headerTapRecognizer.numberOfTapsRequired = 1;
		headerTapRecognizer.numberOfTouchesRequired = 1;
		
		self.menuHeader.addGestureRecognizer(headerTapRecognizer);
		self.tableView.backgroundView = self.menuBg;
		self.tableView.reloadData();
    }
	var menuHeader : MenuHeader!;
    private func updateUserInfo() {
        if let user = UserProfile.currentUser() {
            self.menuHeader.usernameLabel.text = user.general.username
        }else{
            self.menuHeader.usernameLabel.text = ""
        }
        FBEvent.onProfileReceived().listen(self, callback: { [unowned self] (user) -> Void in
            self.menuHeader.usernameLabel.text = user.general?.username
            self.refreshToken()
        })
    }
    private func updateMainImage() {
        UserProfile.getMainPict({ (image) -> Void in
            self.menuBg.image = image
			if(self.menuBg.subviews.count == 0){
				let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
				let blurView = UIVisualEffectView(effect: blurEffect)
				blurView.frame = self.menuBg.bounds
				self.menuBg.addSubview(blurView)
			}
            UserProfile.getCircledMainImage({ (image) -> Void in
                self.menuHeader.userImageView.image = image
            })
        })
    }
	func handleTap(gestureRecognizer: UIGestureRecognizer)
	{
		self.openProfile();
	}
    // MARK: - Outlets
    var menuBg: UIImageView!
    @IBOutlet weak var closeContentButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var menu: UIView!
	var menuBlurView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var menuRight: NSLayoutConstraint!
    @IBOutlet weak var menuLeft: NSLayoutConstraint!
    
    // MARK: - Actions
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            GoogleAnalitics.send(GoogleAnalitics.MainScreen.Category, action: GoogleAnalitics.MainScreen.LOGOUT)
            AuthMe.logout()
        }
    }
    @IBAction func closeContentAction(sender: AnyObject) {
        closeMenu()
    }
	
	
    @IBAction func menuAction(sender: AnyObject) {
        if menuLeft.constant == 0.0 {
            closeMenu()
        }else{
            openMenu()
        }
    }
    
    @IBAction func onlineAction(sender: AnyObject) {
        openController("OnlineViewControllerNav", storyboardName: "Online", moduleName: "OnlineViewController")
        closeMenu()
        if let onlineNav = currentController as? UINavigationController {
            if let online = onlineNav.viewControllers.first as? OnlineViewController {
                online.topTitle.text = "_ONLINE".localized
                online.type = .Online
            }
        }
    }
    @IBAction func messagesAction(sender: AnyObject) {
        openController("MessagesViewControllerNav", storyboardName: "Messages", moduleName: "MessagesViewControllerNav")
        closeMenu()
    }
    
    // MARK: - Helper methods
    
    func hideMenuButton(animated: Bool) {
        if animated {
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.menuButton.alpha = 0.0
                }, completion:{(_) -> Void in
            })
        }else{
            menuButton.alpha = 0.0
        }
    }
    
    func showMenuButton(animated: Bool) {
        if animated {
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.menuButton.alpha = 1.0
                }, completion:{(_) -> Void in
            })
        }else{
            menuButton.alpha = 1.0
        }
    }
    
    var currentOpenedControllerName: String?
    var currentController: UIViewController?
    private func openController(name: String, storyboardName: String, moduleName: String) {
        if currentOpenedControllerName != moduleName {
            currentOpenedControllerName = moduleName
            
            if currentController != nil {
                currentController!.willMoveToParentViewController(nil)
                currentController!.view.removeFromSuperview()
                currentController!.removeFromParentViewController()
                currentController = nil
            }
            
            let controller = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewControllerWithIdentifier(name)
            controller.willMoveToParentViewController(self)
            self.addChildViewController(controller)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(controller.view)
            controller.didMoveToParentViewController(self)
            
            contentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            currentController = controller
        }
    }
	func openProfile(){
		openController("ProfileViewController", storyboardName: "Main", moduleName: "ProfileViewController")
		closeMenu()
	}
    func openMenu() {
        self.view.endEditing(true)
        menuLeft.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
                self.closeContentButton.userInteractionEnabled = true
        })
    }
    
    func closeMenu() {
        menuLeft.constant = -menuRight.constant - self.view.bounds.width
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
                self.closeContentButton.userInteractionEnabled = false
        })
    }
    
    func closeSignUp() {
        if let signUp = signUpNav {
            UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                signUp.view.alpha = 0.0
                }, completion:{(_) -> Void in
                    signUp.view.removeFromSuperview()
                    signUp.removeFromParentViewController()
                    self.signUpNav = nil
            })
        }
    }
    private var signUpNav: UINavigationController?
    private func addSignUp() {
        self.view.endEditing(true)
        if let liveNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewControllerNav") as? UINavigationController where self.signUpNav == nil {
            liveNav.willMoveToParentViewController(self)
            self.addChildViewController(liveNav)
            liveNav.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(liveNav.view)
            liveNav.didMoveToParentViewController(self)
            
            view.addConstraint(NSLayoutConstraint(item: liveNav.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: liveNav.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: liveNav.view, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: liveNav.view, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            
            signUpNav = liveNav
        }
    }
	
	//MARK: - UITableView stuff
	 func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	 func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.menuItems.count;
	}
	
	 func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! MenuCell;
		switch cell.tag {
		case 0:
			openController("OnlineViewControllerNav", storyboardName: "Online", moduleName: "OnlineViewController")
			if let onlineNav = currentController as? UINavigationController {
				if let online = onlineNav.viewControllers.first as? OnlineViewController {
					online.topTitle.text = "_ONLINE".localized
					online.type = .Online
				}
			}
		case 1:
			openController("RadarViewControllerNav", storyboardName: "Radar", moduleName: "RadarViewControllerNav")
		case 2:
			openController("OnlineViewControllerNav", storyboardName: "Online", moduleName: "Blocked")
			if let onlineNav = currentController as? UINavigationController {
				if let online = onlineNav.viewControllers.first as? OnlineViewController {
					online.topTitle.text = "_SEARCH".localized
					online.type = .Search
				}
			}
		case 3:
			openController("SexyOrNotViewControllerNav", storyboardName: "SexyOrNot", moduleName: "SexyOrNotViewControllerNav")
		case 4:
			openController("ProfileViewController", storyboardName: "Main", moduleName: "ProfileViewController")
		case 5:
			openController("MessagesViewControllerNav", storyboardName: "Messages", moduleName: "MessagesViewControllerNav")
		case 6:
			openController("MeetingsViewControllerNav", storyboardName: "Meetings", moduleName: "MeetingsViewController")
		case 7:
			openController("VisitorsViewControllerNav", storyboardName: "Visitors", moduleName: "VisitorsViewController")
		case 8:
			openController("OnlineViewControllerNav", storyboardName: "Online", moduleName: "Blocked")
			if let onlineNav = currentController as? UINavigationController {
				if let online = onlineNav.viewControllers.first as? OnlineViewController {
					online.topTitle.text = "_FAVOURITES".localized
					online.type = .Faves
				}
			}
		case 9:
			openController("OnlineViewControllerNav", storyboardName: "Online", moduleName: "Blocked")
			if let onlineNav = currentController as? UINavigationController {
				if let online = onlineNav.viewControllers.first as? OnlineViewController {
					online.topTitle.text = "_BLOCKED".localized
					online.type = .Blocked
				}
			}
		case 10:
            openController("PremiumViewControllerNav", storyboardName: "Premium", moduleName: "Blocked")
			break;
		case 11:
			openController("SettingsViewController", storyboardName: "Settings", moduleName: "SettingsViewController")
		case 12:
			openController("FeedbackViewController", storyboardName: "Feedback", moduleName: "FeedbackViewController")
		case 13:
			openController("AboutViewController", storyboardName: "About", moduleName: "AboutViewController")
		case 14:
			 UIAlertView(title: "_LOGOUT".localized, message: "_LOGOUT_CONFIRMATION".localized, delegate: self, cancelButtonTitle: "_CANCEL".localized.uppercaseString, otherButtonTitles: "_YES".localized.uppercaseString).show()
		default:
			break;
		}
		closeMenu()
		tableView.deselectRowAtIndexPath(indexPath, animated: false);
	}
	 func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 50;
	}
	 func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let menuCell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell;
		let menuItem = self.menuItems[indexPath.row];
		menuCell.configureWithTitle(menuItem.title, imageName: menuItem.pictureName, tag: menuItem.tag);
		return menuCell;
	}
    func refreshToken()
    {
        let refreshedToken = FIRInstanceID.instanceID().token()!
        if !UserProfile.isPushTokenPresent(refreshedToken)
        {
            Net.updateProfileRegID(refreshedToken, operatingSystem: FBNet.OPERATINGSYS_PARAM_VALUE, operatingSystemVersion: String(NSProcessInfo().operatingSystemVersion.majorVersion))
        }
    }
}
