//
//  EditImageViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 07.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit

class EditImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {

    // MARK: - Lifecycle
    private var pictures: [FBPicture] = []
    private var rowsToOrder: [String] = []
    deinit {
        FBEvent.onPicturesChanged().removeListener(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        updateImages()
//        FBEvent.onPicturesChanged().listen(self) { [unowned self] (_) -> Void in
////            self.updateImages()
//        }

        self.hideSubmitButton()
        if let reordableLayout = self.collectionView.collectionViewLayout as? RAReorderableLayout {
            reordableLayout.delegate = self
            reordableLayout.datasource = self
        }
    }
    private func updateImages() {
        self.imagesAction.startAnimating()
        Net.pictureList().onSuccess { (pictures) -> Void in
            self.pictures = pictures.sort({ (first, second) -> Bool in
                return Int(first.orderid) > Int(second.orderid)
            })
            self.relateOrders()
            self.collectionView.reloadData()
            self.imagesAction.stopAnimating()
            }.onFailure { (_) -> Void in
                self.imagesAction.stopAnimating()
        }
    }
    private func relateOrders() {
        self.rowsToOrder.removeAll()
        for picture in self.pictures {
            self.rowsToOrder.append(picture.orderid)
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomSubmit: NSLayoutConstraint!
    @IBOutlet weak var imagesAction: UIActivityIndicatorView!
    
    // MARK: - Actions
    @IBAction func submitAction(sender: AnyObject) {
        if checkChanges() > 1 {
            var ids: [Int] = []
            for pict in self.pictures.reverse() {
                if let id = Int(pict.picid) {
                    ids.append(id)
                }
            }
            GoogleAnalitics.send(GoogleAnalitics.Profile.Category, action: GoogleAnalitics.Profile.ORDER_PICTURES)
            Net.orderPicture(ids)
        }
        self.relateOrders()
        self.checkChanges()
    }
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UICollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureCollectionViewCell", forIndexPath: indexPath)
        if let pictureCollectionViewCell = collectionViewCell as? PictureCollectionViewCell {
            let picture = pictures[indexPath.row]
            if let url = NSURL(string: picture.getUrl()) {
                pictureCollectionViewCell.pictureImage.nk_cancelLoading()
                pictureCollectionViewCell.pictureImage.nk_setImageWith(url)
            }
        }
        return collectionViewCell
    }
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let pictureCollectionViewCell = cell as? PictureCollectionViewCell {
            pictureCollectionViewCell.pictureImage.nk_cancelLoading()
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionViewWidth = (self.collectionView.bounds.size.width - 20) / 2.0
        return CGSize(width: collectionViewWidth, height: collectionViewWidth)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DetailedImageViewController") as? DetailedImageViewController {
            let picture = pictures[indexPath.row]
            controller.image = picture
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    // Reorderable
    func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        if atIndexPath.row < toIndexPath.row {
            let atPicture = self.pictures[atIndexPath.row]
            for index in atIndexPath.row + 1...toIndexPath.row {
                let nextPicture = self.pictures[index]
                self.pictures[index - 1] = nextPicture
            }
            self.pictures[toIndexPath.row] = atPicture
        }else{
            let atPicture = self.pictures[atIndexPath.row]
            
            for index in (toIndexPath.row...atIndexPath.row - 1).reverse() {
                let nextPicture = self.pictures[index]
                self.pictures[index + 1] = nextPicture
            }
            self.pictures[toIndexPath.row] = atPicture
        }
        
        FBoxHelper.delay(0.3) { () -> () in
            self.checkChanges()
        }
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        return 0.3
    }
    
    func scrollTrigerPaddingInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.collectionView.contentInset.top, 5, self.collectionView.contentInset.bottom, 5)
    }
    
    // MARK: - Helper methods
    private func checkChanges() -> Int {
        var changes = 0
        for row in 0 ..< self.pictures.count {
            let picture = self.pictures[row]
            let relatedOrder = self.rowsToOrder[row]
            if relatedOrder != picture.orderid {
                changes += 1
            }
        }
        if changes > 0 {
            self.showSubmitButton()
        }else{
            self.hideSubmitButton()
        }
        return changes
    }
    
    private let closedHeight: CGFloat = -60.0
    private let openedHeight: CGFloat = 8
    private func hideSubmitButton() {
        if self.bottomSubmit.constant != closedHeight {
            self.bottomSubmit.constant = closedHeight
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, -self.closedHeight, 0)
                self.view.layoutIfNeeded()
                }, completion:{(_) -> Void in
            })
        }
    }
    private func showSubmitButton() {
        if self.bottomSubmit.constant != openedHeight {
            self.bottomSubmit.constant = openedHeight
            UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
                self.collectionView.contentInset = UIEdgeInsetsZero
                self.view.layoutIfNeeded()
                }, completion:{(_) -> Void in
            })
        }
    }
}
