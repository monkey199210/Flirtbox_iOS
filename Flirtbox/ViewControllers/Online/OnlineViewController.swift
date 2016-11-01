//
//  OnlineViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import Nuke
import GoogleMobileAds
import LGAlertView

enum UserSearchType {
    case Online
    case Faves
    case Blocked
    case Search
	case Indefinite
}

class OnlineViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, RangeSelectorDelegate, ValueSelectorDelegate, GADBannerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, OnlineControllerDelegate {

	//MARK: -Properties and fields
    private var users: [FBSearchedUser] = []
    private func getBottomDefault() -> CGFloat {
        return self.bottomFilterView.hidden ? 0.0 : 40.0
    }
    private var currentOnlineDays = 0 {
        didSet {
            GoogleAnalitics.send(GoogleAnalitics.Online.Category, action: GoogleAnalitics.Online.FILTER, label: nil, value: onlineDays[currentOnlineDays])
            self.needDownload = true
            self.collectionView.reloadData()
        }
    }
    private var onlineDays = [1, 7, 30, 90]
    private var lat: Double = 0.0
    private var lon: Double = 0.0
    private let kNearestDefaultDistance: Double = 100
    private let kNearestGreatDistance: Double = 6000
    var type: UserSearchType = .Indefinite {
        didSet {
            self.users = []
            self.collectionView.reloadData()
			self.deleteButton.hidden = true
			self.searchButton.hidden = true
			self.filterButton.hidden = true
			self.bottomFilterView.hidden = true
			getData(type, offset: 0);
			switch type {
			case .Online:
				break;
			case .Search:
				self.bottomFilterView.hidden = false
				var isNearestSearched = false
				LocationManager.sharedInstance.setLocationProcessBlock { (lat, lon) -> () in
					self.lat = lat
					self.lon = lon
					if !isNearestSearched {
						isNearestSearched = true
						Net.nearby(0, limit: FBoxConstants.kDefaultLimit).onSuccess(callback: { (users) -> Void in
							self.activity.stopAnimating()
							self.users = users
							self.collectionView.reloadData()
						})
					}
				}
			case .Blocked:
				break;
			case .Faves:
				break;
			case .Indefinite:
				break;
			}
            collectionBottom.constant = getBottomDefault()
            self.view.layoutIfNeeded()
        }
    }
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.filterGender = nil;
		self.genderCriteria.text = "\("_WOMEN".localized), \("_MEN".localized)";
		
		self.searchSegment.setTitle("_NEARBY".localized, forSegmentAtIndex: 0);
		self.searchSegment.setTitle("_ACTIVE".localized, forSegmentAtIndex: 1);
		self.searchSegment.setTitle("_NEW".localized, forSegmentAtIndex: 2);
		self.searchSegment.setTitle("_TOP".localized, forSegmentAtIndex: 3);
		self.collectionView.registerClass(EmptyCollectionCell.self, forCellWithReuseIdentifier: "EmptyListCell");
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        bannerView.adUnitID = GoogleAnalitics.kAdUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.loadRequest(GADRequest())
        bannerView.alpha = 0.0
        
        ageSelector.delegate = self
        distanceSelector.delegate = self
        filterView.alpha = 0.0
        filterTop.constant = -filterHeight.constant
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.menuBg.image = nil
        self.updateMainImage()
        FBEvent.onMainPictChanged().listen(self) { [unowned self] (_) -> Void in
            self.updateMainImage()
        }
		self.selectGenderButton.setTitle("_EDIT".localized, forState: .Normal);
		self.selectGenderButton.setTitleColor(UIColor.grayColor(), forState: .Normal);
    }
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		FBoxHelper.getMainController()?.showMenuButton(true)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OnlineViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OnlineViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	private func updateMainImage() {
		UserProfile.getMainPict({ (image) -> Void in
			self.menuBg.image = image
		})
	}
	//MARK: -Ads
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print(error)
        self.bannerHeight.constant = 0.0
        UIView.animateWithDuration(1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        self.bannerHeight.constant = GoogleAnalitics.kBannerHeight
        UIView.animateWithDuration(1, animations: {
            self.view.layoutIfNeeded()
            bannerView.alpha = 1.0
        })
    }
	//MARK: -Keyboard stuff
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            collectionBottom.constant = keyboardSize.height
            UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion:{(_) -> Void in
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        collectionBottom.constant = getBottomDefault()
        UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
                
        })
    }
    
    // MARK: - Actions
	@IBAction func selectGenderAction(sender: AnyObject) {
		Net.localValues(Net.SingleProfileItems.SEXUALITY.rawValue, animated: true, category: nil, gender: UserProfile.currentUser()?.general.gender).onSuccess { (values) -> Void in
			self.openWithValues(values, title: "_SEXUALITY".localized, item: Net.SingleProfileItems.SEXUALITY.rawValue)
		}
	}
    @IBAction func searchSegmentAction(sender: AnyObject) {
        isFilterUsed = false
        self.getData(.Search)
    }
	
    @IBAction func searchOpenAction(sender: AnyObject) {
        openSearch()
    }
    @IBAction func searchOnFieldAction(sender: AnyObject) {
        closeSearch()
    }
    @IBAction func filterAction(sender: AnyObject) {
        toggleFilter()
    }

    // MARK: - Outlets
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var womanSwitch: UISwitch!
    @IBOutlet weak var menSwitch: UISwitch!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var menuBg: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var distanceSelector: ValueSelector!
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var filterHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomFilterView: UIView!
    @IBOutlet weak var ageSelector: RangeSelector!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var agesLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTop: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionBottom: NSLayoutConstraint!
    @IBOutlet weak var searchTop: NSLayoutConstraint!
    @IBOutlet weak var searchSegment: UISegmentedControl!
	@IBOutlet weak var genderCriteria: UILabel!
	@IBOutlet weak var selectGenderButton: UIButton!
    // MARK: - UICollectionView
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if !needDownload && self.type == .Online && self.currentOnlineDays < self.onlineDays.count - 1 {
            return CGSizeMake(self.view.frame.size.width, 40)
        }else{
            return CGSizeZero
        }
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "OnlineMoreCollectionReusableView", forIndexPath: indexPath) as! OnlineMoreCollectionReusableView
        view.onlineViewController = self
        return view
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return users.count == 0 ? 1 : users.count;
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		if(users.count == 0){
			let emptyCell = collectionView.dequeueReusableCellWithReuseIdentifier("EmptyListCell", forIndexPath: indexPath) as! EmptyCollectionCell
			emptyCell.frame = CGRect(x: 0,y: 0,width: UIScreen.mainScreen().bounds.width,height: 100);
			emptyCell.textLabel.frame = emptyCell.bounds;
			emptyCell.userInteractionEnabled = false;
			return emptyCell;
		}
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("OnlineCollectionViewCell", forIndexPath: indexPath)
        if let onlineCollectionViewCell = collectionViewCell as? OnlineCollectionViewCell {
            let user = users[indexPath.row]
			onlineCollectionViewCell.initWithUser(user);
            if self.users.count > 0 && indexPath.row > self.users.count - 2 && self.needDownload {
				self.getData(self.type, offset: self.users.count);
            }
        }
        return collectionViewCell
    }
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let onlineCollectionViewCell = cell as? OnlineCollectionViewCell {
            onlineCollectionViewCell.userPicture.nk_cancelLoading()
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		if(users.count == 0){
			return;
		}
        let user = users[indexPath.row]
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController {
            controller.user = user
			if(self.type == .Blocked){
				controller.onlineDelegate = self;
			}
            FBoxHelper.getMainController()?.hideMenuButton(true)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		self.closeFilterIfNeeded(0.7);
	}
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
		return true;
    }
    
    // MARK: - ValueSelectorDelegate
    func valueChanged(valueSelector: ValueSelector, value: CGFloat) {
        self.distance.text = "\(String(Int(value)))"
    }
    func valueSelected(valueSelector: ValueSelector, value: CGFloat) {
        self.filterDistance = Int(value)
    }
    
    // MARK: - RangeSelectorDelegate
    func positionsChanged(rangeSelector: RangeSelector, firstPosition: CGFloat, secondPosition: CGFloat) {
        agesLabel.text = "\(String(Int(firstPosition))) - \(String(Int(secondPosition)))"
    }
    func rangeSelected(rangeSelector: RangeSelector, firstPosition: CGFloat, secondPosition: CGFloat) {
        self.filterMinAge = Int(firstPosition)
        self.filterMaxAge = Int(secondPosition)
    }
    
    // MARK: - Helper methods
    func changeOnlineDays() {
        if self.currentOnlineDays < self.onlineDays.count - 1 {
            self.currentOnlineDays += 1
        }
    }
    private var isFilterOpened = false
    private func toggleFilter() {
        if isFilterOpened {
            closeFilterIfNeeded()
        }else{
            openFilter()
        }
    }
    private func openFilter() {
        isFilterOpened = true
        filterButton.setImage(UIImage(named: "onlinePressedFilter"), forState: .Normal)
        closeSearch()
        self.filterTop.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
        })
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.1, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.filterView.alpha = 1.0
            }, completion:{(_) -> Void in
        })
    }
	private func closeFilterIfNeeded(animationDuration : NSTimeInterval = 0.3){
		if(!isFilterOpened){
			return;
		}
        isFilterOpened = false
        filterButton.setImage(UIImage(named: "onlineFilter"), forState: .Normal)
        self.filterTop.constant = -self.filterHeight.constant
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.filterView.alpha = 0.0
            }, completion:{(_) -> Void in
        })
        UIView.animateWithDuration(animationDuration, delay: 0.1, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
        })
    }
    
    let kSearchClosedConstant: CGFloat = -60.0
    private func closeSearch() {
        FBoxHelper.getMainController()?.showMenuButton(false)
        self.view.endEditing(true)
        self.searchTop.constant = kSearchClosedConstant
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
        })
    }
    private func openSearch() {
        closeFilterIfNeeded()
        self.searchField.becomeFirstResponder()
        FBoxHelper.getMainController()?.hideMenuButton(false)
        self.searchTop.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
        })
    }
	
	
	// MARK: - UIPickerViewDataSource
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return values.count
	}
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	// MARK: - UIPickerViewDelegate
	private var values: [FBLocalValue] = []
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		 return values[row].text
	}
	
	// MARK: - Localizable dialogs
	private func openWithValues(array: [FBLocalValue], title: String, item: String) {
		let picker = UIPickerView()
		picker.dataSource = self
		picker.delegate = self
		self.values = array
		let alertPicker = LGAlertView(viewStyleWithTitle: title, message: "", view: picker, buttonTitles: ["_SUBMIT".localized.capitalizedString], cancelButtonTitle: "_CANCEL".localized.capitalizedString, destructiveButtonTitle: nil, actionHandler: { [weak self] (alertView, name, index) -> Void in
			if let descr = self?.values[picker.selectedRowInComponent(0)] {
				if(item == Net.SingleProfileItems.SEXUALITY.rawValue){
					var fbSex: Sexuality? = nil
					switch(picker.selectedRowInComponent(0)){
					case 0:
						fbSex = UserProfile.currentUser()?.general.gender == "m" ? .Msf : .Fsm
						self!.filterGender = UserProfile.currentUser()?.general.gender == "m" ? .Female : .Male
						self?.genderCriteria.text = UserProfile.currentUser()?.general.gender == "m" ? "_WOMEN".localized : "_MEN".localized
					case 1:
						fbSex = UserProfile.currentUser()?.general.gender == "m" ? .Msmf : .Fsmf
						self!.filterGender = nil;
						self?.genderCriteria.text = "\("_WOMEN".localized), \("_MEN".localized)";
					case 2:
						fbSex = UserProfile.currentUser()?.general.gender == "m" ? .Msm : .Fsf
						self!.filterGender = UserProfile.currentUser()?.general.gender == "m" ? .Male : .Female
						self?.genderCriteria.text = UserProfile.currentUser()?.general.gender == "m" ? "_MEN".localized : "_WOMEN".localized
					default:
						break
					}
				}
			}
			}, cancelHandler: { (alertView,result) -> Void in
				
			}, destructiveHandler: nil)
		alertPicker.showAnimated(true, completionHandler: nil)
	}
	
	//MARK: - Private methods
	private func getData(type : UserSearchType, offset: Int = 0){
		self.closeFilterIfNeeded(0.5);
		self.currentOffset = offset
		if self.currentOffset == 0 {
			needDownload = true
			self.users = []
			self.collectionView.reloadData()
			self.activity.startAnimating()
		}
		
		switch self.type {
		case .Search:
			if self.isFilterUsed {
				self.updateWithFilter(offset)
			}else{
				self.updateSearch(offset)
			}
		case .Online:
			Net.onlineFilter(currentOffset, limit: FBoxConstants.kDefaultLimit, days: self.onlineDays[self.currentOnlineDays]).onSuccess { (users) -> Void in
				self.appendUsers(users)
			}
		case .Blocked:
			Net.blocked(currentOffset, limit: FBoxConstants.kDefaultLimit).onSuccess(callback: { (users) -> Void in
				self.appendUsers(users)
			})
		case .Faves:
			Net.favourites(currentOffset, limit: FBoxConstants.kDefaultLimit).onSuccess(callback: { (users) -> Void in
				self.appendUsers(users)
			})
		case .Indefinite:
			break;
		}
		

	}
	
	private var needDownload = true
	private var currentOffset: Int = 0
	private var isFilterUsed = false {
		didSet {
			currentOffset = 0
		}
	}
	private func updateOnline(offset: Int = 0) {
		self.currentOffset = offset
		if self.currentOffset == 0 {
			needDownload = true
			self.users = []
			self.collectionView.reloadData()
			self.activity.startAnimating()
		}
		Net.onlineFilter(currentOffset, limit: FBoxConstants.kDefaultLimit, days: self.onlineDays[self.currentOnlineDays]).onSuccess { (users) -> Void in
			self.appendUsers(users)
		}
	}
	private func appendUsers(users: [FBSearchedUser]) {
		if users.count == 0 || users.count < FBoxConstants.kDefaultLimit {
			self.needDownload = false
		}
		self.activity.stopAnimating()
		for user in users {
			if !self.isUserContains(user) {
				self.users.append(user)
			}
		}
		self.collectionView.reloadData()
	}
	private func isUserContains(user: FBSearchedUser) -> Bool {
		var isContained = false
		for usr in self.users {
			if usr.username == user.username {
				isContained = true
				break
			}
		}
		return isContained
	}
	
	//MARK: - Filter stuff
	private var filterGender: Gender? = nil {
		didSet {
			isFilterUsed = true
			getData(.Search);
		}
	}
	private var filterMaxAge: Int? = nil {
		didSet {
			isFilterUsed = true
			getData(.Search);
		}
	}
	private var filterMinAge: Int?
	private var filterDistance: Int? = nil {
		didSet {
			isFilterUsed = true
			getData(.Search);
		}
	}
	
	private func updateWithFilter(offset: Int = 0) {
		var sortField : SortField? = nil;
		var minRatings : Int = 0;
		var sortDesc : Bool = true;
		switch self.searchSegment.selectedSegmentIndex {
		case 0:
			sortField = nil;
			sortDesc = false;
		case 1:
			sortField = .Lastactive;
			minRatings = 3;
		case 2:
			sortField = .RegdateTime;
		case 3:
			sortField = .AverageVote;
			minRatings = 3;
		default:
			sortField = nil;
			sortDesc = false;
		}
		
		var distance = self.kNearestGreatDistance
		if let dist = self.filterDistance {
			distance = Double(dist)
		}
		Net.search(distance,
			offset: currentOffset,
			limit: FBoxConstants.kDefaultLimit,
			lat: self.lat,
			lon: self.lon,
			sortField: sortField,
			sortDesc: sortDesc,
			minRatings: minRatings,
			gender: self.filterGender,
			minAge: self.filterMinAge,
			maxAge: self.filterMinAge).onSuccess(callback: { (users) -> Void in
				self.appendUsers(users)
			})
	}
	//--filter
	private func updateSearch(offset: Int = 0) {
		
		switch self.searchSegment.selectedSegmentIndex {
		case 0:
			Net.nearby(currentOffset, limit: FBoxConstants.kDefaultLimit).onSuccess(callback: { (users) -> Void in
				self.appendUsers(users)
			})
		case 1:
			Net.active(currentOffset, limit: FBoxConstants.kDefaultLimit).onSuccess(callback: { (users) -> Void in
				self.appendUsers(users)
			})
		case 2:
			Net.new(currentOffset, limit: FBoxConstants.kDefaultLimit).onSuccess(callback: { (users) -> Void in
				self.appendUsers(users)
			})
		default:
			Net.top(currentOffset, limit: FBoxConstants.kDefaultLimit).onSuccess(callback: { (users) -> Void in
				self.appendUsers(users)
			})
		}
	}
	
	//MARK: - OnlineControllerDelegate
	func refreshData(){
		self.getData(self.type);
	}
}
