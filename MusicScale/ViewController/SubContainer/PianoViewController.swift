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
    func didMIDIReceived(_ controller: PianoViewController, noteNumber: Int)
}

class PianoViewController: UIViewController {
    enum Mode {
        case stricted, quiz
    }
    
    var viewPiano: PianoView!
    var mode: Mode = .stricted
    var isKeyPressEnabled: Bool = true
    
    private var generator: MIDISoundGenerator = GlobalGenerator.shared
    
    var currentPlayableKey: Music.PlayableKey = .C
    var octaveShift: Int = 0
    
    var parentContainerView: UIView?
    weak var delegate: PianoVCDelegate?
    
    private var prevTouchedKey: PianoKeyInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPiano()
        view.backgroundColor = .systemBackground
        
        if mode == .quiz {
            GlobalMIDIListener.shared.noteOnHandler = { noteNumber in
                self.delegate?.didMIDIReceived(self, noteNumber: noteNumber)
            }
        } else {
            GlobalMIDIListener.shared.noteOnHandler = nil
        }
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
            
            // let pianoTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePianoTap))
            // viewPiano.addGestureRecognizer(pianoTapRecognizer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        generator.startEngine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        generator.pauseEngine()
    }
    
    // @objc func handlePianoTap(gesture: UITapGestureRecognizer) {
    //     guard isKeyPressEnabled else { return }
    //     let location = gesture.location(in: gesture.view)
    //     if let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: location) {
    //         startKeyPress(keyInfo, isLongPress: false)
    //     }
    // }
    
    @objc func handlePianoLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        
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
            if let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: location) {
                changeKeyPress(keyInfo)
            }
        case .ended:
            // 노트 멈춤
            guard isKeyPressEnabled else { return }
            if let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: location) {
                stopKeyPress(keyInfo)
            } else if let prevTouchedKey {
                stopKeyPress(prevTouchedKey)
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
    
    // MARK: - Start or stop key press
    
    func startKeyPress(_ keyInfo: PianoKeyInfo, isLongPress: Bool = true) {
        let semitoneStart = 60 + PianoKeyHelper.adjustKeySemitone(key: currentPlayableKey)
        
        if mode == .stricted {
            guard viewPiano.viewModel.availableKeyIndexes.contains(keyInfo.keyIndex) else {
                return
            }
        }
        
        // viewPiano.viewModel.currentTouchedKey = keyInfo
        viewPiano.viewModel.insertCurrentTouchedKeysWithRefreshView(keyInfo)
        
        // 노트 재생
        let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
        generator.playSound(noteNumber: targetNoteNumber)
        
        // delegate 있는 경우 키 누름 정보 전송
        if let delegate = delegate {
            delegate.didKeyPressed(self, keyInfo: keyInfo)
        }
    }
    
    func changeKeyPress(_ keyInfo: PianoKeyInfo) {
        guard !viewPiano.viewModel.currentTouchedKeys.contains(keyInfo) else {
            prevTouchedKey = keyInfo
            return
        }
        
        if let prevTouchedKey {
            stopKeyPress(prevTouchedKey)
        }
    }
    
    // func stopKeyPress() {
    //     if viewPiano.viewModel?.currentTouchedKey != nil {
    //         viewPiano.viewModel?.currentTouchedKey = nil
    //         generator.stopSound()
    //     }
    // }
    
    func stopKeyPress(_ keyInfo: PianoKeyInfo) {
        if viewPiano.viewModel.currentTouchedKeys.contains(keyInfo) {
            viewPiano.viewModel.removeCurrentTouchedKeysWithRefreshView(keyInfo)
            let semitoneStart = 60 + PianoKeyHelper.adjustKeySemitone(key: currentPlayableKey)
            let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
            generator.stopSimply(noteNumber: targetNoteNumber)
        }
        
        prevTouchedKey = nil
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

extension PianoViewController {
    // MARK: - Detect Hardware Keyboard Press
    
    func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    var characterSet: CharacterSet {
        var characterSet = CharacterSet(charactersIn: "./;'")
        characterSet.formUnion(.alphanumerics)
        return characterSet
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var didHandleEvent = false
        
        for press in presses {
            // Get the pressed key.
            guard let key = press.key else { continue }
            
            let keyValue = key.charactersIgnoringModifiers
            
            // 흰색 피아노 키: "zcvbnm,"으로 고정됨
            if "zxcvbnm,".contains(keyValue),
               let firstIndex = "zxcvbnm,".map(String.init).firstIndex(of: keyValue) {
                startKeyPress(viewPiano.viewModel.pianoWhiteKeys[firstIndex + 1])
                didHandleEvent = true
            }
            // 검은색 피아노 키:
            else if currentPlayableKey.keyInputToBlackKeyMapper.contains(keyValue),
               let firstIndex = currentPlayableKey.keyInputToBlackKeyMapper.map(String.init).firstIndex(of: keyValue) {
                startKeyPress(viewPiano.viewModel.pianoBlackKeys[firstIndex])
                didHandleEvent = true
            }
            else if let scalar = keyValue.unicodeScalars.first, characterSet.contains(scalar) {
                didHandleEvent = true
            }
        }
        
        if !didHandleEvent {
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var didHandleEvent = false
        
        for press in presses {
            // Get the released key.
            guard let key = press.key else { continue }
            
            let keyValue = key.charactersIgnoringModifiers
            
            if "zxcvbnm,".contains(key.charactersIgnoringModifiers),
               let firstIndex = "zxcvbnm,".map(String.init).firstIndex(of: key.charactersIgnoringModifiers) {
                stopKeyPress(viewPiano.viewModel.pianoWhiteKeys[firstIndex + 1])
                didHandleEvent = true
            }
            else if currentPlayableKey.keyInputToBlackKeyMapper.contains(keyValue),
               let firstIndex = currentPlayableKey.keyInputToBlackKeyMapper.map(String.init).firstIndex(of: keyValue) {
                stopKeyPress(viewPiano.viewModel.pianoBlackKeys[firstIndex])
                didHandleEvent = true
            }
            else if let scalar = keyValue.unicodeScalars.first, characterSet.contains(scalar) {
                didHandleEvent = true
            }
        }
        
        if !didHandleEvent {
            super.pressesEnded(presses, with: event)
        }
    }
}
