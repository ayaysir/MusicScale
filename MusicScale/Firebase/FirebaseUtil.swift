//
//  FirebaseUtil.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/14.
//

import Firebase

struct FirebaseUtil {
    
    static func timestampToDate(_ timestamp: Timestamp) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
    }
}
