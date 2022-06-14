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
    
    var bindHandler: (() -> ()) = {}
    
    let manager = FirebasePostManager.shared

    init() {
        FirebaseAuthManager.shared.signInAnonymously { user in
            self.listenAll()
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
}
