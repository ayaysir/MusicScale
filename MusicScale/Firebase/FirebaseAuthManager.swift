//
//  FirebaseAuthManager.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/12.
//

import FirebaseAuth

struct FirebaseAuthManager {
    
    static let shared = FirebaseAuthManager()
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }

    func signInAnonymously(completionHandler: @escaping (_ user: User) -> ()) {
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else { return }
            completionHandler(user)
        }
    }
}
