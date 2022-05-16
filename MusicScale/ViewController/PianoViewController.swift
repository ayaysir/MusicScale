//
//  PianoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/11.
//

import UIKit
import AudioKit
import AVFoundation

class PianoViewController: UIViewController {
    
    @IBOutlet weak var viewPiano: PianoView!
    @IBOutlet weak var lblCurrentKeyPosition: UILabel!
    @IBOutlet weak var lblCurrentPianoViewScale: UILabel!
    @IBOutlet weak var pkvSelectKey: UIPickerView!
    
//    var midiManager = MIDIManager()
    let engine = AudioEngine()
    private var instrument = MIDISampler(name: "Instrument 1")
    private var midiNote: MIDINoteNumber!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        initPianoSound()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print(#function)
        engine.stop()
    }
    
    private func initPianoSound() {
        
        // piano sound
        engine.output = instrument
        
        // Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
        do {
//            if let fileURL = Bundle.main.url(forResource: "sawPiano1 복사본", withExtension: "exs") {
//                try instrument.loadInstrument(url: fileURL)
//            }
            
            // 무음모드에서 소리나게 하기
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            if let fileURL = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2") {

                try instrument.loadMelodicSoundFont(url: fileURL, preset: 67)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }
    
    @objc func handlePianoLongPress(gesture: UILongPressGestureRecognizer) {
        
        let semitoneStart = 60 + PianoKeyHelper.adjustKeySemitone(key: currentPlayableKey)
        let viewModel = viewPiano.pianoViewModel
        
        let location = gesture.location(in: gesture.view)
        
        switch gesture.state {
        case .possible:
//            print("possible")
            break
        case .began:
//            print("touchLocation:", location)
            
            if let keyInfo = viewModel?.getKeyInfoBy(touchLocation: location) {
                viewModel?.currentTouchedKey = keyInfo
                print("keyInfo:", keyInfo)
                // 노트 재생
                midiNote = MIDINoteNumber(semitoneStart + keyInfo.keyIndex)
                instrument.play(noteNumber: midiNote, velocity: 90, channel: 1)
            }
            
        case .changed:
//            print("changed")
            break
        case .ended:
//            print("ended")
            viewModel?.currentTouchedKey = nil
            // 노트 멈춤
            instrument.stop(noteNumber: midiNote, channel: 1)
            midiNote = nil
        case .cancelled:
//            print("cancelled")
            break
        case .failed:
//            print("failed")
            break
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

