//
//  Practice_Firebase.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/12.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Person: Codable {
    
    // @DocumentID가 붙은 경우 Read시 해당 문서의 ID를 자동으로 할당
    @DocumentID var documentID: String?
    
    // @ServerTimestamp가 붙은 경우 Create, Update시 서버 시간을 자동으로 입력함 (FirebaseFirestoreSwift 디펜던시 필요)
    @ServerTimestamp var serverTS: Timestamp?
    
    var name, job: String
    var devices: [String]
    var authorUID: String = ""
    
    // 왼쪽: Swift 내에서 사용하는 변수이름 / 오른쪽: Firebase에서 사용하는 변수이름
    enum CodingKeys: String, CodingKey {
        case documentID = "document_id"
        case serverTS = "server_ts"
        case authorUID = "author_uid"
        
        case name, job, devices
    }
}

class FirebasePractice {
    
    static let shared = FirebasePractice()
    
    var db: Firestore!
    var personsRef: CollectionReference!
    
    init() {
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        
        // [END setup]
        db = Firestore.firestore()
        
        personsRef = db.collection("persons")
    }
    
    /// 로그인 되어있는 경우 User 반환
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    /// 익명 로그인
    func signInAnonymously(completionHandler: @escaping (_ user: User) -> ()) {
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else { return }
            completionHandler(user)
        }
    }
    
    func addPost(personRequest request: Person) {
        
        var ref: DocumentReference? = nil
        
        do {
            ref = personsRef.document()
            
            guard let ref = ref else {
                print("Reference is not exist.")
                return
            }
            
            // 사용자 uid 추가
            guard let currentUser = currentUser else {
                return
            }
            
            var request = request
            request.authorUID = currentUser.uid
            
            try ref.setData(from: request) { err in
                if let err = err {
                    print("Firestore>> Error adding document: \(err)")
                    return
                }
                
                print("Firestore>> Document added with ID: \(ref.documentID)")
            }
        } catch  {
            print("Firestore>> Error from addPost-setData: ", error)
        }
    }
    
    func updatePost(documentID: String, originalPersonRequest request: Person) {
        
        do {
            // serverTS에는 값이 들어있으므로 업데이트시 시간이 바뀌지 않는다.
            // serverTS를 nil로 하면 새로운 시간이 부여된다.
            var request = request
            request.serverTS = nil
            
            try personsRef.document(documentID).setData(from: request) { err in
                if let err = err {
                    print("Firestore>> Error updating document: \(err)")
                    return
                }
                
                print("Firestore>> Document updating with ID: \(documentID)")
            }
        } catch {
            print("Firestore>> Error from updatePost-setData: ", error)
        }
    }
    
    func deletePost(documentID: String) {
        
        personsRef.document(documentID).delete() { err in
            if let err = err {
                print("Firestore>> Error deleting document: \(err)")
                return
            }
            
            print("Firestore>> Document deleted with ID: \(documentID)")
        }
    }
    
    func readAll() {
        // 서버 업로드 시간 기준으로 내림차순
        let query: Query = personsRef.order(by: Person.CodingKeys.serverTS.rawValue, descending: true)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Firestore>> read failed", error)
                return
            }
            
            guard let snapshot = snapshot else {
                print("Firestore>> QuerySnapshot is nil")
                return
            }
            
            snapshot.documents.compactMap { documentSnapshot in
                try? documentSnapshot.data(as: Person.self)
            }.forEach {
                // local 저장된 상태에 원격 서버로 업로드되지 않은 경우 timestamp가 nil이 되는 경우가 있음
                print("Firestore>>", #function, $0.documentID!, $0.name, $0.serverTS ?? "-")
            }
        }
    }
    
    func read(documentID: String, completionHandler: ((_ person: Person) -> ())?) {
        personsRef.document(documentID).getDocument { document, err in
            guard let document = document else {
                print("Firestore>> document is nil")
                return
            }
            
            if let person = try? document.data(as: Person.self) {
                print("Firestore>>", #function, person.documentID!, person)
                completionHandler?(person)
            }
        }
    }
}
