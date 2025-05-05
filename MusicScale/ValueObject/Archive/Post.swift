//
//  PostRequest.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/**
 Firebase 서버로 리퀘스트하기 위한 구조체
 */
struct Post: Codable {
  
  internal init(scaleInfo: ScaleInfo) {
    self.scaleInfo = scaleInfo
    self.authorUID = ""
  }
  
  var scaleInfo: ScaleInfo
  var authorUID: String
  @DocumentID var documentID: String?
  
  // If a Codable object being written contains a nil for an @ServerTimestamp-annotated field, it will be replaced with FieldValue.serverTimestamp() as it is sent.
  // https://firebase.google.com/docs/reference/swift/firebasefirestoreswift/api/reference/Structs/ServerTimestamp
  @ServerTimestamp var serverCreatedTS: Timestamp?
  @ServerTimestamp var serverModifiedTS: Timestamp?
  
  enum CodingKeys: String, CodingKey {
    case scaleInfo = "scale_info"
    case authorUID = "author_uid"
    case documentID = "document_id"
    case serverCreatedTS = "server_created_ts"
    case serverModifiedTS = "server_modified_ts"
  }
}
