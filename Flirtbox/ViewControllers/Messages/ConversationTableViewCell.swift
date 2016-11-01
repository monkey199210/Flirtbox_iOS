//
//  InboxTableViewCell.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 09.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
protocol ConversationCellActionsDelegate {
    func cellClosed(cell: ConversationTableViewCell)
    func cellOpened(cell: ConversationTableViewCell)
    func cellBeginOpen(cell: ConversationTableViewCell)
    func cellMoved(cell: ConversationTableViewCell)
    func deleteMessageTapped(cell: ConversationTableViewCell)
    func archiveMessageTapped(cell: ConversationTableViewCell)
    func allowOpen() -> Bool
}
class ConversationTableViewCell: UITableViewCell {
    var delegate: ConversationCellActionsDelegate?
    var msg: FBMessage?
	
	var unreadCount: Int = 0 {
		didSet {
			if unreadCount > 0 {
				self.countImage.hidden = false
				self.msgCount.text = String(unreadCount)
			}else{
				self.countImage.hidden = true
				self.msgCount.text = " "
			}
		}
	}
	private var kClosedPosition: CGFloat = -158.0
	func close() {
		left.constant = 0.0
		lastXPosition = left.constant
		animateConstraints { () -> () in
			self.delegate?.cellClosed(self)
		}
	}
	
	//MARK: -Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ConversationTableViewCell.panGesture(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		// Configure the view for the selected state
	}
	
	func setupWithConversation(conversation: FBMessage, conversationType: eConversationType){
		self.name.text = conversation.username;
		self.message.text = conversation.lastMessage;
		self.date.text = String.getFormattedDate(conversation.receivedAt);
		if(conversationType != .Inbox){
			kClosedPosition = -79;
			self.archiveButton.hidden = true;
			self.unreadCount = 0;
		}
		else{
			kClosedPosition = -158;
			self.archiveButton.hidden = false;
			if let unreadCountStr = Int("\(conversation.unreadMessages)") {
				self.unreadCount = unreadCountStr ?? 0
			}else{
				self.unreadCount = 0
			}
		}
		self.msg = conversation
		self.avatarImage.layer.borderWidth = 0.0
		self.avatarImage.layer.masksToBounds = false
		self.avatarImage.layer.borderColor = UIColor.clearColor().CGColor
		self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2.0
		self.avatarImage.clipsToBounds = true
		var imageUrl: String
		if let avatar = self.msg!.avatar {
			imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_SMALL + avatar
		}else{
			imageUrl = FBNet.PROFILE_DEFAULT_PIC
		}
		if let url = NSURL(string: imageUrl) {
			self.avatarImage.nk_cancelLoading()
			self.avatarImage.nk_setImageWith(url)
		}
	}
	//
	
	//MARK: -Gesture recognizers stuff
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    var beginningPoint: CGPoint?
    var lastXPosition: CGFloat = 0.0
    func panGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.locationInView(self)
        if gestureRecognizer.state == UIGestureRecognizerState.Began && self.delegate!.allowOpen() {
            beginningPoint = location
        }else if (gestureRecognizer.state == UIGestureRecognizerState.Ended || gestureRecognizer.state == UIGestureRecognizerState.Cancelled) && beginningPoint != nil {
            beginningPoint = nil
            let velocity = gestureRecognizer.velocityInView(self)
            if velocity.x < 0 {
                open()
            }else{
                close()
            }
        }else if beginningPoint != nil {
            var position = location.x - beginningPoint!.x + lastXPosition
            var moved = true
            if position < kClosedPosition {
                position = kClosedPosition
                moved = false
            }else if position > 0 {
                position = 0.0
                moved = false
            }
            left.constant = position
            self.setNeedsLayout()
            self.layoutIfNeeded()
            if moved {
                delegate?.cellMoved(self)
            }
        }
    }
	//
	
	//MARK: -Private methods
    private func open() {
        left.constant = kClosedPosition
        lastXPosition = left.constant
        animateConstraints { () -> () in
            self.delegate?.cellOpened(self)
        }
    }
    private func animateConstraints(completition: (()->())?) {
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion:{ (_) -> Void in
                if completition != nil {
                    completition!()
                }
        })
    }
	//

 
    //MARK: -Outlets
    @IBAction func archiveAction(sender: AnyObject) {
        self.delegate?.archiveMessageTapped(self)
    }
    @IBAction func deleteAction(sender: AnyObject) {
        self.delegate?.deleteMessageTapped(self)
    }
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var msgCount: UILabel!
    @IBOutlet weak var countImage: UIImageView!
	@IBOutlet weak var archiveButtonSizeConstraint: NSLayoutConstraint!
	@IBOutlet weak var archiveButton: UIButton!
	//
}
