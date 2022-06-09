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
    @IBOutlet weak var viewWebContainer: UIView!
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
    
    /// 지금 문제 풀이중?
    var isSolvingQuestionNow: Bool = true {
        didSet {
            if isSolvingQuestionNow {
                barBtnReset.isEnabled = true
                barBtnBackspace.isEnabled = true
                btnPlayAnswer.isEnabled = false
                btnPlayTogether.isEnabled = false
                btnSubmit.setTitle("Submit", for: .normal)
                btnSubmit.backgroundColor = .systemOrange
            } else {
                barBtnReset.isEnabled = false
                barBtnBackspace.isEnabled = false
                btnPlayAnswer.isEnabled = true
                btnPlayTogether.isEnabled = true
                btnSubmit.setTitle("Next >>", for: .normal)
                btnSubmit.backgroundColor = .systemBlue
            }
        }
    }
    
    var pianoVC: PianoViewController?
    
    var currentPlayableKey: Music.PlayableKey?
    var currentQuestion: QuizQuestion?
    var currentEditViewModel: QuizEditKeyViewModel?
    var currentScaleInfoVM: SimpleScaleInfoViewModel?
    var currentPlayMode: PlayMode?
    var questionSuccessResult: Bool? {
        didSet {
            if questionSuccessResult == nil {
                lblResult.text = "🤔"
                lblResult.backgroundColor = .tertiarySystemGroupedBackground
                lblResult.textColor = nil
            } else if let result = questionSuccessResult {
                if result {
                    lblResult.text = "Success"
                    lblResult.backgroundColor = .green
                    lblResult.textColor = nil
                } else {
                    lblResult.text = "Failed"
                    lblResult.backgroundColor = .systemPink
                    lblResult.textColor = .white
                }
            }
        }
    }
    
    private var firstrun: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewWebContainer.backgroundColor = UIColor(named: "OpaqueBackgroundColor")
        
        // button design
        btnSubmit.layer.cornerRadius = 10
        lblResult.layer.cornerRadius = 10
        
        webkitView = WKWebView(frame: CGRect(origin: .zero, size: viewWebContainer.frame.size))
        webkitView.isUserInteractionEnabled = false
        viewWebContainer.addSubview(webkitView)
        
        displayNextQuestionHandler = { [unowned self] newQuestion in
            self.displayName(question: newQuestion)
            
            let tempo = playbackConfigStore.tempo
            currentQuestion = newQuestion
            currentScaleInfoVM = SimpleScaleInfoViewModel(scaleInfo: newQuestion.scaleInfo, currentKey: newQuestion.key, currentTempo: tempo, currentEnharmonicMode: quizStore.enharmonicMode)
            currentEditViewModel = QuizEditKeyViewModel(scaleInfo: newQuestion.scaleInfo, key: newQuestion.key, order: newQuestion.isAscending ? .ascending : .descending, tempo: tempo)
            
            setPianoPosition(playableKey: newQuestion.key.playableKey)
            
            if firstrun {
                isSolvingQuestionNow = true
                initWebSheetPage(initAbcjsText: currentEditViewModel!.abcjsTextOnEdit)
                firstrun = false
                updateProgressViews(isBeforeSubmit: true)
            }
            
            refreshSheetView()
            updateProgressViews(isBeforeSubmit: true)
        }
        
        loadFirstQuestion()
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
        if !isSolvingQuestionNow, let result = questionSuccessResult {
            questionSuccessResult = nil
            isSolvingQuestionNow = true
            progressNextQuestion(result)
            return
        }
        
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
            injectAbcjsText(from: abcjsText, needReload: true)
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
            injectAbcjsText(from: currentEditViewModel.abcjsTextOnEdit, needReload: true)
            self.highlightLastNote()
        }
    }
    
    func displayName(question: QuizQuestion) {
        lblKeyName.text = "\(question.key) \(question.scaleInfo.name)"
        lblOrder.text = question.isAscending ? "Ascending" : "Descending"
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "QuizPianoSegue":
            pianoVC = segue.destination as? PianoViewController
            pianoVC?.parentContainerView = containerViewPiano
            pianoVC?.mode = .free
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
    func didKeyPressed(_ controller: PianoViewController, keyInfo: PianoKeyInfo) {
        guard isSolvingQuestionNow else {
            // print("isSolvingQuestionNow is false. Delegate processing refused.")
            return
        }
        guard let currentPlayableKey = currentPlayableKey else { return }
        guard let currentEditViewModel = currentEditViewModel else { return }
        let intNotation = keyInfo.keyIndex - PianoKeyHelper.findRootKeyPosition(playableKey: currentPlayableKey)
        
        print(currentPlayableKey, keyInfo, intNotation)
        currentEditViewModel.addKey(intNotation: intNotation, enharmonicMode: quizStore.enharmonicMode)
        
        injectAbcjsText(from: currentEditViewModel.abcjsTextOnEdit, needReload: true)
        highlightLastNote()
    }
}
