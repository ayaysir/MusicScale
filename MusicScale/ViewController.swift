//
//  ViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2021/12/15.
//

import UIKit

class ViewController: UIViewController {
    
    let conductor = NoteSequencerConductor()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Efe")
        conductor.start()
////        conductor.sequencer.play()
        // conductor.instrument.play(noteNumber: 65, velocity: 100, channel: 1)
    }


}

