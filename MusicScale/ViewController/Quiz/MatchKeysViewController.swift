//
//  MatchKeysViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/06.
//

import UIKit
import WebKit

class MatchKeysViewController: InQuizViewController {

    @IBOutlet weak var lblKeyName: UILabel!
    @IBOutlet weak var lblOrder: UILabel!
    @IBOutlet weak var lblQuizProgressInfo: UILabel!
    @IBOutlet weak var containerViewPiano: UIView!
    // @IBOutlet weak var viewWebContainer: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var viewQuizTitles: UIView!
    @IBOutlet weak var cnstTitlesHeight: NSLayoutConstraint!
    @IBOutlet weak var cnstSpaceBetweenProgAndTits: NSLayoutConstraint!
    
    @IBOutlet weak var viewBannerContainer: UIView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblResult: UILabel!
    
    @IBOutlet weak var barBtnReset: UIBarButtonItem!
    @IBOutlet weak var barBtnBackspace: UIBarButtonItem!
    
    @IBOutlet weak var btnPlayOnEdit: UIButton!
    @IBOutlet weak var btnPlayAnswer: UIButton!
    @IBOutlet weak var btnPlayTogether: UIButton!
    
    @IBOutlet weak var progressViewInStudying: UIProgressView!
    @IBOutlet weak var progressViewDayQuestionProgress: UIProgressView!
    var prevDayQuestionPercent: Float = 0.0
    
    private var staffWidth: Int? { setStaffWidth() }
    
    /// 지금 문제 풀이중?
    var isSolvingQuestionNow: Bool = true {
        didSet { didSetIsSolvingQuestionNow() }
    }
    
    var pianoVC: PianoViewController?
    
    private var currentPlayableKey: Music.PlayableKey?
    // private var currentQuestion: QuizQuestion?
    private var currentEditViewModel: QuizEditKeyViewModel?
    private var currentScaleInfoVM: SimpleScaleInfoViewModel?
    private var currentPlayMode: PlayMode?
    private var currentDisplayAbcjsText: String?
    var questionSuccessResult: Bool? {
        didSet { didSetQuestionSuccessResult() }
    }
    
    private var firstrun: Bool = true
    
    /// 문제 시작부터 정답까지 몇 초 걸렸는지 타이머
    private var solvingTimer: Timer?
    private var elapsedSeconds: Int = 0
    
    private var keyPressTimer: Timer?
    private var lastKeyPressedInterval: Int = 0 {
        didSet {
            if lastKeyPressedInterval == 6 {
                if !isSolvingQuestionNow && viewBannerContainer.isHidden {
                    fadeBannerOnPiano(fadeIn: true)
                }
                lastKeyPressedInterval = 0
                keyPressTimer?.invalidate()
                keyPressTimer = nil
            }
        }
    }

    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBannerAds(self, container: viewBannerContainer)
        viewBannerContainer.isHidden = true
        
        DispatchQueue.main.async {
            self.removeTitlesIfIphoneTouch()
        }
        
        // button design
        btnSubmit.layer.cornerRadius = 10
        lblResult.layer.cornerRadius = 10
        lblResult.clipsToBounds = true
        
        webView.layoutIfNeeded()
        print("⛔️ MatchTheKeysVC webview frame:", webView.frame)
        print("⛔️ MatchTheKeysVC view frame:", view.frame)
        webkitView = webView
        webkitView.isUserInteractionEnabled = false
        
        initButtonsAppearance()
        
        // Override displayNextQuestionHandler
        displayNextQuestionHandler = { [unowned self] newQuestion in
            solvingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                self.elapsedSeconds += 1
            })
            
            self.displayName(question: newQuestion)
            
            let tempo = playbackConfigStore.tempo
            currentQuestion = newQuestion
            currentScaleInfoVM = SimpleScaleInfoViewModel(scaleInfo: newQuestion.scaleInfo, currentKey: newQuestion.key, currentTempo: tempo, currentEnharmonicMode: quizStore.enharmonicMode)
            currentEditViewModel = QuizEditKeyViewModel(scaleInfo: newQuestion.scaleInfo, key: newQuestion.key, order: newQuestion.isAscending ? .ascending : .descending, tempo: tempo)
            
            setPianoPosition(playableKey: newQuestion.key.playableKey)
            
            quizViewModel.incrementTryCount()
            
            if firstrun {
                isSolvingQuestionNow = true
                initWebSheetPage(initAbcjsText: currentEditViewModel!.abcjsTextOnEdit, staffWidth: staffWidth)
                firstrun = false
                updateProgressViews(isBeforeSubmit: true)
            }
            
            refreshSheetView()
            updateProgressViews(isBeforeSubmit: true)
        }
        
        loadFirstQuestion()
        
        if isPad {
            hideTabBarWhenLandscape(self)
        }
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
    
    // MARK: - Initial methods
    
    /// 방향 전환시 피아노 뷰 다시 그리기 (coordinator.animate(alongsideTransition: nil) {...})
    func redrawPianoViewWhenOrientationChange() {
        containerViewPiano.layoutIfNeeded()
        pianoVC?.parentContainerView = containerViewPiano
        pianoVC?.setPiano()
        
        if let currentPlayableKey = currentPlayableKey {
            setPianoPosition(playableKey: currentPlayableKey)
        } else if let currentQuestion = currentQuestion {
            setPianoPosition(playableKey: currentQuestion.key.playableKey)
        }
        
        if let currentDisplayAbcjsText = currentDisplayAbcjsText {
            injectAbcjsText(from: currentDisplayAbcjsText, needReload: true, staffWidth: staffWidth)
        }
    }
    
    private func initButtonsAppearance() {
        let space: CGFloat = 10
        btnPlayOnEdit.spaceBetweenImageAndText(space: space)
        btnPlayAnswer.spaceBetweenImageAndText(space: space)
        btnPlayTogether.spaceBetweenImageAndText(space: space)
    }
    
    private func removeTitlesIfIphoneTouch() {
        let isIPhoneTouch = isLandscape ? view.frame.height == 320 : view.frame.width == 320
        if isIPhoneTouch {
            lblResult.frame.origin = CGPoint(x: lblResult.frame.origin.x, y: 0)
            lblKeyName.frame.size.height = 0.0
            lblOrder.frame.size.height = 0.0
            cnstTitlesHeight.constant = lblResult.frame.size.height
        }
    }
    
    // MARK: - computed properties or didSet
    
    private func isCorrectDevice(_ logicalWidth: CGFloat, _ logicalHeight: CGFloat) -> Bool {
        let width = view.frame.size.width
        let height = view.frame.size.height
        return !isLandscape ? width == logicalWidth && height == logicalHeight : width == logicalHeight && height == logicalWidth
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
    
    func didSetIsSolvingQuestionNow() {
        if isSolvingQuestionNow {
            barBtnReset.isEnabled = true
            barBtnBackspace.isEnabled = true
            btnPlayAnswer.isEnabled = false
            btnPlayTogether.isEnabled = false
            btnSubmit.setTitle("Submit".localized(), for: .normal)
            btnSubmit.backgroundColor = .systemOrange
            
            viewBannerContainer.isHidden = true
        } else {
            barBtnReset.isEnabled = false
            barBtnBackspace.isEnabled = false
            btnPlayAnswer.isEnabled = true
            btnPlayTogether.isEnabled = true
            btnSubmit.setTitle("Next >>".localized(), for: .normal)
            btnSubmit.backgroundColor = .systemBlue
            
            if AdsManager.SHOW_AD {
                fadeBannerOnPiano(fadeIn: true)
            }
        }
    }
    
    var isFadeAnimatingNow: Bool = false
    func fadeBannerOnPiano(fadeIn: Bool) {
        let duration: TimeInterval = 1.2
            
        DispatchQueue.main.async {
            self.viewBannerContainer.layoutIfNeeded()
            if fadeIn && self.viewBannerContainer.isHidden {
                self.viewBannerContainer.alpha = 0
                self.viewBannerContainer.isHidden = false
                
                UIView.animate(withDuration: duration) {
                    self.isFadeAnimatingNow = true
                    self.viewBannerContainer.alpha = 1
                } completion: { _ in
                    self.isFadeAnimatingNow = false
                }
            } else if !fadeIn && !self.viewBannerContainer.isHidden {
                self.viewBannerContainer.alpha = 1
                
                UIView.animate(withDuration: duration) {
                    self.isFadeAnimatingNow = true
                    self.viewBannerContainer.alpha = 0
                } completion: { _ in
                    self.viewBannerContainer.isHidden = true
                    self.isFadeAnimatingNow = false
                }
            }
        }
    }
    
    func didSetQuestionSuccessResult() {
        if questionSuccessResult == nil {
            lblResult.text = "🤔"
            lblResult.backgroundColor = .tertiarySystemGroupedBackground
            lblResult.textColor = nil
        } else if let result = questionSuccessResult {
            if result {
                lblResult.text = "Success".localized()
                lblResult.backgroundColor = UIColor(named: "Color_QuizSuccess")
                lblResult.textColor = .white
            } else {
                lblResult.text = "Failed".localized()
                lblResult.backgroundColor = .systemPink
                lblResult.textColor = .white
            }
        }
    }
    
    // MARK: - @IBAction
    @IBAction func barBtnActBackspaceNote(_ sender: UIBarButtonItem) {
        if let currentEditViewModel = currentEditViewModel {
            currentEditViewModel.removeLastKey()
            refreshSheetView()
        }
    }
    
    @IBAction func barBtnActResetNotes(_ sender: UIBarButtonItem) {
        if let currentEditViewModel = currentEditViewModel {
            currentEditViewModel.removeAllKeys()
            refreshSheetView()
        }
    }
    
    @IBAction func btnActSubmit(_ sender: Any) {
        // Next 버튼
        if !isSolvingQuestionNow, let result = questionSuccessResult {
            questionSuccessResult = nil
            isSolvingQuestionNow = true
            setQuizStatFromCurrentQuestion(result, elapsedSeconds: resetSolvingTimer())
            progressNextQuestion(result)
            stopSequencer()
            return
        }
        
        // Submit 버튼
        if let question = currentQuestion,
           let editVM = currentEditViewModel,
           let infoVM = currentScaleInfoVM {
            
            questionSuccessResult = editVM.checkAnswer(originalAnswer: question.isAscending ? infoVM.ascendingIntegerNotationArray : infoVM.descendingIntegerNotationArray)
            
            // editMode
            isSolvingQuestionNow = false
            updateProgressViews(isBeforeSubmit: false)
            
            // 정답, 오답 비교 표시
            let order: DegreesOrder = question.isAscending ? .ascending : .descending
            let abcjsText = editVM.abcjsTextForComparison(questionSuccessResult!, originalDegrees: infoVM.targetDegrees(order: order), order: order, key: infoVM.currentKey, octaveShift: 0, enharmonicMode: quizStore.enharmonicMode)
            injectAbcjsText(from: abcjsText, needReload: true, staffWidth: staffWidth)
            currentDisplayAbcjsText = abcjsText
        } 
    }
    
    @IBAction func btnActPlayOnEdit(_ sender: UIButton) {
        playOrStop(playMode: .onEdit)
    }
    
    @IBAction func btnActPlayAnswer(_ sender: UIButton) {
        playOrStop(playMode: .answer)
    }
    
    @IBAction func btnActPlayTogether(_ sender: UIButton) {
        playOrStop(playMode: .together)
    }
    
    // MARK: - Custom methods
    
    func refreshSheetView() {
        if let currentEditViewModel = currentEditViewModel {
            injectAbcjsText(from: currentEditViewModel.abcjsTextOnEdit, needReload: true, staffWidth: staffWidth)
            currentDisplayAbcjsText = currentEditViewModel.abcjsTextOnEdit
            self.highlightLastNote()
        }
    }
    
    func displayName(question: QuizQuestion) {
        lblKeyName.text = "\(question.key.textValue) \(question.scaleInfo.name)"
        lblOrder.text = question.isAscending ? "Ascending".localized() : "Descending".localized()
        self.title = "\(lblKeyName.text!) \(question.isAscending ? "⬆" : "⬇")"
        lblQuizProgressInfo.text = quizViewModel.quizStatus
    }
    
    func setPianoPosition(playableKey: Music.PlayableKey) {
        currentPlayableKey = playableKey
        pianoVC?.adjustKeyPosition(key: playableKey)
        pianoVC?.updateAvailableKeys(integerNotations: [])
    }
    
    func highlightLastNote() {
        var cursorIndex: Int {
            if let currentEditViewModel = currentEditViewModel {
                return currentEditViewModel.onEditNotes.count
            }
            
            return 0
        }
        
        // 첫번째 노트는 하이라이트하지 않음
        guard cursorIndex > 0 else {
            return
        }
        
        webkitView.evaluateJavaScript("""
        document.querySelector(".abcjs-n\(cursorIndex)").classList.add("abcjs-highlight");
        """)
    }
    
    func updateProgressViews(isBeforeSubmit: Bool) {
        // day 0: 문제 진행 프로그레스
        // day 1~ : 완료한 문제 프로그레스
        let (isPhaseOne, percent) = quizViewModel.studyingProgress(isBeforeSubmit: isBeforeSubmit)
        if !isPhaseOne {
            // ??
            changeProgressViewColor(isPhaseOne: isPhaseOne)
        }
        progressViewInStudying.setProgress(percent, animated: true)
        
        let dayQuestionPercent = quizViewModel.dayQuestionProgress(isBeforeSubmit: isBeforeSubmit)
        let animateDayQuestion = prevDayQuestionPercent != 1.0
        if animateDayQuestion {
            progressViewDayQuestionProgress.setProgress(dayQuestionPercent, animated: true)
        } else {
            progressViewDayQuestionProgress.setProgress(0.0, animated: false)
            progressViewDayQuestionProgress.setProgress(dayQuestionPercent, animated: true)
        }
        
        lblQuizProgressInfo.text = quizViewModel.quizStatus
        
        prevDayQuestionPercent = dayQuestionPercent
    }
    
    func changeProgressViewColor(isPhaseOne: Bool) {
        if isPhaseOne {
            progressViewInStudying.progressTintColor = .systemYellow
            progressViewInStudying.trackTintColor = nil
        } else {
            progressViewInStudying.progressTintColor = .realGreeen
            progressViewInStudying.trackTintColor = .systemYellow
        }
    }
    
    func resetSolvingTimer() -> Int {
        solvingTimer?.invalidate()
        solvingTimer = nil
        let storedSeconds = self.elapsedSeconds
        self.elapsedSeconds = 0
        return storedSeconds
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "QuizPianoSegue":
            containerViewPiano.layoutIfNeeded()
            pianoVC = segue.destination as? PianoViewController
            pianoVC?.parentContainerView = containerViewPiano
            pianoVC?.mode = .quiz
            pianoVC?.delegate = self
        default:
            break
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // highlightLastNote()
    }
}

extension MatchKeysViewController: ConductorPlay {
    
    func playOrStop(playMode: PlayMode? = nil) {
        
        guard let playMode = playMode else {
            return
        }
        
        let beforePlayMode = currentPlayMode
        
        if conductor.sequencer.isPlaying {
            stopSequencer()
        }
        
        if let beforePlayMode = beforePlayMode, beforePlayMode == playMode {
            return
        }
        
        startSequencer(playMode: playMode)
    }
    
    @objc func stopSequencer() {
        stopTimer()
        conductor.sequencer.stop()
        conductor.sequencer.rewind()
        conductor.isPlaying = false
        playTimer?.invalidate()
        
        currentPlayMode = nil
        highlightLastNote()
    }
    
    func setHighlightPart(playMode: PlayMode) {
        switch playMode {
        case .onEdit:
            webkitView.evaluateJavaScript("showHighlightParts = [0]")
        case .answer:
            webkitView.evaluateJavaScript("showHighlightParts = [1]")
        case .together:
            webkitView.evaluateJavaScript("showHighlightParts = []")
        }
    }
    
    func startSequencer(playMode: PlayMode? = .onEdit) {
        stopSequencer()
        
        guard let playMode = playMode,
              let editVM = currentEditViewModel,
              let infoVM = currentScaleInfoVM,
              let isAscending = currentQuestion?.isAscending else {
            return
        }
        
        guard let semitones = isAscending ? infoVM.playbackSemitoneAscending : infoVM.playbackSemitoneDescending else {
            return
        }
        
        switch playMode {
        case .onEdit:
            self.conductor.addScaleToSequencer(semitones: editVM.playbackMidiNumbersOnEdit, startSemitone: 0)
        case .answer:
            self.conductor.addScaleToSequencer(semitones: semitones)
        case .together:
            self.conductor.addScaleToSequencerTwoTrack(semitones1: editVM.playbackMidiNumbersOnEdit, semitones2: semitones, startFrom_1: 0, startFrom_2: 60)
        }
        
        setHighlightPart(playMode: playMode)
        conductor.tempo = Float(playbackConfigStore.tempo)
        self.conductor.isPlaying = true
        startTimer()
        playTimer = Timer.scheduledTimer(timeInterval: conductor.sequencer.length.seconds, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
        
        self.currentPlayMode = playMode
    }
}

// MARK: - PianoVCDelegate
extension MatchKeysViewController: PianoVCDelegate {
    func didMIDIReceived(_ controller: PianoViewController, noteNumber: Int) {
        guard let currentPlayableKey else {
            return
        }
        
        // 현재 키가 C#이면 C#(Db)4가 0, C#(Db)5가 12가 나와야 함
        let intNotationRelative = noteNumber - 60 - currentPlayableKey.rawValue
        addNoteToSheet(intNotation: intNotationRelative)
    }
    
    func didKeyPressed(_ controller: PianoViewController, keyInfo: PianoKeyInfo) {
        guard isSolvingQuestionNow else {
            if !isFadeAnimatingNow && !viewBannerContainer.isHidden {
                fadeBannerOnPiano(fadeIn: false)
                keyPressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                    self.lastKeyPressedInterval += 1
                })
            }
            
            lastKeyPressedInterval = 0
            return
        }
        
        guard let currentPlayableKey = currentPlayableKey else { return }
        
        let intNotation = keyInfo.keyIndex - PianoKeyHelper.findRootKeyPosition(playableKey: currentPlayableKey)
        
        print(currentPlayableKey, keyInfo, intNotation)
        addNoteToSheet(intNotation: intNotation)
    }
    
    func addNoteToSheet(intNotation: Int) {
        guard let currentEditViewModel = currentEditViewModel else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            currentEditViewModel.addKey(intNotation: intNotation, enharmonicMode: quizStore.enharmonicMode)
            
            injectAbcjsText(from: currentEditViewModel.abcjsTextOnEdit, needReload: true, staffWidth: staffWidth)
            currentDisplayAbcjsText = currentEditViewModel.abcjsTextOnEdit
            highlightLastNote()
        }
        
    }
}
