//
//  PianoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/11.
//

import UIKit
import AudioKit
import AVFoundation

protocol PianoVCDelegate: AnyObject {
    func didKeyPressed(_ controller: PianoViewController, keyInfo: PianoKeyInfo)
}

class PianoViewController: UIViewController {
    
    enum Mode {
        case stricted, free
    }
    
    var viewPiano: PianoView!
    var mode: Mode = .stricted
    var isKeyPressEnabled: Bool = true
    
    let engine = AudioEngine()
    private var instrument = MIDISampler(name: "Instrument 1")
    private var midiNote: MIDINoteNumber!
    
    var currentPlayableKey: Music.PlayableKey = .C
    var octaveShift: Int = 0
    
    var parentContainerView: UIView?
    weak var delegate: PianoVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentContainerView = parentContainerView {
            
            viewPiano = PianoView(frame: CGRect(origin: .zero, size: parentContainerView.frame.size))
            self.view.addSubview(viewPiano)
            
            let pianoLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePianoLongPress(gesture:)))
            pianoLongPressRecognizer.minimumPressDuration = 0.0
            viewPiano.addGestureRecognizer(pianoLongPressRecognizer)
        }
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
        let location = gesture.location(in: gesture.view)
        let viewModel = viewPiano.viewModel
        
        switch gesture.state {
        case .possible:
            // print("possible", terminator: ":")
            break
        case .began:
            guard isKeyPressEnabled else { return }
            
            if let viewModel = viewModel, let keyInfo = viewModel.getKeyInfoBy(touchLocation: location) {
                if mode == .stricted {
                    guard viewPiano.viewModel.availableKeyIndexes.contains(keyInfo.keyIndex) else {
                        return
                    }
                }
                
                viewModel.currentTouchedKey = keyInfo
                
                // 노트 재생
                midiNote = MIDINoteNumber(semitoneStart + keyInfo.keyIndex + (octaveShift * 12))
                instrument.play(noteNumber: midiNote, velocity: 90, channel: 1)
                
                // delegate 있는 경우 키 누름 정보 전송
                if let delegate = delegate {
                    delegate.didKeyPressed(self, keyInfo: keyInfo)
                }
            }
        case .changed:
            // print(".", terminator: ":")
            break
        case .ended:
            // 노트 멈춤
            if viewModel?.currentTouchedKey != nil && midiNote != nil {
                viewModel?.currentTouchedKey = nil
                instrument.stop(noteNumber: midiNote, channel: 1)
                midiNote = nil
            }
        case .cancelled:
            // print("cancelled")
            break
        case .failed:
            // print("failed")
            break
        @unknown default:
            print("default", terminator: ":")
        }
    }
}

extension PianoViewController {

    func adjustKeyPosition(key: Music.PlayableKey) {
        currentPlayableKey = key
        viewPiano.viewModel.changeKey(key: key)
    }
    
    func updateAvailableKeys(integerNotations: [Int]) {
        viewPiano.viewModel.availableKeyIndexes = integerNotations.map { $0 + PianoKeyHelper.findRootKeyPosition(playableKey: currentPlayableKey) }
        viewPiano.setNeedsDisplay()
    }
}

