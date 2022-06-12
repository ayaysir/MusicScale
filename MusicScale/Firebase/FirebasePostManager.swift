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
    
    static let shared = FirebasePostManager()
    
    typealias CD_CompletionHandler = (_ documentID: String) -> ()
    typealias ErrorHandler = (_ err: Error) -> ()
    typealias ReadAllCompletionHandler = (_ posts: [Post]) -> ()
    typealias ReadOneCompletionHandler = (_ post: Post) -> ()
    typealias QuerySnapshotListener = (QuerySnapshot?, Error?) -> ()
    
    var db: Firestore!
    var rootCollection: CollectionReference!
    var collectionName: String!
    
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
    
    func addPost(postRequest request: Post, completionHandler: CD_CompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        
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
    
    func updatePost(documentID: String, originalRequest request: Post, completionHandler: CD_CompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        
        do {
            // createdTS에는 값이 들어있으므로 업데이트시 시간이 바뀌지 않는다.
            // modifiedTS를 nil로 하면 새로운 시간이 부여된다.
            var request = request
            request.serverModifiedTS = nil
            
            try rootCollection.document(documentID).setData(from: request) { err in
                if let err = err, let errorHandler = errorHandler {
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
    
    func deletePost(documentID: String, completionHandler: CD_CompletionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        
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
    
    func readAll(completionHandler: @escaping ReadAllCompletionHandler, errorHandler: ErrorHandler? = nil) {
        let query: Query = rootCollection.order(by: Post.CodingKeys.serverCreatedTS.rawValue, descending: true)
        
        let listener = querySnapshotListener(completionHandler: completionHandler, errorHandler: errorHandler)
        query.addSnapshotListener(listener)
    }
    
    func listenAll(completionHandler: @escaping ReadAllCompletionHandler, errorHandler: ErrorHandler? = nil) {
        let query: Query = rootCollection.order(by: Post.CodingKeys.serverCreatedTS.rawValue, descending: true)
        
        let listener = querySnapshotListener(completionHandler: completionHandler, errorHandler: errorHandler)
        query.addSnapshotListener(listener)
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
    
    
    
    
}
