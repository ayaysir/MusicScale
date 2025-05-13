//
//  Reply.swift
//  MusicScale
//
//  Created by 윤범태 on 5/13/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Reply: Codable {
  @DocumentID var id: String?
  var postDocumentID: String
  var authorUID: String
  @ServerTimestamp var createdAt: Timestamp?
  @ServerTimestamp var modifiedAt: Timestamp?
  var content: String
  
  enum CodingKeys: String, CodingKey {
    case postDocumentID = "post_id"
    case authorUID = "author_uid"
    case createdAt = "created_at"
    case modifiedAt = "modified_at"
    case content
  }
}
