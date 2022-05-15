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
    @IBOutlet weak var pkvSelectKey: UIPickerView!
    
//    var midiManager = MIDIManager()
    private(set) var midiManagerLoaded = false {
        didSet {
            print("midiManagerLoaded")
        }
    }
    lazy var midiManager: MIDIManager = {
        midiManagerLoaded = true
        return MIDIManager()
    }()
    var currentPlayableKey: Music.PlayableKey = .C
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let pianoLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePianoLongPress(gesture:)))
        pianoLongPressRecognizer.minimumPressDuration = 0
        viewPiano.addGestureRecognizer(pianoLongPressRecognizer)
        
        pkvSelectKey.delegate = self
        pkvSelectKey.dataSource = self

    }
    
    @objc func handlePianoLongPress(gesture: UILongPressGestureRecognizer) {
        
        let semitoneStart = 60 + PianoKeyHelper.adjustKeySemitone(key: currentPlayableKey)
        let viewModel = viewPiano.pianoViewModel
        
        let location = gesture.location(in: gesture.view)
        
        switch gesture.state {
        case .possible:
            print("possible")
        case .began:
            print("touchLocation:", location)
            
            if let keyInfo = viewModel?.getKeyInfoBy(touchLocation: location) {
                viewModel?.currentTouchedKey = keyInfo
                print("keyInfo:", keyInfo)
                midiManager.playNote(semitone: semitoneStart + keyInfo.keyIndex)
            }
            
        case .changed:
            print("changed")
        case .ended:
            print("ended")
            viewModel?.currentTouchedKey = nil
            midiManager.stopNote()
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
        viewPiano.pianoViewModel.adjustKeyPosition = Int(sender.value)
        lblCurrentKeyPosition.text = "\(Int(sender.value))"
    }
    
}

extension PianoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Music.PlayableKey.caseCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Music.PlayableKey(rawValue: row)?.textValueMixed
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let key = Music.PlayableKey(rawValue: row)!
        currentPlayableKey = key
        viewPiano.pianoViewModel.changeKey(key: key)
    }
}

