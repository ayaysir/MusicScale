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
    
    // private var generator: MIDISoundGenerator!
    private var generator: MIDISoundGenerator = GlobalGenerator.shared
    
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
        // Decide instPreset
        // generator = MIDISoundGenerator()
        generator.startEngine()
        
        // NotificationCenter.default.addObserver(self, selector: #selector(didActivated), name: UIScene.didActivateNotification, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
        // NotificationCenter.default.removeObserver(self, name: UIScene.willDeactivateNotification, object: nil)
        // generator.stopEngine()
        generator.pauseEngine()
    }
    
    // @objc func didActivated() {
    //     generator.startEngine()
    // }
    //
    // @objc func willResignActive() {
    //     generator.pauseEngine()
    // }
    
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
            
            if let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: location) {
                startKeyPress(keyInfo)
            }
        case .changed:
            // print(".", terminator: ":")
            break
        case .ended:
            // ?????? ??????
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
        
        // ?????? ??????
        let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
        generator.playSound(noteNumber: targetNoteNumber)
        
        // delegate ?????? ?????? ??? ?????? ?????? ??????
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

