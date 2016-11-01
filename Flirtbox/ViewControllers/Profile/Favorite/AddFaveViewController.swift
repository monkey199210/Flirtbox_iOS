//
//  AddFaveViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import LGAlertView

class AddFaveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Lifecycle
    var category: String? {
        didSet{
            if let cat = category {
                for c in self.faves {
                    if c.tag.uppercaseString == cat.uppercaseString {
                        self.selectedCategory = c
                        break
                    }
                }
            }
        }
    }
    var selectedTags: Array<String> = [] {
        didSet {
            for tag in self.selectedTags {
                self.tags.insert(tag)
            }
        }
    }
    private var tags = Set<String>() {
        didSet {
            self.collectionView.reloadData()
            checkSubmit()
        }
    }
    private var selectedCategory: (tag: String, title: String)? {
        didSet {
            guard let category = selectedCategory else{return}
            self.categoryButton.setTitle(category.title, forState: .Normal)
            checkSubmit()
        }
    }
    weak var profileViewController: ProfileViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedCategory = faves.first!
        
        tagText.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        tagText.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        tagText.autoCompleteCellHeight = 35.0
        tagText.maximumAutoCompleteCount = 200
        tagText.hidesWhenSelected = true
        tagText.hidesWhenEmpty = true
        tagText.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        tagText.autoCompleteAttributes = attributes
        
        tagText.onTextChange = {[weak self] text in
            if let category = self?.selectedCategory where !text.isEmpty {
                Net.localValues(category.tag, animated: false).onSuccess { (values) -> Void in
                    let valueStrings = values.map({ (value) -> String in
                        return value.text
                    })
                    let filtered = valueStrings.filter({ (txt) -> Bool in
                        return txt.lowercaseString.containsString(text.lowercaseString)
                    })
                    if filtered.count > 0 {
                        self?.tagText.autoCompleteStrings = filtered
                        self?.tagText.autoCompleteTableView?.hidden = false
                    }else{
                        self?.tagText.autoCompleteStrings = nil
                        self?.tagText.autoCompleteTableView?.hidden = true
                    }
                }
            }
        }
        
        tagText.onSelect = {[weak self] text, indexpath in
            if !text.isEmpty {
                self?.tags.insert(text)
                self?.tagText.text = ""
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Actions
    @IBAction func chooseCategoryAction(sender: AnyObject) {
        self.openWithValues("Favourites", item: "")
    }
    @IBAction func addTagAction(sender: AnyObject) {
        if !self.tagText.text!.isEmpty {
            tags.insert(self.tagText.text!)
            self.tagText.text = ""
        }
    }
    @IBAction func submitAction(sender: AnyObject) {
        if let category = selectedCategory where tags.count > 0 {
            let tagItems = Array(tags)
            GoogleAnalitics.send(GoogleAnalitics.OwnFavorites.Category, action: GoogleAnalitics.OwnFavorites.UPDATE, label: category.tag)
            Net.updateProfile(category.tag, value: tagItems)
            self.close()
        }
    }
    @IBAction func cancelAction(sender: AnyObject) {
        self.close()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var tagText: AutoCompleteTextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Helper methods
    private func checkSubmit() {
        if let _ = selectedCategory where tags.count > 0 {
            self.submitButton.enabled = true
        }else{
            self.submitButton.enabled = false
        }
    }
    func openTags() {
        self.tagText.becomeFirstResponder()
    }
    private func close() {
        self.profileViewController?.closeAddFave()
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.alpha = 0.0
            }, completion:{ (_) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    private func openWithValues(title: String, item: String) {
        self.view.endEditing(true)
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        let alertPicker = LGAlertView(viewStyleWithTitle: title, message: "", view: picker, buttonTitles: ["OK"], cancelButtonTitle: "_CANCEL".localized.uppercaseString, destructiveButtonTitle: nil, actionHandler: { [weak self, unowned picker] (alertView, name, index) -> Void in
            let item = self?.faves[picker.selectedRowInComponent(0)]
            self?.selectedCategory = item
            self?.tagText.becomeFirstResponder()
            }, cancelHandler: { [weak self] (alertView,result) -> Void in
                self?.tagText.becomeFirstResponder()
            }, destructiveHandler: nil)
        alertPicker.showAnimated(true, completionHandler: nil)
    }
    
    // MARK: - UICollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCollectionViewCell", forIndexPath: indexPath)
        if let tagCollectionViewCell = collectionViewCell as? TagCollectionViewCell {
            tagCollectionViewCell.tagText.text = self.tags[self.tags.startIndex.advancedBy(indexPath.row)]
        }
        return collectionViewCell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let font = UIFont(name: "Roboto", size: 13)!
        let tag = self.tags[self.tags.startIndex.advancedBy(indexPath.row)] as NSString
        let size = font.sizeOfString(tag, constrainedToWidth: DBL_MAX, constrainedToHeight: 29)
        return CGSizeMake(size.width + 16, 29)
    }
    
    // MARK: - UIPickerViewDataSource
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return faves.count
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - UIPickerViewDelegate
    private var faves: [(tag: String, title: String)] = Net.faves
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return faves[row].title
    }
}
