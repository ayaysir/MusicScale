//
//  PostListViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/12.
//

import Foundation

class PostListViewModel {
    
    private(set) var posts: [Post] = [] {
        didSet {
            self.bindHandler()
        }
    }
    private(set) var likeInfo: [String: LikeCounts] = [:] {
        didSet {
            self.likeCountsBindHandler()
        }
    }
    
    var bindHandler: (() -> ()) = {}
    var likeCountsBindHandler: (() -> ()) = {}
    
    let manager = FirebasePostManager.shared

    init() {
        FirebaseAuthManager.shared.signInAnonymously { user in
            self.listenAll()
            self.listenLikeAll()
        }
    }
    
    func readAll() {
        manager.readAll { posts in
            self.posts = posts
        }
    }
    
    func listenAll() {
        manager.listenAll { posts in
            self.posts = posts
        }
    }
    
    func post(at index: Int) -> Post {
        return posts[index]
    }
    
    func postViewModel(at index: Int) -> PostViewModel {
        return PostViewModel(post: post(at: index))
    }
    
    func listenLikeAll() {
        manager.listenLikeAll { likeInfo in
            self.likeInfo = likeInfo
        } errorHandler: { err in
            print(err)
        }
    }
    
    func likeInfo(documentID: String) -> LikeCounts? {
        return likeInfo[documentID]
    }
}
