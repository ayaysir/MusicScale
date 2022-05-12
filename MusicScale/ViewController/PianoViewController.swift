//
//  PianoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/11.
//

import UIKit

class PianoViewController: UIViewController {
    
    @IBOutlet weak var viewPiano: PianoView!
    @IBOutlet weak var lblCurrentKeyPosition: UILabel!
    @IBOutlet weak var lblCurrentPianoViewScale: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let pianoLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePianoLongPress(gesture:)))
        pianoLongPressRecognizer.minimumPressDuration = 0
        viewPiano.addGestureRecognizer(pianoLongPressRecognizer)
        
        // Piano
        print(#function)
        let sampleBlackKeyNotes = [
            Note(scale7: .C, pitchShift: .sharp),
            Note(scale7: .D, pitchShift: .sharp),
            Note(scale7: .F, pitchShift: .sharp),
            Note(scale7: .G, pitchShift: .sharp),
            Note(scale7: .A, pitchShift: .sharp),
            Note(scale7: .C, pitchShift: .sharp),
        ]
        
//        for index in 0...sampleBlackKeyNotes.count - 1 {
//            viewPiano.touchBlackKeyArea[index].note = sampleBlackKeyNotes[index]
//        }
    }
    
    @objc func handlePianoLongPress(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .possible:
            print("possible")
        case .began:
            let location = gesture.location(in: gesture.view)
            print("touchLocation:", location)
            
            if let targetBlackKey = viewPiano.touchBlackKeyArea.first(where: { $0.touchArea.contains(location) }) {
                print(targetBlackKey)
                viewPiano.currentTouchedKey = targetBlackKey
                return
            }
            
            if let targetWhiteKey = viewPiano.touchWhiteKeyArea.first(where: { $0.touchArea.contains(location) }) {
                print(targetWhiteKey)
                viewPiano.currentTouchedKey = targetWhiteKey
                return
            }
            
        case .changed:
            print("changed")
        case .ended:
            print("ended")
            viewPiano.currentTouchedKey = nil
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        @unknown default:
            print("default")
        }
    }
    
    @IBAction func sldActViewScale(_ sender: UISlider) {
        viewPiano.transform = .identity.scaledBy(x: CGFloat(sender.value), y: CGFloat(sender.value))
        lblCurrentPianoViewScale.text = "\(sender.value)"
    }
    
    @IBAction func stepAdjustKeyPosition(_ sender: UIStepper) {
        viewPiano.adjustKeyPosition = Int(sender.value)
        lblCurrentKeyPosition.text = "\(Int(sender.value))"
    }
    
}

