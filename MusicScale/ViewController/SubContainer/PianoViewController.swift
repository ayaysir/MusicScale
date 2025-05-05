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
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    generator.startEngine()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    generator.pauseEngine()
  }
  
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
      
      // 20250506: 순서 바꿈 (.ended 처리부에 keyInfo가 nil이 아닐 경우에도 prevTouchedKey를 우선적으로 활용하지 않음:)
      if let prevTouchedKey {
        print("Gesture: .ended using prevTouchedKey")
        stopKeyPress(prevTouchedKey)
      } else if let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: location) {
        print("Gesture: .ended fallback keyInfo")
        stopKeyPress(keyInfo)
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
    
    // 20250506 추가: keyInfo를 미리 prevTouchedKey에 배정하고
    // .stricted 모드에서 터치 슬라이드를 할 때 끊기는 것 방지
    prevTouchedKey = keyInfo
    
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
    // keyInfo가 현재 누른 키 목록에 있는지 검사
    // 없으면 prevTouchKey에 keyInfo 할당 후 리턴, 있다면 다음 단계
    guard !viewPiano.viewModel.currentTouchedKeys.contains(keyInfo) else {
      return
    }
    
    if let prevTouchedKey {
      stopKeyPress(prevTouchedKey)
      // 20250505 추가: 움직이면 prevKey를 멈추고 끝내는게 아닌 움직인 위치에 있는 키 연주
      startKeyPress(keyInfo)
    }
  }
  
  func stopKeyPress(_ keyInfo: PianoKeyInfo) {
    if viewPiano.viewModel.currentTouchedKeys.contains(keyInfo) {
      viewPiano.viewModel.removeCurrentTouchedKeysWithRefreshView(keyInfo)
      let semitoneStart = 60 + PianoKeyHelper.adjustKeySemitone(key: currentPlayableKey)
      let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
      generator.stopSimply(noteNumber: targetNoteNumber)
      
      prevTouchedKey = nil
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

extension PianoViewController {
  // MARK: - Detect Hardware Keyboard Press
  
  func canBecomeFirstResponder() -> Bool {
    return true
  }
  
  @discardableResult
  func startKeyPressByHWKeyboard(keyValueIgnoringModifiers keyValue: String) -> Bool {
    // 흰색 피아노 키: "zcvbnm,"으로 고정됨
    if "zxcvbnm,".contains(keyValue),
       let firstIndex = "zxcvbnm,".map(String.init).firstIndex(of: keyValue) {
      startKeyPress(viewPiano.viewModel.pianoWhiteKeys[firstIndex + 1])
      return true
    }
    
    // 검은색 피아노 키:
    if currentPlayableKey.keyInputToBlackKeyMapper.contains(keyValue),
       let firstIndex = currentPlayableKey.keyInputToBlackKeyMapper.map(String.init).firstIndex(of: keyValue) {
      startKeyPress(viewPiano.viewModel.pianoBlackKeys[firstIndex])
      return true
    }
    
    return false
  }
  
  @discardableResult
  func endKeyPressByHWKeyboard(keyValueIgnoringModifiers keyValue: String) -> Bool {
    if "zxcvbnm,".contains(keyValue),
       let firstIndex = "zxcvbnm,".map(String.init).firstIndex(of: keyValue) {
      stopKeyPress(viewPiano.viewModel.pianoWhiteKeys[firstIndex + 1])
      return true
    }
    
    if currentPlayableKey.keyInputToBlackKeyMapper.contains(keyValue),
       let firstIndex = currentPlayableKey.keyInputToBlackKeyMapper.map(String.init).firstIndex(of: keyValue) {
      stopKeyPress(viewPiano.viewModel.pianoBlackKeys[firstIndex])
      return true
    }
    
    return false
  }
}
