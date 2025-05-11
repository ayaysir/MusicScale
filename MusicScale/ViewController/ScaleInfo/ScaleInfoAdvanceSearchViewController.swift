//
//  ScaleInfoAdvanceSearchViewController.swift
//  MusicScale
//
//  Created by 윤범태 on 5/8/25.
//

import UIKit
import WebKit
import DropDown

// TODO: - ⚠️⚠️ 키보드 공통부분, 악보 표시 공통부분 모듈화 ⚠️⚠️

class ScaleInfoAdvanceSearchViewController: UIViewController {
  @IBOutlet weak var webView: WKWebView!
  @IBOutlet weak var btnSubmit: UIButton!
  @IBOutlet weak var barBtnReset: UIBarButtonItem!
  @IBOutlet weak var barBtnBackspace: UIBarButtonItem!
  @IBOutlet weak var btnPlayOnEdit: UIButton!
  @IBOutlet weak var containerViewPiano: UIView!
  @IBOutlet weak var stepperTranspose: UIStepper!
  @IBOutlet weak var btnTranspose: UIButton!
  @IBOutlet weak var tblViewScaleList: UITableView!
  
  private var pianoVC: PianoViewController?
  private var currentPlayableKey: Music.PlayableKey = .C
  private var staffWidth: Int? { setStaffWidth() }
  
  private var currentDisplayAbcjsText: String?
  var playTimer: Timer?
  
  private var editViewModel = AdvSearchEditKeyViewModel(
    key: .C,
    tempo: ScaleInfoVCConfigStore.shared.tempo
  )
  private var scaleListViewModel = ScaleInfoListViewModel()
  private var resultScaleList: [InfoWithSimilarity] = [] {
    didSet {
      updateTableBackgroundView()
    }
  }
  
  private let conductor = GlobalConductor.shared
  private let transposeDropDown = DropDown()
  
  // MARK: - View Lifecycles
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setPianoPosition(playableKey: currentPlayableKey)
    
    webView.layoutIfNeeded()
    webView.isUserInteractionEnabled = false
    
    initWebSheetPage(initAbcjsText: editViewModel.abcjsTextOnEdit, staffWidth: staffWidth)
    
    initTransposeDropDown()
    
    tblViewScaleList.dataSource = self
    tblViewScaleList.delegate = self
    updateTableBackgroundView()
    
    title = "Scale Search"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if isPhone {
      OrientationUtil.lockOrientation(.portrait)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if isPhone {
      OrientationUtil.lockOrientation(.portrait, andRotateTo: .portrait)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    showTabBar(self)
    OrientationUtil.lockOrientation(.all)
    stopSequencer()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    
    if isPad {
      hideTabBarWhenLandscape(self)
    }
    
    // https://stackoverflow.com/questions/26943808/ios-how-to-run-a-function-after-device-has-rotated-swift
    coordinator.animate(alongsideTransition: nil) { _ in
      self.redrawPianoViewWhenOrientationChange()
    }
  }
  
  // MARK: - Action Outlets
  
  @IBAction func btnActPlay(_ sender: UIButton) {
    playOrStop()
  }
  
  @IBAction func btnActSubmit(_ sender: UIButton) {
    submit()
  }
  
  @IBAction func btnActReset(_ sender: UIBarButtonItem) {
    editViewModel.removeAllKeys()
    refreshSheetView()
  }
  
  @IBAction func btnActBackspace(_ sender: UIBarButtonItem) {
    backspaceNote()
  }
  
  @IBAction func btnActTranspose(_ sender: UIButton) {
    transposeDropDown.anchorView = sender
    transposeDropDown.show()
  }
  
  @IBAction func stepperActTranspose(_ sender: UIStepper) {
    let index = Int(sender.value)
    let noteStr = transposeDropDown.dataSource[index]
    transpose(noteStr: noteStr)
  }
  
  // MARK: - Set/Init methods
  
  func initTransposeDropDown() {
    var dataSource: [String] {
      Music.Key.allCases.map { $0.textValue }
    }
    
    let selectionAction = { [unowned self] (index: Int, item: String) in
      transpose(noteStr: item)
      stepperTranspose.value = Double(index)
    }
    
    transposeDropDown.cornerRadius = 10
    transposeDropDown.cellHeight = 30
    
    transposeDropDown.dataSource = dataSource
    transposeDropDown.selectionAction = selectionAction
    
    stepperTranspose.maximumValue = Double(transposeDropDown.dataSource.count) - 1
    stepperTranspose.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
  }
  
  func transpose(noteStr: String, initChange: Bool = false) {
    self.btnTranspose.setTitle(noteStr, for: .normal)
    
    if let targetKey = Music.Key.getKeyFromNoteStr(noteStr) {
      editViewModel.key = targetKey
      
      // change keyboard start position
      setPianoPosition(playableKey: targetKey.playableKey)
      editViewModel.setScaleName(key: targetKey)
      injectAbcjsText(from: editViewModel.abcjsTextOnEdit, needReload: true, staffWidth: staffWidth)
    }
  }
  
  
  func setStaffWidth() -> Int {
    /*
     landscape
     ipad 12 : 600 (570)
     ipad 11 : 750 (417)
     ipad mini : 1000 (344.5)
     ipad 9.7 : 750 (364)
     ipad Air : 750 (406)
     iPad 5th : 750 (397.5)
     
     0 ~ 228 (600 ~ 1000)
     */
    
    // // Orientation Test
    // lblKeyName.text = "\(isLandscape) : \(isPad) : \(UIDevice.current.orientation == .unknown) : \(UIDevice.current.orientation.isFlat)"
    
    if isLandscape && isPad {
      // print("📱 isLandscape && isPad:", UIDevice().type.rawValue)
      if isIpad129 {
        return 600
      } else if isIpadMini {
        return 1000
      } else {
        return 750
      }
    }
    
    return DEF_STAFFWIDTH
  }
  
  /// 방향 전환시 피아노 뷰 다시 그리기 (coordinator.animate(alongsideTransition: nil) {...})
  func redrawPianoViewWhenOrientationChange() {
    containerViewPiano.layoutIfNeeded()
    pianoVC?.parentContainerView = containerViewPiano
    pianoVC?.setPiano()
    
    setPianoPosition(playableKey: currentPlayableKey)
    
    if let currentDisplayAbcjsText {
      injectAbcjsText(from: currentDisplayAbcjsText, needReload: true, staffWidth: staffWidth)
    }
  }
  
  func setPianoPosition(playableKey: Music.PlayableKey) {
    currentPlayableKey = playableKey
    pianoVC?.adjustKeyPosition(key: playableKey)
    pianoVC?.updateAvailableKeys(integerNotations: [])
  }
  
  func initWebSheetPage(initAbcjsText: String, staffWidth: Int? = DEF_STAFFWIDTH) {
    if #available(iOS 14.0, *) {
      webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    } else {
      // Fallback on earlier versions
      webView.configuration.preferences.javaScriptEnabled = true
    }
    
    // 웹 파일 로딩
    webView.uiDelegate = self
    webView.navigationDelegate = self
    let pageName = "index"
    guard let url = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "web") else {
      return
    }
    webView.loadFileURL(url, allowingReadAccessTo: url)
    webView.scrollView.isScrollEnabled = false
    
    injectAbcjsText(from: initAbcjsText, needReload: false, staffWidth: staffWidth)
    
    // 자바스크립트 -> 네이티브 앱 연결
    // 브리지 등록
    webView.configuration.userContentController.add(self, name: "notePlayback")
    
    // inject JS to capture console.log output and send to iOS
    let source = """
            function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); }
            window.console.log = captureLog;
        """
    let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    webView.configuration.userContentController.addUserScript(script)
    // register the bridge script that listens for the output
    webView.configuration.userContentController.add(self, name: "logHandler")
  }
  
  func refreshSheetView() {
    injectAbcjsText(from: editViewModel.abcjsTextOnEdit, needReload: true, staffWidth: staffWidth)
    currentDisplayAbcjsText = editViewModel.abcjsTextOnEdit
    self.highlightLastNote()
  }
  
  func injectAbcjsText(
    from abcjsText: String,
    needReload: Bool = true,
    staffWidth: Int? = DEF_STAFFWIDTH
  ) {
    
    let abcjsTextFixed = charFixedAbcjsText(abcjsText)
    
    if needReload {
      webView.evaluateJavaScript(generateAbcJsInjectionSource(from: abcjsTextFixed, staffWidth: staffWidth))
    } else {
      let injectionSource = generateAbcJsInjectionSource(from: abcjsTextFixed, staffWidth: staffWidth)
      let injectionScript = WKUserScript(source: injectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
      webView.configuration.userContentController.addUserScript(injectionScript)
    }
  }
  
  func highlightLastNote() {
    var cursorIndex: Int {
      editViewModel.onEditNotes.count
    }
    
    // 첫번째 노트는 하이라이트하지 않음
    guard cursorIndex > 0 else {
      return
    }
    
    webView.evaluateJavaScript("""
        document.querySelector(".abcjs-n\(cursorIndex)").classList.add("abcjs-highlight");
        """)
  }
  
  func setHighlightPart(playMode: PlayMode) {
    webView.evaluateJavaScript("showHighlightParts = [0]")
  }
  
  func addNoteToSheet(intNotation: Int) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      
      editViewModel.addKey(intNotation: intNotation, enharmonicMode: .standard)
      
      injectAbcjsText(from: editViewModel.abcjsTextOnEdit, needReload: true, staffWidth: staffWidth)
      currentDisplayAbcjsText = editViewModel.abcjsTextOnEdit
      highlightLastNote()
    }
  }
  
  func backspaceNote() {
    editViewModel.removeLastKey()
    refreshSheetView()
  }
  
  func playOrStop() {
    if conductor.sequencer.isPlaying {
      stopSequencer()
    }
    
    startSequencer()
  }
  
  func startSequencer(playMode: PlayMode? = .onEdit) {
    stopSequencer()
    
    conductor.addScaleToSequencer(semitones: editViewModel.playbackMidiNumbersOnEdit, startSemitone: 0)
    
    setHighlightPart(playMode: .onEdit)
    conductor.tempo = Float(ScaleInfoVCConfigStore.shared.tempo)
    self.conductor.isPlaying = true
    startTimer()
    playTimer = Timer.scheduledTimer(timeInterval: conductor.sequencer.length.seconds, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
  }
  
  @objc func stopSequencer() {
    stopTimer()
    conductor.sequencer.stop()
    conductor.sequencer.rewind()
    conductor.isPlaying = false
    playTimer?.invalidate()
    
    highlightLastNote()
  }
  
  func startTimer() {
    webView.evaluateJavaScript("startTimer()")
  }
  
  func stopTimer() {
    webView.evaluateJavaScript("stopTimer()")
  }
  
  func submit() {
    resultScaleList = scaleListViewModel.similarityData(onEditNotes: editViewModel.integerNotationsOnEdit)
    tblViewScaleList.reloadData()
    tblViewScaleList.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "SearchPianoSegue":
      containerViewPiano.layoutIfNeeded()
      pianoVC = segue.destination as? PianoViewController
      pianoVC?.parentContainerView = containerViewPiano
      pianoVC?.contentMode = .quiz
      pianoVC?.delegate = self
    case "DetailViewSegue":
      guard let scaleInfoVC = segue.destination as? ScaleInfoViewController,
            let receivedInfoViewModel = sender as? ScaleInfoViewModel else {
        return
      }
      
      scaleInfoVC.scaleInfoViewModel = receivedInfoViewModel
      scaleInfoVC.delegate = self
    default:
      break
    }
  }
}

extension ScaleInfoAdvanceSearchViewController: UITableViewDataSource, UITableViewDelegate {
  // MARK: Table View Delegate
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    resultScaleList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScaleListCell", for: indexPath) as? ScaleListCell else {
      return UITableViewCell()
    }
    
    let infoTuple = resultScaleList[indexPath.row]
    
    cell.configure(infoViewModel: infoTuple.infoVM)
    // percent label: 스토리보드 레이블 목록 위치 항상 첫번째로
    if let lblPercent = cell.contentView.subviews.first as? UILabel {
      lblPercent.text = String(format: "%.0f%%", infoTuple.similarity)
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(
      withIdentifier: "DetailViewSegue",
      sender: resultScaleList[safe: indexPath.row]?.infoVM
    )
  }
  
  func updateTableBackgroundView() {
    if resultScaleList.isEmpty {
      let messageLabel = UILabel()
      messageLabel.text = "건반을 이용한 고급 검색 기능\n\n1. 조성을 설정하세요.\n\n2. 건반, 키보드, 미디 장치 등을 통해 찾고자 하는 스케일을 해당 조성에 맞게 입력하세요.\n순서에 상관없이 자유롭게 입력할 수 있습니다.\n\n3. [제출] 버튼을 눌러 결과 목록을 확인하세요.\n퍼센트 단위로 유사도와 스케일 목록이 표시됩니다."
      messageLabel.textAlignment = .center
      messageLabel.textColor = .gray
      messageLabel.font = UIFont.systemFont(ofSize: 16)
      messageLabel.numberOfLines = 0

      tblViewScaleList.backgroundView = messageLabel
    } else {
      tblViewScaleList.backgroundView = nil
    }
  }
}

extension ScaleInfoAdvanceSearchViewController: PianoVCDelegate {
  func didKeyPressed(_ controller: PianoViewController, keyInfo: PianoKeyInfo) {
    let intNotation = keyInfo.keyIndex - PianoKeyHelper.findRootKeyPosition(playableKey: currentPlayableKey)
    addNoteToSheet(intNotation: intNotation)
  }
  
  func didMIDIReceived(_ controller: PianoViewController, noteNumber: Int) {
    // 현재 키가 C#이면 C#(Db)4가 0, C#(Db)5가 12가 나와야 함
    let intNotationRelative = noteNumber - 60 - currentPlayableKey.rawValue
    addNoteToSheet(intNotation: intNotationRelative)
  }
}

extension ScaleInfoAdvanceSearchViewController: ScaleInfoVCDelgate {
  func didInfoUpdated(_ controller: ScaleInfoViewController, indexPath: IndexPath?) {
    guard let indexPath else {
      tblViewScaleList.reloadData()
      return
    }
    
    tblViewScaleList.reloadRows(at: [indexPath], with: .none)
  }
}

extension ScaleInfoAdvanceSearchViewController {
  // MARK: - KeyPress
  
  var characterSet: CharacterSet {
    var characterSet = CharacterSet(charactersIn: ",./;'")
    characterSet.formUnion(.alphanumerics)
    return characterSet
  }
  
  func startHWKeyPress(key: UIKey) {
    if let pianoVC,
       let firstScalar = key.charactersIgnoringModifiers.unicodeScalars.first,
       characterSet.contains(firstScalar) {
      pianoVC.startKeyPressByHWKeyboard(keyValueIgnoringModifiers: key.charactersIgnoringModifiers)
    }
  }
  
  func endHWKeyPress(key: UIKey) {
    if let pianoVC,
       let firstScalar = key.charactersIgnoringModifiers.unicodeScalars.first,
       characterSet.contains(firstScalar) {
      pianoVC.endKeyPressByHWKeyboard(keyValueIgnoringModifiers: key.charactersIgnoringModifiers)
      return
    }
  }
  
  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    guard let key = presses.first?.key else { return }
    
    switch key.keyCode {
    case .keyboardSpacebar:
      playOrStop()
    case .keyboardDeleteOrBackspace:
      backspaceNote()
    case .keyboardReturnOrEnter:
      submit()
    default:
      if (4...56) ~= key.keyCode.rawValue {
        startHWKeyPress(key: key)
        return
      }
      
      super.pressesBegan(presses, with: event)
    }
  }
  
  override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    guard let key = presses.first?.key else { return }
    
    if (4...56) ~= key.keyCode.rawValue {
      endHWKeyPress(key: key)
    }
    
    super.pressesEnded(presses, with: event)
  }
}

extension ScaleInfoAdvanceSearchViewController: WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {}
}
