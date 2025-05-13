//
//  ArchiveReplyViewController.swift
//  MusicScale
//
//  Created by 윤범태 on 5/13/25.
//

import UIKit

class ArchiveReplyViewController: UIViewController {
  @IBOutlet weak var tblViewReplyList: UITableView!
  @IBOutlet weak var txvDiscussionReply: UITextView!
  @IBOutlet weak var lblCurrentUser: UILabel!
  @IBOutlet weak var btnSubmit: UIButton!
  
  var documentID: String?
  var postTitle: String?
  private var replies: [Reply] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    txvDiscussionReply.layer.borderColor = UIColor.lightGray.cgColor
    txvDiscussionReply.layer.borderWidth = 1.0
    txvDiscussionReply.layer.cornerRadius = 8.0
    txvDiscussionReply.clipsToBounds = true
    txvDiscussionReply.delegate = self
    
    btnSubmit.backgroundColor = .systemGray5
    btnSubmit.layer.cornerRadius = 7
    btnSubmit.setTitle("loc.submit".localized(), for: .normal)
    
    tblViewReplyList.dataSource = self
    tblViewReplyList.delegate = self
    
    lblCurrentUser.text = FirebaseAuthManager.shared.currentUser?.uid[0..<4] ?? "loc.anon".localized()
    
    loadReplies()
    
    if let postTitle {
      title = "\(postTitle)/\("loc.discussion".localized())"
    } else {
      title = "loc.discussion".localized()
    }
  }
  
  private func loadReplies() {
    SwiftSpinner.show("loc.loading_discussion_replies".localized())
    if let documentID {
      FirebasePostManager.shared.readReplies(documentID: documentID) { [unowned self] replies in
        // print("readReplies \(documentID):", replies)
        self.replies = replies
        tblViewReplyList.reloadData()
        
        if replies.count > 0 {
          tblViewReplyList.scrollToRow(at: IndexPath(row: replies.count - 1, section: 0), at: .bottom, animated: true)
        }
        
        SwiftSpinner.hide()
      } errorHandler: { err in
        print(err)
        SwiftSpinner.hide()
      }
    }
  }
  
  @IBAction func btnActReplySubmit(_ sender: UIButton) {
    txvDiscussionReply.resignFirstResponder()
    // btnSubmit.disabled
    
    guard let documentID,
          let user = FirebaseAuthManager.shared.currentUser else {
      print(#function, "documentID/userID is nil")
      return
    }
    
    FirebasePostManager.shared.addReply(
      documentID: documentID,
      reply: Reply(
        postDocumentID: documentID,
        authorUID: user.uid,
        content: txvDiscussionReply.text
      ), completionHandler: { [unowned self] replyID in
        simpleAlert(self, message: "loc.reply_submit_message".localized(), title: "loc.reply_submit_title".localized())
        loadReplies()
        txvDiscussionReply.text = ""
      })
  }
}

extension ArchiveReplyViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    replies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Reply_Reusable") as? ReplyCell
    cell?.configure(reply: replies[indexPath.row]) { reply in
      guard let id = reply.id else {
        print("no id: \(reply)")
        return
      }
      
      simpleYesAndNo(
        self,
        message: "loc.warn_delete_message".localized(),
        title: "loc.delete".localized()
      ) { _ in
        FirebasePostManager.shared.deleteReply(
          documentID: reply.postDocumentID,
          replyID: id,
          completionHandler:  { replyID in
          self.loadReplies() // 삭제 후 목록 새로고침
        })
      }
    }
    
    return cell ?? UITableViewCell()
  }
}

extension ArchiveReplyViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if textView.text.count >= 1000 {
      return false
    }
    
    return true
  }
}

class ReplyCell: UITableViewCell {
  @IBOutlet weak var lblUserId: UILabel!
  @IBOutlet weak var lblUploadDate: UILabel!
  @IBOutlet weak var txvComment: UITextView!
  @IBOutlet weak var btnDelete: UIButton!
  private var reply: Reply?
  var onDelete: ((Reply) -> Void)?
  
  func configure(reply: Reply, onDelete: ((Reply) -> Void)? = nil) {
    lblUserId.text = reply.authorUID[0..<4]
    txvComment.text = reply.content
    
    lblUploadDate.text = if let timestamp = reply.createdAt {
      FirebaseUtil.timestampToDate(timestamp).localizedRelativeTime
    } else {
      "loc.unknown".localized()
    }
    
    btnDelete.isHidden = reply.authorUID != FirebaseAuthManager.shared.currentUser?.uid
    self.reply = reply
    self.onDelete = onDelete
  }
  
  @IBAction func btnActDelete(_ sender: UIButton) {
    guard let reply else {
      print("no reply")
      return
    }
    
    onDelete?(reply)
  }
}
