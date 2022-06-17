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
        
        if let parentContainerView = parentContainerView {
            
            var newSize = parentContainerView.frame.size
            // newSize.height = newSize.height - parentContainerView.frame.minY
            viewPiano = PianoView(frame: CGRect(origin: .zero, size: newSize))
            print("#1: parentContainerView.frame.size", parentContainerView.frame, parentContainerView.bounds, viewPiano.bounds.origin, viewPiano.boxOutline)
            self.view.addSubview(viewPiano)
            print("#1-1:", viewPiano.frame.origin)
            
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
                let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
                generator.playSound(noteNumber: targetNoteNumber)
                
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
            if viewModel?.currentTouchedKey != nil {
                viewModel?.currentTouchedKey = nil
                generator.stopSound()
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

