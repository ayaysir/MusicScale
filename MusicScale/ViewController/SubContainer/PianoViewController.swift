//
//  PianoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/11.
//

import UIKit
import AudioKit
import AVFoundation

// MARK: - Delegates

protocol PianoVCDelegate: AnyObject {
  func didKeyPressed(_ controller: PianoViewController, keyInfo: PianoKeyInfo)
  func didMIDIReceived(_ controller: PianoViewController, noteNumber: Int)
}

// MARK: - VC Main

class PianoViewController: UIViewController {
  var viewPiano: PianoView!
  var contentMode: ContentMode = .stricted
  var keyPressMode: KeyPressMode = .singleTouchOnly {
    didSet {
      setPressMode()
    }
  }
  var isKeyPressEnabled: Bool = true
  
  private var generator: MIDISoundGenerator = GlobalGenerator.shared
  
  var currentPlayableKey: Music.PlayableKey = .C
  var octaveShift: Int = 0
  
  var parentContainerView: UIView?
  weak var delegate: PianoVCDelegate?
  
  /// 이전 터치 키 - single touch slide 모드에서 필요
  private var prevTouchedKey: PianoKeyInfo?
  
  /// 터치 시작지점 모음 - single touch only/multi touch 모드에서 필요
  private var touchStartInfos: [UITouch : TouchInfo] = [:]
  
  /// 롱프레스 제스처 전역변수 - 제스처 등록/삭제에 필요
  private var pianoLongPressGesture: UILongPressGestureRecognizer?
  
  /// single touch only/multi touch에서 최소 지속시간
  /// - 너무 짧게 누르면 소리가 나오기도 전에 stopSound()가 실행됨
  private let MIN_HOLD_TIME = 0.1
  
  private let GESTURE_DEBUG = false
  
  // MARK: - Lifecycles
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setPiano()
    view.backgroundColor = .systemBackground
    
    if contentMode == .quiz {
      GlobalMIDIListener.shared.noteOnHandler = { noteNumber in
        self.delegate?.didMIDIReceived(self, noteNumber: noteNumber)
      }
    } else {
      GlobalMIDIListener.shared.noteOnHandler = nil
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    generator.startEngine()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    generator.pauseEngine()
  }
  
  // MARK: - OBJC Functions
  
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
        GESTURE_DEBUG ? print("Gesture: .ended using prevTouchedKey") : nil
        stopKeyPress(prevTouchedKey)
      } else if let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: location) {
        GESTURE_DEBUG ? print("Gesture: .ended fallback keyInfo") : nil
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
  
  // MARK: - Init/Change states
  
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
      
      // 제스처 1: 하나만 누르기 (터치 + 슬라이드)
      pianoLongPressGesture = UILongPressGestureRecognizer(
        target: self,
        action: #selector(
          handlePianoLongPress(gesture:)
        )
      )
      pianoLongPressGesture?.minimumPressDuration = 0.0
      
      setPressMode()
    }
  }
  
  private func setPressMode() {
    // quiz인 경우 singleTouchOnly만
    if contentMode == .quiz {
      viewPiano.isMultipleTouchEnabled = false
      if let pianoLongPressGesture {
        viewPiano.removeGestureRecognizer(pianoLongPressGesture)
      }
      
      return
    }
    
    switch keyPressMode {
    case .singleTouchOnly:
      viewPiano.isMultipleTouchEnabled = false
      if let pianoLongPressGesture {
        viewPiano.removeGestureRecognizer(pianoLongPressGesture)
      }
    case .singleTouchWithSlide:
      viewPiano.isMultipleTouchEnabled = false
      if let pianoLongPressGesture {
        viewPiano.addGestureRecognizer(pianoLongPressGesture)
      }
    case .multiTouchOnly:
      viewPiano.isMultipleTouchEnabled = true
      if let pianoLongPressGesture {
        viewPiano.removeGestureRecognizer(pianoLongPressGesture)
      }
    }
    
    prevTouchedKey = nil
    touchStartInfos = [:]
  }
  
  
  // MARK: - Start or stop key press
  
  func startKeyPress(_ keyInfo: PianoKeyInfo, isLongPress: Bool = true) {
    let semitoneStart = 60 + PianoKeyHelper.adjustKeySemitone(key: currentPlayableKey)
    
    // 20250506 추가: keyInfo를 미리 prevTouchedKey에 배정하고
    // .stricted 모드에서 터치 슬라이드를 할 때 끊기는 것 방지
    prevTouchedKey = keyInfo
    
    // 스트릭트 모드일 경우에만 유효한 키인지 검사
    // contentMode != .stricted → 스트릭트 모드가 아닌 경우는 무조건 통과
    // 이하 → 스트릭트 모드인 경우에는 해당 인덱스가 있는지 확인
    guard contentMode != .stricted || viewPiano.viewModel.availableKeyIndexes.contains(keyInfo.keyIndex) else {
      return
    }
    
    // 노트 재생
    let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
    generator.playSound(noteNumber: targetNoteNumber)
    
    viewPiano.viewModel.insertCurrentTouchedKeysWithRefreshView(keyInfo)
    
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
      
      prevTouchedKey = nil
      
      let targetNoteNumber = semitoneStart + keyInfo.keyIndex + (octaveShift * 12)
      generator.stopSimply(noteNumber: targetNoteNumber)
    }
  }
}

// MARK: - Extensions

extension PianoViewController {
  // MARK: - Touches Overriding
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard keyPressMode != .singleTouchWithSlide else { return }
    guard isKeyPressEnabled else { return }
    
    GESTURE_DEBUG ? print("GESTURE: \(#function)") : nil
    
    for touch in touches {
      let location = touch.location(in: viewPiano)
      GESTURE_DEBUG ? print("touches: start", location) : nil

      // 시작 위치, 타임스탬프 저장
      touchStartInfos[touch] = .init(location: location, touchTimestamp: touch.timestamp)
      
      if let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: location) {
        startKeyPress(keyInfo)
      }
      
      if keyPressMode == .singleTouchOnly || contentMode == .quiz {
        break
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard keyPressMode != .singleTouchWithSlide else { return }
    guard isKeyPressEnabled else { return }
    
    GESTURE_DEBUG ? print("GESTURE: \(#function)") : nil
    
    for touch in touches {
      if let startInfo = touchStartInfos[touch],
         let keyInfo = viewPiano.viewModel.getKeyInfoBy(touchLocation: startInfo.location) {
        let endTime = touch.timestamp
        let heldTime = endTime - startInfo.touchTimestamp
        let remainingTime = MIN_HOLD_TIME - heldTime
        
        if remainingTime > 0 {
          DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) {
            self.stopKeyPress(keyInfo)
          }
        } else {
          stopKeyPress(keyInfo)
        }
        
        touchStartInfos.removeValue(forKey: touch)
      }
    }
  }
}

extension PianoViewController {
  // MARK: - Key Utilities
  
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

extension PianoViewController {
  // MARK: - Inner enums & structs
  
  struct TouchInfo {
    var location: CGPoint
    var touchTimestamp: TimeInterval
  }
  
  enum ContentMode {
    case stricted, quiz
  }
  
  enum KeyPressMode: Int {
    case singleTouchOnly = 0
    case singleTouchWithSlide
    case multiTouchOnly
    
    var next: Self {
      // 순서: 싱글 터치 -> 슬라이드 -> 멀티
      switch self {
      case .singleTouchOnly:
          .singleTouchWithSlide
      case .singleTouchWithSlide:
          .multiTouchOnly
      case .multiTouchOnly:
          .singleTouchOnly
      }
    }
    
    var systemImageString: String {
      switch self {
      case .singleTouchOnly:
        "hand.point.up"
      case .singleTouchWithSlide:
        "hand.draw"
      case .multiTouchOnly:
        "hand.raised"
      }
    }
  }
}
