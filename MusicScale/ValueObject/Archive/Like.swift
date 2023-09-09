//
//  Like.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum LikeStatus: String, Codable {
    case none, like, dislike
}

struct Like: Codable {
    var status: LikeStatus
    var authorUID: String
    var postDocumentID: String
    @ServerTimestamp var timestamp: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case status
        case authorUID = "author_uid"
        case postDocumentID = "post_document_id"
        case timestamp
    }
}

struct LikeCounts: Codable {
    
    var likeCount = 0
    var dislikeCount = 0
    
    var totalCount: Int { likeCount + dislikeCount }
    var likePercent: Double { Double(likeCount) / Double(totalCount) }
    var dislikePercent: Double { Double(dislikeCount) / Double(totalCount) }
    
    static func getLikeCounts(from likes: [Like]) -> LikeCounts {
        return likes.reduce(into: LikeCounts(likeCount: 0, dislikeCount: 0)) { partialResult, like in
            if like.status == .like {
                partialResult.likeCount += 1
            } else if like.status == .dislike {
                partialResult.dislikeCount += 1
            }
        }
    }
}
