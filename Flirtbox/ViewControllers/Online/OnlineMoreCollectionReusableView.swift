//
//  OnlineMoreCollectionReusableView.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 28.01.16.
//  Copyright © 2016 flirtbox. All rights reserved.
//

import UIKit

class OnlineMoreCollectionReusableView: UICollectionReusableView {
    weak var onlineViewController: OnlineViewController?
    @IBOutlet weak var moreButton: UIButton!
    @IBAction func moreAction(sender: AnyObject) {
        self.onlineViewController?.changeOnlineDays()
    }
}
