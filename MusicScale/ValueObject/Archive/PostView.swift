//
//  PostView.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PostView: Codable {
    var viewerUID: String
    var postDocumentID: String
    @ServerTimestamp var timestamp: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case viewerUID = "viewer_uid"
        case postDocumentID = "post_document_id"
        case timestamp
    }
}
