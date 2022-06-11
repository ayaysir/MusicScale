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
    
    let POST_DIR = "scale_posts"
    
    typealias CD_CompletionHandler = (_ documentID: String) -> ()
    typealias CD_CreateErrorHandler = (_ err: Error) -> ()
    
    var db: Firestore!
    
    init() {
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
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
    
    func addPost(postRequest request: PostCreateRequest, completionHandler: CD_CompletionHandler? = nil, errorHandler: CD_CreateErrorHandler? = nil) {
        
        var ref: DocumentReference? = nil
        
        do {
            ref = db.collection(POST_DIR).document()
            
            guard let ref = ref else {
                print("Reference is not exist.")
                return
            }
            
            guard let currentUser = currentUser else {
                print("User is not exist(or not signed in.)")
                return
            }

            var request = request
            request.documentID = ref.documentID
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
            print("Error from setData: ", error)
        }
    }
    
    func deletePost(documentID: String, completionHandler: CD_CompletionHandler? = nil, errorHandler: CD_CreateErrorHandler? = nil) {
        
        db.collection(POST_DIR).document(documentID).delete() { err in
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
}
