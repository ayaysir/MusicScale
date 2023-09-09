//
//  PostListViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/12.
//

import Foundation

class PostListViewModel {
    
    private var totalPosts: [Post] = []
    private(set) var filteredPosts: [Post] = [] {
        didSet {
            self.bindHandler()
        }
    }
    var filteredCount: Int { filteredPosts.count }
    
    private(set) var likeInfo: [String: LikeCounts] = [:] {
        didSet {
            self.likeCountsBindHandler()
        }
    }
    
    private var lastSearchText: String?
    private var lastSearchCategory: SearchCategory = .all
    var isDescending: Bool = true {
        didSet {
            listenAll()
            changeOrderHandler()
        }
    }
    
    typealias Handler = (() -> ())
    var bindHandler: Handler = {}
    var likeCountsBindHandler: Handler = {}
    var changeOrderHandler: Handler = {}
    
    let manager = FirebasePostManager.shared

    init() {
        FirebaseAuthManager.shared.signInAnonymously { user in
            self.listenAll()
            self.listenLikeAll()
        }
    }
    
    func readAll() {
        manager.readAll(isDescending: isDescending) { posts in
            self.getPostsApplyFiltering(fetchedPosts: posts)
        }
    }
    
    func listenAll() {
        manager.listenAll(isDescending: isDescending) { posts in
            self.getPostsApplyFiltering(fetchedPosts: posts)
        }
    }
    
    /// 검색 조건이 있다면 그 검색 조건으로 필터링하고, 없다면 전체 내려받음
    private func getPostsApplyFiltering(fetchedPosts: [Post]) {
        self.totalPosts = fetchedPosts
        filter(searchText: lastSearchText, searchCategory: lastSearchCategory)
    }
    
    func postViewModel(at index: Int) -> PostViewModel {
        return PostViewModel(post: filteredPosts[index])
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
    
    // 검색
    func filter(searchText: String?, searchCategory: SearchCategory) {
        
        lastSearchText = searchText
        lastSearchCategory = searchCategory
        
        guard let searchText = searchText?.lowercased(), searchText != "" else {
            filteredPosts = totalPosts
            return
        }
        
        self.filteredPosts = totalPosts.filter { post in
            var results: [Bool] = []
            let alwaysAll = searchCategory == .all
        
            if alwaysAll || searchCategory == .name {
                results.append(post.scaleInfo.name.lowercased().contains(searchText))
            }
        
            if alwaysAll || searchCategory == .comment {
                results.append(post.scaleInfo.comment.lowercased().contains(searchText))
            }
        
            if alwaysAll || searchCategory == .degrees {
                let replacedSearchText = replaceAltText(searchText: searchText)
                results.append(post.scaleInfo.degreesAscending.contains(replacedSearchText))
                results.append(post.scaleInfo.degreesDescending.contains(replacedSearchText))
            }
        
            return results.reduce(false) { $0 || $1 }
        }
    }
}
