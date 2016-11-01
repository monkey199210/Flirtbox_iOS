//
//  MessagesViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 09.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit

enum eConversationType {
    case Inbox
    case Outbox
    case Archived
	case Indefinite
}

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConversationCellActionsDelegate, ChatDelegate {

	@IBOutlet weak var controllerTitleLabel: UILabel!
    // MARK: - Lifecycle
	private var inboxMessages: [FBMessage] = []{
		didSet{
			if(self.type == .Inbox){
				self.messagesToDisplay = inboxMessages;
			}
		}
	}
	private var outboxMessages : [FBMessage] = []{
		didSet{
			if(self.type == .Outbox){
				self.messagesToDisplay = outboxMessages;
			}
		}
	}
	private var archivedMessages: [FBMessage/*FBArchivedMessage*/] = []{
		didSet{
			if(self.type == .Archived){
				self.messagesToDisplay = archivedMessages;
			}
		}
	}
	
	private var messagesToDisplay : [FBMessage] = []{
		didSet{
			self.tableView.reloadData();
		}
	}
	private var type: eConversationType = .Indefinite {
		didSet{
			openedCell?.close();
			deselectAllButtons();
			self.activity.startAnimating();
			switch type {
			case .Inbox:
				inboxButton.selected = true;
				selectedLineLeading.constant = 0.0;
				Net.inbox(nil, limit: nil).onSuccess { (messages) -> Void in
					self.activity.stopAnimating()
					self.inboxMessages = messages
					}.onFailure { (error) -> Void in
						self.activity.stopAnimating()
				}
				break;
			case .Outbox:
				outboxButton.selected = true;
				selectedLineLeading.constant = self.view.bounds.size.width / 3.0;
				Net.outbox(nil, limit: nil).onSuccess { (messages) -> Void in
					self.activity.stopAnimating()
					self.outboxMessages = messages
					}.onFailure { (error) -> Void in
						self.activity.stopAnimating()
				}
				break;
			case .Archived:
				archiveButton.selected = true;
				selectedLineLeading.constant = 2.0 * self.view.bounds.size.width / 3.0;
				Net.archivebox(nil, limit: nil).onSuccess { (messages) -> Void in
					self.activity.stopAnimating()
					self.archivedMessages = messages
					}.onFailure { (error) -> Void in
						self.activity.stopAnimating()
				}
				break;
			case .Indefinite:
				self.activity.stopAnimating()
			break;
			}
			animateConstraints()
		}
	}
		
    override func viewDidLoad() {
        super.viewDidLoad()
		self.inboxButton.setTitle("_INBOX".localized.uppercaseString, forState: .Normal);
		self.outboxButton.setTitle("_OUTBOX".localized.uppercaseString, forState: .Normal);
		self.archiveButton.setTitle("_ARCHIVE".localized.uppercaseString, forState: .Normal);
		self.controllerTitleLabel.text = "_MESSAGES".localized;
        self.searchButton.hidden = true
        self.deleteButton.hidden = true
		
        self.activity.startAnimating()
		self.tableView.registerClass(EmptyListCell.self, forCellReuseIdentifier: "EmptyListCell");
		self.tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		if(self.type == .Indefinite){
			self.type = .Inbox;
		}
		else{
			//Tricky way to re-assign property to itself
			let tmp = self.type;
			self.type = tmp;
		}
        FBoxHelper.getMainController()?.showMenuButton(true)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var outboxButton: UIButton!
    @IBOutlet weak var inboxButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedLineLeading: NSLayoutConstraint!
    
    // MARK: - Actions
    @IBAction func inboxAction(sender: AnyObject) {
        type = .Inbox
    }
    @IBAction func outboxAction(sender: AnyObject) {
        type = .Outbox
    }
    @IBAction func archiveAction(sender: AnyObject) {
        type = .Archived
    }
    
    // MARK: - Helper methods
    private func deselectAllButtons(){
        inboxButton.selected = false
        outboxButton.selected = false
        archiveButton.selected = false
    }
    private func animateConstraints() {
        UIView.animateWithDuration(FBoxConstants.kAnimationFastDuration, delay: 0.0, usingSpringWithDamping: FBoxConstants.kAnimationDamping, initialSpringVelocity: FBoxConstants.kAnimationInitialVelocity, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:nil)
    }
    
    // MARK: - UICollectionView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(messagesToDisplay.count == 0){
			return 1;
		}
		else{
			return messagesToDisplay.count;
		}
    }
	
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if(self.messagesToDisplay.count == 0){
			let emptyCell = tableView.dequeueReusableCellWithIdentifier("EmptyListCell") ?? UITableViewCell();
			emptyCell.textLabel?.textColor = UIColor.blackColor();
			emptyCell.selectionStyle = .None;
			return emptyCell;
		}

        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationTableViewCell", forIndexPath: indexPath)
        if let conversationCell = cell as? ConversationTableViewCell {
			let conversation = self.messagesToDisplay[indexPath.row];
			conversationCell.setupWithConversation(conversation, conversationType: type);
			conversationCell.delegate = self;
        }
        return cell
    }
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let inboxTableViewCell = cell as? ConversationTableViewCell {
            inboxTableViewCell.avatarImage.nk_cancelLoading()
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if(self.messagesToDisplay.count == 0){
			return;
		}
        if let chatViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as? ChatViewController {
			var conversation : FBMessage? = nil;
			if type == .Inbox || type == .Outbox {
				conversation = self.messagesToDisplay[indexPath.row]
            }else{
				conversation = self.archivedMessages[indexPath.row];
            }
			openedCell?.close()
			chatViewController.type = self.type;
			FBoxHelper.getMainController()?.hideMenuButton(true)
			if(conversation != nil){
				conversation!.unreadMessages = 0
				chatViewController.message = conversation
				chatViewController.chatDelegate = self;
				self.navigationController?.pushViewController(chatViewController, animated: true);
			}
        }
    }
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	
	
    // MARK: - MessageCellsActionsDelegate
    var openedCell: ConversationTableViewCell?
    func cellOpened(cell: ConversationTableViewCell) {
        openedCell = cell
        self.tableView.scrollEnabled = true
    }
    func cellClosed(cell: ConversationTableViewCell) {
        self.tableView.scrollEnabled = true
    }
    func cellBeginOpen(cell: ConversationTableViewCell) {
        self.tableView.scrollEnabled = false
    }
    func cellMoved(cell: ConversationTableViewCell) {
        if openedCell != nil {
            openedCell!.close()
            openedCell = nil
        }
        self.tableView.scrollEnabled = false
    }
    func deleteMessageTapped(cell: ConversationTableViewCell) {
        if let msg = cell.msg {
			let alertController = UIAlertController(title: "_CONVERSATION_DELETE_SINGLE".localized, message: "", preferredStyle: .Alert)
			
			let cancelAction = UIAlertAction(title: "_CANCEL".localized.capitalizedString, style: .Cancel) { (action) in
    
			}
			alertController.addAction(cancelAction)
			
			let OKAction = UIAlertAction(title: "_YES".localized.capitalizedString, style: .Default) { (action) in
				
				GoogleAnalitics.send(GoogleAnalitics.MessageBox.Category, action: GoogleAnalitics.MessageBox.DELETE)
				Net.deleteConversation(msg.username).onSuccess(callback: { (_) -> Void in
					print("message deleted")
					if let indexPath = self.tableView.indexPathForCell(cell) {
						switch self.type{
						case .Archived:
							self.archivedMessages.removeAtIndex(indexPath.row);
						case .Inbox:
							self.inboxMessages.removeAtIndex(indexPath.row)
						case .Outbox:
							self.outboxMessages.removeAtIndex(indexPath.row);
						default:
							break;
						}
						self.tableView.reloadData();
					}
				});
				self.openedCell?.close()
			}
			alertController.addAction(OKAction)
			
			self.presentViewController(alertController, animated: true) {
			}
			
        }
		
    }
    func archiveMessageTapped(cell: ConversationTableViewCell) {
		if(type == .Archived){
			return;
		}
        if let msg = cell.msg {
            if let uid = Int(msg.uid) {
				if let msg = cell.msg {
					let alertController = UIAlertController(title: "_CONVERSATION_ARCHIVE_SINGLE".localized, message: "", preferredStyle: .Alert)
					
					let cancelAction = UIAlertAction(title: "_CANCEL".localized.capitalizedString, style: .Cancel) { (action) in
						
					}
					alertController.addAction(cancelAction)
					
					let OKAction = UIAlertAction(title: "_YES".localized.capitalizedString, style: .Default) { (action) in
						GoogleAnalitics.send(GoogleAnalitics.MessageBox.Category, action: GoogleAnalitics.MessageBox.ARCHIVE)
						Net.archiveConversation([uid]).onSuccess(callback: { (_) -> Void in
							print("message archived")
							if let indexPath = self.tableView.indexPathForCell(cell) {
								self.inboxMessages.removeAtIndex(indexPath.row);
								self.tableView.reloadData();
							}
						})
						self.openedCell?.close()
					}
					alertController.addAction(OKAction)
					
					self.presentViewController(alertController, animated: true) {
					}
				}
			}
		}
	}
    private var isAllowOpen = false
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isAllowOpen = false
        if openedCell != nil {
            openedCell!.close()
            openedCell = nil
        }
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isAllowOpen = true
    }
    func allowOpen() -> Bool {
        return isAllowOpen
    }
	//MARK: Chat Delegate
	func deleteConversation(conversation: FBMessage,completionHandler: (result: Bool)->()) {
			let alertController = UIAlertController(title: "_CONVERSATION_DELETE_SINGLE".localized, message: "", preferredStyle: .Alert)
			
			let cancelAction = UIAlertAction(title: "_CANCEL".localized.capitalizedString, style: .Cancel) { (action) in
    
			}
			alertController.addAction(cancelAction)
			
			let OKAction = UIAlertAction(title: "_YES".localized.capitalizedString, style: .Default) { (action) in
				
				GoogleAnalitics.send(GoogleAnalitics.MessageBox.Category, action: GoogleAnalitics.MessageBox.DELETE)
				Net.deleteConversation(conversation.username).onSuccess(callback: { (_) -> Void in
					print("message deleted")
					
						switch self.type{
						case .Archived:
							let found = self.archivedMessages.indexOf{ $0.uid == conversation.uid };
							if let indexPath = found {
								self.archivedMessages.removeAtIndex(indexPath);
							}
						case .Inbox:
							let found = self.inboxMessages.indexOf{ $0.uid == conversation.uid };
							if let indexPath = found {
								self.archivedMessages.removeAtIndex(indexPath);
							}
						case .Outbox:
							let found = self.outboxMessages.indexOf{ $0.uid == conversation.uid };
							if let indexPath = found {
								self.outboxMessages.removeAtIndex(indexPath);
							}
						default:
							break;
						}
						self.tableView.reloadData();
					completionHandler(result: true);
				});
				self.openedCell?.close()
			}
			alertController.addAction(OKAction)
			
			self.presentViewController(alertController, animated: true) {
			}
	}
	func archiveConversation(conversation: FBMessage,completionHandler: (result: Bool)->()) {
		if let uid = Int(conversation.uid) {
				let alertController = UIAlertController(title: "_CONVERSATION_ARCHIVE_SINGLE".localized, message: "", preferredStyle: .Alert)
				
				let cancelAction = UIAlertAction(title: "_CANCEL".localized.capitalizedString, style: .Cancel) { (action) in
				}
				alertController.addAction(cancelAction)
				
				let OKAction = UIAlertAction(title: "_YES".localized.capitalizedString, style: .Default) { (action) in
					GoogleAnalitics.send(GoogleAnalitics.MessageBox.Category, action: GoogleAnalitics.MessageBox.ARCHIVE)
					Net.archiveConversation([uid]).onSuccess(callback: { (_) -> Void in
						print("message archived")
							//								self.messagesToDisplay.removeAtIndex(indexPath.row)
						let found = self.inboxMessages.indexOf{ $0.uid == conversation.uid };
						if(found != nil){
							self.messagesToDisplay.removeAtIndex(found!);
						}
						self.tableView.reloadData();
						completionHandler(result: true);
					})
					self.openedCell?.close()
				}
				alertController.addAction(OKAction)
				
				self.presentViewController(alertController, animated: true) {
				}
		}
	}
}
