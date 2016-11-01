//
//  PremiumViewController.swift
//  Flirtbox
//
//  Created by Rui Caneira on 8/3/16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import UIKit

class PremiumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var upgradButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //purchase item labels
    //12months
    @IBOutlet weak var lbl12number: UILabel!
    @IBOutlet weak var lbl12month: UILabel!
    @IBOutlet weak var lbl12permonth: UILabel!
    @IBOutlet weak var lbl12save: UILabel!
    @IBOutlet weak var lbl12total: UILabel!
    
    //6months
    @IBOutlet weak var lbl6number: UILabel!
    @IBOutlet weak var lbl6month: UILabel!
    @IBOutlet weak var lbl6permonth: UILabel!
    @IBOutlet weak var lbl6save: UILabel!
    @IBOutlet weak var lbl6total: UILabel!
    
    //3months
    @IBOutlet weak var lbl3number: UILabel!
    @IBOutlet weak var lbl3month: UILabel!
    @IBOutlet weak var lbl3permonth: UILabel!
    @IBOutlet weak var lbl3total: UILabel!
    var currentcolor = UIColor.blueColor()
    var introData: [PremiumIntro] = []
    let images = ["premiummessage", "premiumsupport", "premiumfaster", "premiumincrease", "premiumdelete"]
    let titles = ["UNLIMITED", "PREMIUM SUPPORT", "FASTER APPROVAL", "MORE FAVORITES", "VISITORS"]
    let intros = ["Messages and number of new contacts per day", "We will give priority to your questions", "Faster approval of your awesome pictures", "You will be able to add even more favourites", "See who visited your profile"]
    override func viewDidLoad() {
        super.viewDidLoad()
        initIntroData()
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width
        
        //Setting the right content size - only height is being calculated depenging on content.
        let height = self.upgradButton.frame.maxY + 15
        let contentSize = CGSizeMake(screenWidth, height);
        self.scrollView.contentSize = contentSize;
        
        currentcolor = lbl12number.textColor
    }
    func initIntroData()
    {
        for i in 0...4
        {
            var item = PremiumIntro()
            item.title = titles[i]
            item.image = images[i]
            item.intro = intros[i]
            introData.append(item)
        }
    }
   func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PremiumCollectionViewCell", forIndexPath: indexPath)
        if let premiumIntrocollectionViewCell = collectionViewCell as? PremiumIntroCell
        {
            premiumIntrocollectionViewCell.introLabel.text = introData[indexPath.row].intro
            premiumIntrocollectionViewCell.titleLabel.text = introData[indexPath.row].title
            premiumIntrocollectionViewCell.premiumImg.image = UIImage(named: introData[indexPath.row].image)
            return premiumIntrocollectionViewCell
        }
    
        return collectionViewCell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return introData.count
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            var page: Int = Int(scrollView.contentOffset.x / self.view.frame.size.width)
            page = min(page, self.introData.count - 1)
            page = max(page, 0)
            self.pageControl.currentPage = page
        }
    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//            return CGSizeMake(320, 268)
//    }
    @IBAction func purchaseItemAction(sender: UIButton) {
        let selectedColor = UIColor.greenColor()
        refreshPurchaseLablesColor()
        switch sender.tag {
        case 1:
            lbl12number.textColor = selectedColor
            lbl12month.textColor = selectedColor
            lbl12permonth.textColor = selectedColor
        case 2:
            lbl6number.textColor = selectedColor
            lbl6month.textColor = selectedColor
            lbl6permonth.textColor = selectedColor
        case 3:
            lbl3number.textColor = selectedColor
            lbl3month.textColor = selectedColor
            lbl3permonth.textColor = selectedColor
        default:
            break
        }
    }
    func refreshPurchaseLablesColor()
    {
        lbl12number.textColor = currentcolor
        lbl12month.textColor = currentcolor
        lbl12permonth.textColor = currentcolor
        
        lbl6number.textColor = currentcolor
        lbl6month.textColor = currentcolor
        lbl6permonth.textColor = currentcolor
        
        lbl3number.textColor = currentcolor
        lbl3month.textColor = currentcolor
        lbl3permonth.textColor = currentcolor
    }
}
