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

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    let POSTS_DIR = "scale_posts"
    
    typealias CD_CompletionHandler = (_ documentID: String) -> ()
    typealias CD_CreateErrorHandler = (_ err: Error) -> ()
    
    var db: Firestore!
    var postsDB: CollectionReference!
    
    init() {
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        
        // [END setup]
        db = Firestore.firestore()
        
        postsDB = db.collection(POSTS_DIR)
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
    
    func addPost(postRequest request: Post, completionHandler: CD_CompletionHandler? = nil, errorHandler: CD_CreateErrorHandler? = nil) {
        
        var ref: DocumentReference? = nil
        
        do {
            ref = postsDB.document()
            
            guard let ref = ref else {
                print("Reference is not exist.")
                return
            }
            
            guard let currentUser = currentUser else {
                print("User is not exist(or not signed in.)")
                return
            }

            var request = request
            request.authorUID = currentUser.uid
            
            try ref.setData(from: request) { err in
                if let err = err, let errorHandler = errorHandler {
                    errorHandler(err)
                    return
                } else if let err = err {
                    print("Error adding document: \(err)")
                    return
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(ref.documentID)
                    return
                }
                
                print("Document added with ID: \(ref.documentID)")
            }
        } catch  {
            print("Error from addPost-setData: ", error)
        }
    }
    
    func updatePost(documentID: String, originalRequest request: Post, completionHandler: CD_CompletionHandler? = nil, errorHandler: CD_CreateErrorHandler? = nil) {
        
        do {
            // createdTS에는 값이 들어있으므로 업데이트시 시간이 바뀌지 않는다.
            // modifiedTS를 nil로 하면 새로운 시간이 부여된다.
            var request = request
            request.serverModifiedTS = nil
            
            try postsDB.document(documentID).setData(from: request) { err in
                if let err = err, let errorHandler = errorHandler {
                    errorHandler(err)
                    return
                } else if let err = err {
                    print("Error updating document: \(err)")
                    return
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(documentID)
                    return
                }
                
                print("Document updating with ID: \(documentID)")
            }
        } catch {
            print("Error from updatePost-setData: ", error)
        }
        
    }
    
    func deletePost(documentID: String, completionHandler: CD_CompletionHandler? = nil, errorHandler: CD_CreateErrorHandler? = nil) {
        
        postsDB.document(documentID).delete() { err in
            if let err = err, let errorHandler = errorHandler {
                errorHandler(err)
                return
            } else if let err = err {
                print("Error deleting document: \(err)")
                return
            }
            
            if let completionHandler = completionHandler {
                completionHandler(documentID)
                return
            }
            
            print("Document deleted with ID: \(documentID)")
        }
    }
    
    func readAll() {
        let query: Query = db.collection(POSTS_DIR).order(by: Post.CodingKeys.serverCreatedTS.rawValue, descending: true)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("read failed", error)
                return
            }
            
            guard let snapshot = snapshot else {
                return
            }

            print("querySnapshot: \(snapshot)")
            snapshot.documents.map({ documentSnapshot in
                try! documentSnapshot.data(as: Post.self)
            }).forEach {
                print(#function, $0.serverCreatedTS ?? "\($0)", $0.scaleInfo.name)
            }
        }
    }
    
    func read(documentID: String) {
        postsDB.document(documentID).getDocument { document, err in
            guard let document = document else {
                print("document is nil")
                return
            }
            
            print(#function, document.documentID, try? document.data(as: Post.self))
        }
    }
}
