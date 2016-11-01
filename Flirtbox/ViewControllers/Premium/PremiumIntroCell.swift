//
//  PremiumIntroCell.swift
//  Flirtbox
//
//  Created by Rui Caneira on 8/3/16.
//  Copyright © 2016 flirtbox. All rights reserved.
//


import UIKit

class PremiumIntroCell: UICollectionViewCell {
    
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var premiumImg: UIImageView!
}
struct PremiumIntro {
    var image: String = ""
    var title: String = ""
    var intro: String = ""
}
