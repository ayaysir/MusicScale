//
//  FirebaseManager.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

enum FirebaseManagerError: String, Error {
    case documentSnapshotIsNil
    case collectionSnapshotIsNil
    case refNotExist
    case userNotExist
    case codingFailed
}

class FirebasePostManager {
    
    let POSTS_DIR = "scale_posts"
    let LIKE_DIR = "likes"
    let VIEW_DIR = "views"
    let DOWNLOAD_DIR = "downloads"
    
    static let shared = FirebasePostManager()
    
    typealias CompletionHandler = (_ documentID: String) -> ()
    typealias ErrorHandler = (_ err: Error) -> ()
    typealias ReadAllCompletionHandler = (_ posts: [Post]) -> ()
    typealias ReadOneCompletionHandler = (_ post: Post) -> ()
    typealias QuerySnapshotListener = (QuerySnapshot?, Error?) -> ()
    typealias LikeCompletionHandler = (_ like: Like?) -> ()
    typealias LikeCountsCompletion = (_ likeCounts: LikeCounts, _ recentChanges: Like?) -> ()
    typealias LikeAllCompletion = (_ likeInfo: [String: LikeCounts]) -> ()
    typealias CountCompletionHandler = (_ count: Int) -> ()
    
    var db: Firestore!
    var rootCollection: CollectionReference!
    var collectionName: String!
    
    private var collectionListener: ListenerRegistration?
    private var likeCountsListener: ListenerRegistration?
    
    
    init() {
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        rootCollection = db.collection(POSTS_DIR)
        self.collectionName = POSTS_DIR
    }
    
    private func manageError(error err: Error?, altText: String, errorHandler: ErrorHandler?) {
        if let err = err, let errorHandler = errorHandler {
            errorHandler(err)
        } else if let err = err {
            print("Firestore(\(collectionName!)):", altText, err.localizedDescription)
        }
    }
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    func signInAnonymously(completionHandler: @escaping (_ user: User) -> ()) {
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else { return }
            completionHandler(user)
        }
    }
    
    func addPost(postRequest request: Post, completionHandler: CompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        
        var ref: DocumentReference? = nil
        
        do {
            ref = rootCollection.document()
            
            guard let ref = ref else {
                manageError(error: FirebaseManagerError.refNotExist, altText: "", errorHandler: errorHandler)
                return
            }
            
            guard let currentUser = currentUser else {
                manageError(error: FirebaseManagerError.userNotExist, altText: "", errorHandler: errorHandler)
                return
            }

            var request = request
            request.authorUID = currentUser.uid
            
            try ref.setData(from: request) { err in
                if let err = err {
                    self.manageError(error: err, altText: "Error adding document:", errorHandler: errorHandler)
                    return
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(ref.documentID)
                    return
                }
                
                print("Document added with ID: \(ref.documentID)")
            }
        } catch  {
            manageError(error: FirebaseManagerError.codingFailed, altText: "Error from addPost-setData:", errorHandler: errorHandler)
        }
    }
    
    func updatePost(documentID: String, originalRequest request: Post, completionHandler: CompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        
        do {
            // createdTS에는 값이 들어있으므로 업데이트시 시간이 바뀌지 않는다.
            // modifiedTS를 nil로 하면 새로운 시간이 부여된다.
            var request = request
            request.serverModifiedTS = nil
            
            try rootCollection.document(documentID).setData(from: request) { err in
                if let err = err {
                    self.manageError(error: err, altText: "Error updating document:", errorHandler: errorHandler)
                    return
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(documentID)
                    return
                }
                
                print("Document updating with ID: \(documentID)")
            }
        } catch {
            manageError(error: FirebaseManagerError.codingFailed, altText: "Error from updatePost-setData:", errorHandler: errorHandler)
        }
    }
    
    func deletePost(documentID: String, completionHandler: CompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        
        rootCollection.document(documentID).delete() { err in
            if let err = err {
                self.manageError(error: err, altText: "Error deleting document:", errorHandler: errorHandler)
            }
            
            if let completionHandler = completionHandler {
                completionHandler(documentID)
                return
            }
            
            print("Document deleted with ID: \(documentID)")
        }
    }
    
    func readAll(isDescending: Bool, completionHandler: @escaping ReadAllCompletionHandler, errorHandler: ErrorHandler? = nil) {
        let query: Query = rootCollection.order(by: Post.CodingKeys.serverCreatedTS.rawValue, descending: isDescending)
        listenAllUseQuery(query, completionHandler: completionHandler, errorHandler: errorHandler)
    }
    
    func listenAll(isDescending: Bool, completionHandler: @escaping ReadAllCompletionHandler, errorHandler: ErrorHandler? = nil) {
        let query: Query = rootCollection
            .order(by: Post.CodingKeys.serverCreatedTS.rawValue, descending: isDescending)
            // .whereField("scale_info.name", isEqualTo: "509A87A1-7916-4EE3-B2E4-140A1DBE5B60")
        
            // prefix only
            // .whereField("scale_info.name", isGreaterThanOrEqualTo: "509A87A1").whereField("scale_info.name", isLessThanOrEqualTo: "509A87A1\u{F7FF}")
            // .whereField("scale_info.name", isGreaterThanOrEqualTo: "mode").whereField("scale_info.name", isLessThanOrEqualTo: "mode\u{f8ff}")
        
        listenAllUseQuery(query, completionHandler: completionHandler, errorHandler: errorHandler)
    }
    
    func listenAllUseQuery(_ query: Query, completionHandler: @escaping ReadAllCompletionHandler, errorHandler: ErrorHandler? = nil) {
        if collectionListener != nil {
            collectionListener?.remove()
            collectionListener = nil
        }
        let listener = querySnapshotListener(completionHandler: completionHandler, errorHandler: errorHandler)
        collectionListener = query.addSnapshotListener(listener)
    }
    
    private func querySnapshotListener(completionHandler: @escaping ReadAllCompletionHandler, errorHandler: ErrorHandler?) -> QuerySnapshotListener {
        
        return { snapshot, err in
            guard let collection = snapshot else {
                self.manageError(error: FirebaseManagerError.collectionSnapshotIsNil, altText: "QuerySnapshotListener failed:", errorHandler: errorHandler)
                return
            }
            
            let posts = collection.documents.compactMap { documentSnapshot in
                try? documentSnapshot.data(as: Post.self)
            }
            
            completionHandler(posts)
        }
    }
    
    func read(documentID: String, completionHandler: @escaping ReadOneCompletionHandler, errorHandler: ErrorHandler? = nil) {
        rootCollection.document(documentID).getDocument { document, err in
            if let err = err {
                self.manageError(error: err, altText: "Read one failed:", errorHandler: errorHandler)
            }
            
            guard let document = document else {
                self.manageError(error: FirebaseManagerError.documentSnapshotIsNil, altText: "Read one failed:", errorHandler: errorHandler)
                return
            }
            
            if let post = try? document.data(as: Post.self) {
                completionHandler(post)
            }
        }
    }
    
    func listenOne(documentID: String) {
        rootCollection.document(documentID)
        .addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Current data: \(data)")
        }
    }
    
    // MARK: - Like Dislike
    
    func updateLike(documentID: String, status: LikeStatus, completionHandler: CompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        guard let currentUser = currentUser else {
            manageError(error: FirebaseManagerError.userNotExist, altText: "", errorHandler: errorHandler)
            return
        }
        
        let likesRef = rootCollection.document(documentID).collection(LIKE_DIR)
        let like = Like(status: status, authorUID: currentUser.uid, postDocumentID: documentID)
        do {
            try likesRef.document(currentUser.uid).setData(from: like) { err in
                if let err = err {
                    self.manageError(error: err, altText: "Error from like post:", errorHandler: errorHandler)
                    return
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(documentID)
                    return
                }
                
                print(#function, "\(status) to postDocument ID: \(documentID)")
            }
        } catch {
            manageError(error: error, altText: "", errorHandler: errorHandler)
        }
    }
    
    func readLike(documentID: String, completionHandler: LikeCompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        guard let currentUser = currentUser else {
            manageError(error: FirebaseManagerError.userNotExist, altText: "", errorHandler: errorHandler)
            return
        }
        
        let likesRef = rootCollection.document(documentID).collection(LIKE_DIR)
        likesRef.document(currentUser.uid).getDocument { documentSnapshot, err in
            guard let document = documentSnapshot else {
                self.manageError(error: err, altText: "Error fetching document: \(err!)", errorHandler: errorHandler)
                return
            }
            guard let like = try? document.data(as: Like.self) else {
                print("\(documentID): Like was empty.")
                completionHandler?(nil)
                return
            }
            
            completionHandler?(like)
        }
    }
    
    func listenLikeAll(completionHandler: LikeAllCompletion? = nil, errorHandler: ErrorHandler? = nil) {
        db.collectionGroup("likes").addSnapshotListener { querySnapshot, err in
            guard let collection = querySnapshot else {
                self.manageError(error: FirebaseManagerError.collectionSnapshotIsNil, altText: "QuerySnapshotListener failed:", errorHandler: errorHandler)
                return
            }
            
            let likes = collection.documents.compactMap { documentSnapshot in
                try? documentSnapshot.data(as: Like.self)
            }
            
            let collectedInfo = likes.reduce(into: [String: [Like]]()) { partialResult, like in
                partialResult[like.postDocumentID, default: []].append(like)
            }.reduce(into: [String: LikeCounts]()) { partialResult, element in
                partialResult[element.key] = LikeCounts.getLikeCounts(from: element.value)
            }
            
            completionHandler?(collectedInfo)
        }
    }
    
    func listenTotalLikeCount(documentID: String, completionHandler: LikeCountsCompletion? = nil, errorHandler: ErrorHandler? = nil) {
        let ref = rootCollection.document(documentID).collection("likes")
        self.likeCountsListener = ref.addSnapshotListener { querySnapshot, err in
            guard let collection = querySnapshot else {
                self.manageError(error: err, altText: "Error fetching document: \(err!)", errorHandler: errorHandler)
                return
            }
            
            let likes = collection.documents.compactMap { documentSnapshot in
                try? documentSnapshot.data(as: Like.self)
            }
            
            completionHandler?(
                LikeCounts.getLikeCounts(from: likes),
                try? collection.documentChanges.first?.document.data(as: Like.self)
            )

        }
    }
    
    func removeLikeCountListener() {
        self.likeCountsListener?.remove()
    }
    
    // MARK: - View, Download Count
    enum PostCount {
        case view, download
    }
    
    func updatePostCount(_ category: PostCount, documentID: String, completionHandler: CompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        guard let currentUser = currentUser else {
            manageError(error: FirebaseManagerError.userNotExist, altText: "", errorHandler: errorHandler)
            return
        }
        
        let isViewCount = category == .view
        let countsRef = rootCollection.document(documentID).collection(isViewCount ? VIEW_DIR : DOWNLOAD_DIR)
        let postView = PostView(viewerUID: currentUser.uid, postDocumentID: documentID)
        do {
            try countsRef.document(currentUser.uid).setData(from: postView) { err in
                if let err = err {
                    self.manageError(error: err, altText: " Error from update \(category)Count post \(documentID):", errorHandler: errorHandler)
                    return
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(documentID)
                    return
                }
                
                print(#function, "\(category)Count to postDocument ID: \(documentID)")
            }
        } catch {
            manageError(error: error, altText: "", errorHandler: errorHandler)
        }
    }
    
    func readPostCount(_ category: PostCount, documentID: String, completionHandler: CountCompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        let ref = rootCollection.document(documentID).collection(category == .view ? VIEW_DIR : DOWNLOAD_DIR)
        ref.getDocuments { snapshot, err in
            guard let snapshot = snapshot else {
                self.manageError(error: err, altText: "Error fetching document: \(err!)", errorHandler: errorHandler)
                return
            }

            completionHandler?(snapshot.count)
        }
    }
    
}
