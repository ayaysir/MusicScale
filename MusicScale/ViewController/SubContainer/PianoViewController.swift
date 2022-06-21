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
    
    private var generator: MIDISoundGenerator!
    
    var currentPlayableKey: Music.PlayableKey = .C
    var octaveShift: Int = 0
    
    var parentContainerView: UIView?
    weak var delegate: PianoVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPiano()
        
        
    }
    
    func setPiano() {
        if let parentContainerView = parentContainerView {
            
            if self.view.subviews.isNotEmpty {
                self.view.subviews.forEach { subview in
                    subview.removeFromSuperview()
                }
            }
            
            let newSize = parentContainerView.frame.size
            viewPiano = PianoView(frame: CGRect(origin: .zero, size: newSize))
            self.view.addSubview(viewPiano)
            
            let pianoLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePianoLongPress(gesture:)))
            pianoLongPressRecognizer.minimumPressDuration = 0.0
            viewPiano.addGestureRecognizer(pianoLongPressRecognizer)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // try? availableSoundInSilentMode()
        
        // Decide instPreset
        generator = MIDISoundGenerator()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        generator.stopEngine()
    }
    
    @objc func handlePianoLongPress(gesture: UILongPressGestureRecognizer) {
        
        // let semitoneStart = 60 + PianoKeyHelper.adjustKeySemitone(key: currentPlayableKey)
        let location = gesture.location(in: gesture.view)
        // let viewModel = viewPiano.viewModel
        
        switch gesture.state {
        case .possible:
            // print("possible", terminator: ":")
            break
        case .began:
            guard isKeyPressEnabled else { return }
            
            // if let viewModel = viewModel, let keyInfo = viewModel.getKeyInfoBy(touchLocation: location) {
            //     if mode == .stricted {
            //         guard viewPiano.viewModel.availableKeyIndexes.contains(keyInfo.keyIndex) else {
            //             return
            //         }
            //     }
            //
            //     viewModel.currentTouchedKey = keyInfo
            //
            //     // 노트 재생
            //     let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
            //     generator.playSound(noteNumber: targetNoteNumber)
            //
            //     // delegate 있는 경우 키 누름 정보 전송
            //     if let delegate = delegate {
            //         delegate.didKeyPressed(self, keyInfo: keyInfo)
            //     }
            // }
            
            if let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: location) {
                startKeyPress(keyInfo)
            }
        case .changed:
            // print(".", terminator: ":")
            break
        case .ended:
            // 노트 멈춤
            // if viewModel?.currentTouchedKey != nil {
            //     viewModel?.currentTouchedKey = nil
            //     generator.stopSound()
            // }
            stopKeyPress()
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
    
    // MARK: - Start or stop key press
    
    func startKeyPress(_ keyInfo: PianoKeyInfo) {
        let semitoneStart = 60 + PianoKeyHelper.adjustKeySemitone(key: currentPlayableKey)
        
        if mode == .stricted {
            guard viewPiano.viewModel.availableKeyIndexes.contains(keyInfo.keyIndex) else {
                return
            }
        }
        
        viewPiano.viewModel.currentTouchedKey = keyInfo
        
        // 노트 재생
        let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
        generator.playSound(noteNumber: targetNoteNumber)
        
        // delegate 있는 경우 키 누름 정보 전송
        if let delegate = delegate {
            delegate.didKeyPressed(self, keyInfo: keyInfo)
        }
    }
    
    func stopKeyPress() {
        if viewPiano.viewModel?.currentTouchedKey != nil {
            viewPiano.viewModel?.currentTouchedKey = nil
            generator.stopSound()
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

