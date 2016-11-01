//
//  ChatViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 10.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
class ChatMessage {
    var text: String!
    var time: String!
    var avatar: String?
    var isMy: Bool
    init(text: String, time: String, isMy: Bool, avatar: String?) {
        self.text = text
        self.time = time
        self.avatar = avatar
        self.isMy = isMy
    }
}

protocol ChatDelegate{
	func archiveConversation (conversation : FBMessage, completionHandler: (result: Bool)->());
	func deleteConversation (conversation : FBMessage, completionHandler: (result: Bool)->());
}
class ChatViewController: UIViewController, UITextViewDelegate, ChatTableViewCellDelegate {

    var user: FBSearchedUser?
	var converser : FBUser!
    var message: FBMessage?
    private var chatMessages: [ChatMessage] = []
	var chatDelegate : ChatDelegate?;
    // MARK: - Lifecycle
	
	var type: eConversationType = .Indefinite;
	
	
    override func viewDidLoad() {
		super.viewDidLoad();
		if(self.type != .Inbox){
			self.archiveButton.hidden = true;
		}
		
		self.archiveButton.addTarget(self, action: #selector(ChatViewController.archiveTapped(_:)), forControlEvents: .TouchUpInside)
		self.deleteButton.addTarget(self, action:#selector(ChatViewController.deleteTapped(_:)), forControlEvents: .TouchUpInside);
        self.userNameWithAge.text = " "
        self.userLocation.text = " "
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        let bgView = UIView(frame: self.view.bounds)
        bgView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        let closeBtn = UIButton(type: .Custom)
        closeBtn.frame = self.view.bounds
        closeBtn.addTarget(self, action: #selector(ChatViewController.closeKeyboard), forControlEvents: .TouchUpInside)
        bgView.addSubview(closeBtn)
        tableView.backgroundView = bgView
        
        userAvatar.layer.borderWidth = 0.0
        userAvatar.layer.masksToBounds = false
        userAvatar.layer.borderColor = UIColor.clearColor().CGColor
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width/2.0
        userAvatar.clipsToBounds = true
		userAvatar.userInteractionEnabled = true;
		
        if let user = UserProfile.currentUser() {
            configureWithUser(user)
        }
    }
	
	func archiveTapped(sender : UIButton){
		self.chatDelegate?.archiveConversation(self.message!){ result in
			self.navigationController?.popViewControllerAnimated(true);
		};
	}
	func deleteTapped(sender : UIButton){
		self.chatDelegate?.deleteConversation(self.message!){ result in
			self.navigationController?.popViewControllerAnimated(true);
		};
	}
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        messageTextView.becomeFirstResponder()
    }
    private var myUserName: String!
    private func configureWithUser(usr: FBUser) {
        myUserName = usr.general.username
        var userName: String!
        var msgAvatar: String!
        if let user = self.user {
            var imageUrl: String
            if let avatar = user.avatar {
                imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_SMALL + avatar
            }else{
                imageUrl = FBNet.PROFILE_DEFAULT_PIC
            }
            msgAvatar = imageUrl
            if let url = NSURL(string: imageUrl) {
                userAvatar.nk_cancelLoading()
                userAvatar.nk_setImageWith(url)
            }
            self.locationImage.hidden = false
            self.userNameWithAge.text = user.username + ", " + String(user.age)
			if let country = user.country{
				if country.length > 0 && user.town.length > 0 {
					self.userLocation.text = country + ", " + user.town
				}else if country.length == 0 && user.town.length > 0 {
					self.userLocation.text = user.town
				}else if country.length > 0 && user.town.length == 0 {
					self.userLocation.text = user.country
				}else{
					self.userLocation.text = " "
					self.locationImage.hidden = true
				}
			}
            userName = user.username
        }else if let msg = self.message {
            var imageUrl: String
            if let avatar = msg.avatar {
                imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_SMALL + avatar
            }else{
                imageUrl = FBNet.PROFILE_DEFAULT_PIC
            }
            msgAvatar = imageUrl
            if let url = NSURL(string: imageUrl) {
                userAvatar.nk_cancelLoading()
                userAvatar.nk_setImageWith(url)
            }
            self.locationImage.hidden = false
            Net.userData(msg.username).onSuccess(callback: { (user) -> Void in
                if user.general.age != nil {
                    self.userNameWithAge.text = user.general.username + ", " + user.general.age!
                }else{
                    self.userNameWithAge.text = user.general.username
                }
                if user.general.country.length > 0 && user.general.town?.length > 0 {
                    self.userLocation.text = user.general.country + ", " + user.general.town!
                }else if user.general.country.length == 0 && user.general.town?.length > 0 {
                    self.userLocation.text = user.general.town
                }else if user.general.country.length > 0 && user.general.town?.length == 0 {
                    self.userLocation.text = user.general.country
                }else{
                    self.userLocation.text = " "
                    self.locationImage.hidden = true
                }
				self.converser = user;
            })
            userName = msg.username
        }
        Net.conversation(userName, offset: nil, limit: nil).onSuccess(callback: { (conversation) -> Void in
            let sortedConversation = conversation.sort({ (first, second) -> Bool in
                var firstDate = NSDate(fromString: first.when, format: .Custom("yyyy-MM-dd HH:mm"))
                firstDate = firstDate.dateByAddingSeconds(NSTimeZone.localTimeZone().secondsFromGMT)
                if NSDate().secondsAfterDate(firstDate) < 0 {
                    firstDate = firstDate.dateBySubtractingHours(1)
                }
                var secondDate = NSDate(fromString: second.when, format: .Custom("yyyy-MM-dd HH:mm"))
                secondDate = secondDate.dateByAddingSeconds(NSTimeZone.localTimeZone().secondsFromGMT)
                if NSDate().secondsAfterDate(secondDate) < 0 {
                    secondDate = secondDate.dateBySubtractingHours(1)
                }
                return firstDate.timeIntervalSinceDate(secondDate) < 0
            })
            var chatMessages: [ChatMessage] = []
            var needReadMessages: [Int] = []
            for msg in sortedConversation {
                chatMessages.append(ChatMessage(text: msg.body, time: msg.when, isMy: msg.fromUsername == self.myUserName ,avatar: msgAvatar))
                if let isRead = Int(msg.read), let msgId = Int(msg.id) where isRead == 0 {
                    needReadMessages.append(msgId)
                }
            }
            if needReadMessages.count > 0 {
                GoogleAnalitics.send(GoogleAnalitics.Conversation.Category, action: GoogleAnalitics.Conversation.READ_MESSAGES)
                Net.readMessage(needReadMessages)
            }
            self.chatMessages = chatMessages
            self.tableView.reloadData()
        })
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            bottomConstraint.constant = keyboardSize.height
            UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion:{(_) -> Void in
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 0.0
        UIView.animateWithDuration(FBoxConstants.kAnimationDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(_) -> Void in
                
        })
    }
    
    // MARK: - Outlets
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userNameWithAge: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    // MARK: - Actions
	@IBAction func openProfileAction(sender: AnyObject) {
		if self.user == nil && self.message != nil {
			Net.userData(self.message!.username, animated: true).onSuccess(callback: { (user) -> Void in
				if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController {
					controller.userDetailed = user
					self.navigationController?.pushViewController(controller, animated: true)
				}
			})
		}
	}

	@IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func sendAction(sender: AnyObject) {
        var userName: String? = nil
        if let user = self.user {
            userName = user.username
        }else if let msg = self.message {
            userName = msg.username
        }
        if let username = userName where (messageTextView.text as NSString).length > 0 {
            let msgText = messageTextView.text
            GoogleAnalitics.send(GoogleAnalitics.Conversation.Category, action: GoogleAnalitics.Conversation.SEND_MESSAGE)
            Net.sendMessage(username, message: msgText).onSuccess(callback: { (_) -> Void in
                let now = NSDate().dateBySubtractingSeconds(NSTimeZone.localTimeZone().secondsFromGMT)
                self.chatMessages.append(ChatMessage(text: msgText, time: now.toString(format: .Custom("yyyy-MM-dd HH:mm")), isMy:true, avatar: nil))
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.chatMessages.count - 1, inSection: 0)], withRowAnimation: .Bottom)
                FBoxHelper.delay(0.5, closure: { () -> () in
                    self.scrollToBottom()
                })
            }).onFailure { (error) -> Void in
                UIAlertView(title: "ERROR", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
            }
            messageTextView.text = ""
            computeHeight()
            checkEmpty()
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
    }
    func textViewDidBeginEditing(textView: UITextView) {
        scrollToBottom()
    }
    func textViewDidChange(textView: UITextView) {
        checkEmpty()
        computeHeight()
    }
    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.text = ""
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        closeKeyboard()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        let chatMessage = chatMessages[indexPath.row]
        if !chatMessage.isMy {
            cell = tableView.dequeueReusableCellWithIdentifier("ChatTableViewCell", forIndexPath: indexPath)
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("ChatMyTableViewCell", forIndexPath: indexPath)
        }
        if let chatTableViewCell = cell as? ChatTableViewCell {
			chatTableViewCell.configureWithData(chatMessage.text, timeStr: chatMessage.time, usersAvatar: chatMessage.avatar);
			chatTableViewCell.delegate = self;
        }
        if let chatMyTableViewCell = cell as? ChatMyTableViewCell {
            chatMyTableViewCell.configureWithData(chatMessage.text, timeStr: chatMessage.time)
        }
        return cell!
    }
	
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let chatTableViewCell = cell as? ChatTableViewCell {
            chatTableViewCell.avatar.nk_cancelLoading()
        }
    }
    // MARK: - Helper methods
    private func scrollToBottom() {
        if self.tableView.contentSize.height > self.tableView.frame.size.height {
            tableView.setContentOffset(CGPointMake(0, tableView.contentSize.height - self.tableView.frame.size.height), animated: true)
        }
    }
    private func checkEmpty() {
        if (messageTextView.text as NSString).length > 0 {
            emptyLabel.hidden = true
        }else{
            emptyLabel.hidden = false
        }
    }
    func closeKeyboard(){
        self.view.endEditing(true)
    }
    private let kMaxHeight: CGFloat = 80
    private let kDefaultHeight: CGFloat = 40
    private func computeHeight() {
        let attributes = [NSFontAttributeName : messageTextView.font!]
        let rect = messageTextView.text!.boundingRectWithSize(CGSizeMake(messageTextView.frame.size.width - 12 , kMaxHeight), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        var height = rect.height
        if height < 40 {
            height = 40
        }
        if height > kMaxHeight {
            height = kMaxHeight
        }
        messageHeight.constant = height
        self.view.layoutIfNeeded()
    }
	
	//MARK: -OpenProfile stuff
	private func openConverserProfile(){
		if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController {
			controller.userDetailed = self.converser
			FBoxHelper.getMainController()?.hideMenuButton(false)
			self.navigationController?.pushViewController(controller, animated: true)
		}
	}	
	//MARK: - ChatTableViewCellDelegate
	func imageTapped() {
		self.openConverserProfile();
	}
}
