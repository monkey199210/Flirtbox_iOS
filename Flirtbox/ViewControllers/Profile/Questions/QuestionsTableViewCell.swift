//
//  QuestionsTableViewCell.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit

class QuestionsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func editAction(sender: AnyObject) {
        self.vc.editQuestion(self.question)
    }
    
    var question: Question!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    weak var vc: QuestionsViewController!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var answer: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var bubbleImage: UIImageView!
}
