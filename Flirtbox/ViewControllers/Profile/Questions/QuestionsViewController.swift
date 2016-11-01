//
//  QuestionsViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 08.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
import LGAlertView
class Question {
    var id: String!
    var title: String!
    var example: String!
    var oldExample: String!
    var isFilled: Bool = false
    init(id: String, title: String, example: String, isFilled: Bool) {
        self.id = id
        self.title = title
        self.example = example
        self.oldExample = example
        self.isFilled = isFilled
    }
}
class QuestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {

    var user: FBSearchedUser?
    var userDetailed: FBUser?
    
    weak var profileViewController: ProfileViewController?
    
    deinit {
        FBEvent.onProfileReceived().removeListener(self)
        FBEvent.onAuthenticated().removeListener(self)
    }
    
    // MARK: - Lifecycle
    private var questions: [Question] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 170
        
        let bgView = UIView(frame: self.view.bounds)
        bgView.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundView = bgView
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        
        if self.user == nil && self.userDetailed == nil {
            if AuthMe.isAuthenticated() {
                if let user = UserProfile.currentUser() {
                    configureWithUser(user)
                }
                FBEvent.onProfileReceived().listen(self, callback: { [unowned self] (user) -> Void in
                    self.configureWithUser(user)
                    FBEvent.onProfileReceived().removeListener(self)
                })
            }
            FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
                if isAuthenticated {
                    if let user = UserProfile.currentUser() {
                        self.configureWithUser(user)
                    }
                }else{
                    self.questions.removeAll()
                    self.tableView.reloadData()
                }
            }
        }else{
            if let user = self.profileViewController?.userDetailed {
                configureWithUser(user)
                userAvatar = self.user?.avatar
            }
        }
    }
    private var userAvatar: String? {
        didSet {
            if let _ = userAvatar {
                self.tableView.reloadData()
            }
        }
    }
    func updateWithUser(user: FBUser) {
        configureWithUser(user)
    }
    private func configureWithUser(user: FBUser) {
        if let about = user.qanda.aboutMe {
            self.fillFromArray(about)
        }
        if let stuff = user.qanda.stuffILike {
            self.fillFromArray(stuff)
        }
        if let attitude = user.qanda.myAttitude {
            self.fillFromArray(attitude)
        }
        if self.user == nil && self.userDetailed == nil {
            Net.questions().onSuccess { (questions) -> Void in
                for (_, value) in questions.values {
                    for question in value {
                        if self.questionWithId(question.id) == nil {
                            self.questions.append(Question(id: question.id, title: question.title, example: question.example, isFilled: false))
                        }else if let qst = self.questionWithId(question.id) {
                            qst.oldExample = question.example
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
        self.tableView.reloadData()
    }
    private func fillFromArray(qs: [UserQuestion]) {
        for question in qs {
            if let q = self.questionWithId(question.id) {
                q.title = question.title
                q.example = question.answer
            }else{
                self.questions.append(Question(id: question.id, title: question.title, example: question.answer, isFilled: true))
            }
        }
    }
    private func questionWithId(id: String) -> Question? {
        for question in self.questions {
            if question.id == id {
                return question
            }
        }
        return nil
    }
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let question = self.questions[indexPath.row]
        if question.isFilled {
            self.selectedQuestion = question
			let alert = UIAlertView(title: "Remove my answer?", message: "", delegate: self, cancelButtonTitle: "_CANCEL".localized.uppercaseString, otherButtonTitles: "_YES".localized.uppercaseString)
            alert.show()
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    private let kButtonDefaultHeight: CGFloat = 30.0
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QuestionsTableViewCell", forIndexPath: indexPath)
        if let questionsTableViewCell = cell as? QuestionsTableViewCell {
            let question = self.questions[indexPath.row]
            
            questionsTableViewCell.avatar.layer.borderWidth = 0.0
            questionsTableViewCell.avatar.layer.masksToBounds = false
            questionsTableViewCell.avatar.layer.borderColor = UIColor.clearColor().CGColor
            questionsTableViewCell.avatar.layer.cornerRadius = questionsTableViewCell.avatar.frame.size.width/2.0
            questionsTableViewCell.avatar.clipsToBounds = true
            
            if self.user == nil && self.userDetailed == nil {
                UserProfile.getCircledMainImage({ (image) -> Void in
                    questionsTableViewCell.avatar.image = image
                })
                questionsTableViewCell.buttonHeight.constant = kButtonDefaultHeight
                questionsTableViewCell.editButton.hidden = false
            }else{
                var imageUrl: String
                if let avatar = self.userAvatar {
                    imageUrl = avatar.hasPrefix("http") ? avatar : FBNet.PROFILE_PIC_SMALL + avatar
                }else{
                    imageUrl = FBNet.PROFILE_DEFAULT_PIC
                }
                if let url = NSURL(string: imageUrl) {
                    questionsTableViewCell.avatar.nk_cancelLoading()
                    questionsTableViewCell.avatar.nk_setImageWith(url)
                }
                questionsTableViewCell.buttonHeight.constant = 0.0
                questionsTableViewCell.editButton.hidden = true
            }
            questionsTableViewCell.vc = self
            questionsTableViewCell.question = question
            questionsTableViewCell.questionLabel.text = question.title
			questionsTableViewCell.answer.text = String(htmlEncodedString: question.example)
            questionsTableViewCell.backgroundColor = UIColor.clearColor()
            questionsTableViewCell.contentView.backgroundColor = UIColor.clearColor()
            questionsTableViewCell.bubbleImage.hidden = !question.isFilled
            questionsTableViewCell.setNeedsLayout()
            questionsTableViewCell.layoutIfNeeded()
        }
        return cell
    }
    
    // MARK: - Helper methods
    func editQuestion(question: Question) {
        let textView = UITextView(frame: CGRectMake(0, 0, 260, 100))
        let font = UIFont(name: "Roboto", size: 13.0)
        textView.font = font
        textView.autocapitalizationType = .Sentences
        textView.textColor = UIColor(red:0.41, green:0.43, blue:0.44, alpha:1)
        if question.isFilled && question.example.length > 0 {
            textView.text = question.example
        }
        let datePicker = LGAlertView(viewStyleWithTitle: nil, message: question.title, view: textView, buttonTitles: ["_SUBMIT".localized], cancelButtonTitle: "_CANCEL".localized, destructiveButtonTitle: nil, actionHandler: { [weak textView] (alertView, name, index) -> Void in
            let description = textView?.text
            if let descr = description where descr.length > 0 {
                GoogleAnalitics.send(GoogleAnalitics.OwnQuestions.Category, action: GoogleAnalitics.OwnQuestions.ANSWER)
                Net.updateProfileQuestion(question.id, value: descr).onSuccess(callback: { (_) -> Void in
                    for questionIndex in 0 ..< self.questions.count {
                        if self.questions[questionIndex].id == question.id {
                            self.questions[questionIndex].example = descr
                            self.questions[questionIndex].isFilled = true
                            break
                        }
                    }
                    self.tableView.reloadData()
                })
            }
            }, cancelHandler: { (alertView,result) -> Void in
                
            }, destructiveHandler: nil)
        datePicker.showAnimated(true, completionHandler: {
            textView.becomeFirstResponder()
        })
    }
    
    // MARK: - UIAlertViewDelegate
    private var selectedQuestion: Question?
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if let question = self.selectedQuestion where alertView.cancelButtonIndex != buttonIndex {
            GoogleAnalitics.send(GoogleAnalitics.OwnQuestions.Category, action: GoogleAnalitics.OwnQuestions.EMPTY)
            Net.updateProfileQuestion(question.id, value: "").onSuccess(callback: { (_) -> Void in
                for questionIndex in 0 ..< self.questions.count {
                    if self.questions[questionIndex].id == question.id {
                        self.questions[questionIndex].example = self.questions[questionIndex].oldExample
                        self.questions[questionIndex].isFilled = false
                        break
                    }
                }
                self.tableView.reloadData()
            })
        }
    }
}
