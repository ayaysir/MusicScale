//
//  ViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2021/12/15.
//

import UIKit

class ViewController: UIViewController {
    
    // let conductor = NoteSequencerConductor()
    let conductor = GlobalConductor.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func btnActAddDummy(_ sender: Any) {
        let uuid = UUID()
        let scaleInfo = ScaleInfo(id: uuid, name: uuid.uuidString, nameAlias: uuid.uuidString, degreesAscending: "1 2 3 4 5 6 7", degreesDescending: "", defaultPriority: 3, comment: uuid.uuidString, links: "", isDivBy12Tet: true, displayOrder: 3, myPriority: 0, createdDate: Date(), modifiedDate: Date(), groupName: "gro1")
        let post = Post(scaleInfo: scaleInfo)
        FirebasePostManager.shared.addPost(postRequest: post, completionHandler: nil, errorHandler: nil)
    }
}

