//
//  FlashcardsViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/07.
//

import UIKit
import WebKit

class FlashcardsViewController: InQuizViewController {
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var progressViewInStudying: UIProgressView!
    @IBOutlet weak var progressViewDayQuestionProgress: UIProgressView!
    @IBOutlet weak var lblProgressStatus: UILabel!
    
    // 앞면: 문제, 뒷면: 정답
    // private var frontSheetView: WKWebView = WKWebView()
    private var backAnswerLabel: UILabel = UILabel()
    
    private var showingBack = false
    private let flipDuration = 0.5
    private var firstrun = true
    
    let conductor = NoteSequencerConductor()
    var playTimer: Timer?
    var currentQuizQuestion: QuizQuestion?
    var currentScaleInfoVM: SimpleScaleInfoViewModel?
    
    var prevDayQuestionPercent: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conductor.start()
        btnPlay.setTitle("", for: .normal)
        
        let cardRect = CGRect(origin: .zero, size: cardContainerView.frame.size)
        cardContainerView.backgroundColor = UIColor(named: "OpaqueBackgroundColor")
        
        webkitView = WKWebView(frame: cardRect)
        webkitView.isUserInteractionEnabled = false
        // frontSheetView = WKWebView(frame: cardRect)
        // frontSheetView.isUserInteractionEnabled = false
        
        backAnswerLabel = UILabel(frame: cardRect)
        backAnswerLabel.textAlignment = .center
        
        displayNextQuestionHandler = { [unowned self] newQuestion in
            if showingBack {
                flip()
            }
            
            self.backAnswerLabel.text = newQuestion.labelTitle
            let tempo = playbackConfigStore.tempo
            let scaleInfoVM = SimpleScaleInfoViewModel(scaleInfo: newQuestion.scaleInfo, currentKey: newQuestion.key, currentTempo: tempo, currentEnharmonicMode: quizStore.enharmonicMode)
            
            currentQuizQuestion = newQuestion
            currentScaleInfoVM = scaleInfoVM
            
            let abcjsText = scaleInfoVM.abcjsTextForFlashcard(isAscending: newQuestion.isAscending)
            
            if firstrun {
                initWebSheetPage(initAbcjsText: abcjsText)
                firstrun = false
                
                // progressViewInStudying.setProgress(quizViewModel.studyingProgress.percent, animated: false)
                updateProgressViews()
                return
            }
                
            injectAbcjsText(from: abcjsText, needReload: true)
            updateProgressViews()
        }

        loadFirstQuestion()
        
        // card flip
        backAnswerLabel.contentMode = .scaleAspectFill
        webkitView.contentMode = .scaleAspectFill
        
        cardContainerView.addSubview(webkitView)
        webkitView.translatesAutoresizingMaskIntoConstraints = false
        // lblCardText.spanSuperview()
        
        webkitView.layer.zPosition = -10
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip))
        singleTap.numberOfTapsRequired = 1
        cardContainerView.addGestureRecognizer(singleTap)
    }
    
    @objc func flip() {
        guard let toView = showingBack ? webkitView : backAnswerLabel,
              let fromView = showingBack ? backAnswerLabel : webkitView else {
            return
        }
        
        UIView.transition(from: fromView, to: toView, duration: flipDuration, options: .transitionFlipFromRight, completion: nil)
        toView.translatesAutoresizingMaskIntoConstraints = false
        
        // toView.spanSuperview()
        showingBack = !showingBack
    }
    
    @IBAction func btnActRemindQuestion(_ sender: Any) {
        progressNextQuestion(false)
        stopSequencer()
        // updateProgressViews()
    }
    
    @IBAction func btnActSuccessQuestion(_ sender: Any) {
        progressNextQuestion(true)
        stopSequencer()
        // updateProgressViews()
    }
    
    @IBAction func btnActPlay(_ sender: UIButton) {
        if conductor.sequencer.isPlaying {
            stopSequencer()
            return
        }
        startSequencer()
    }
    
    @objc func stopSequencer() {
        stopTimer()
        conductor.sequencer.stop()
        conductor.sequencer.rewind()
        conductor.isPlaying = false
        btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        playTimer?.invalidate()
    }
    
    func startSequencer() {
        stopSequencer()
        
        if let currentScaleInfoVM = currentScaleInfoVM,
           let currentQuizQuestion = currentQuizQuestion,
           let semitones = currentQuizQuestion.isAscending ? currentScaleInfoVM.playbackSemitoneAscending : currentScaleInfoVM.playbackSemitoneDescending
        {
            conductor.tempo = Float(currentScaleInfoVM.currentTempo)
            startTimer()
            self.conductor.addScaleToSequencer(semintones: semitones)
            self.conductor.isPlaying = true
            btnPlay.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            playTimer = Timer.scheduledTimer(timeInterval: currentScaleInfoVM.expectedPlayTime, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
        }
        
    }
    
    func updateProgressViews() {
        // day 0: 문제 진행 프로그레스
        // day 1~ : 완료한 문제 프로그레스
        let (isPhaseOne, percent) = quizViewModel.studyingProgress
        if !isPhaseOne {
            // ??
            changeProgressViewColor(isPhaseOne: isPhaseOne)
        }
        progressViewInStudying.setProgress(percent, animated: true)
        
        let dayQuestionPercent = quizViewModel.dayQuestionProgress
        let animateDayQuestion = prevDayQuestionPercent != 1.0
        if animateDayQuestion {
            progressViewDayQuestionProgress.setProgress(dayQuestionPercent, animated: true)
        } else {
            progressViewDayQuestionProgress.setProgress(0.0, animated: false)
            progressViewDayQuestionProgress.setProgress(dayQuestionPercent, animated: true)
        }
        
        lblProgressStatus.text = quizViewModel.quizStatus
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// extension FlashcardsViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
//     func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//         switch message.name {
//         // ... //
//         case "logHandler":
//             print("console log:", message.body)
//         // case "notePlayback":
//         //     let status = message.body as! String
//         //     if let delegate = delegate {
//         //         if status == "play" {
//         //             delegate.didStartButtonClicked(self)
//         //         } else if status == "stop" {
//         //             delegate.didStopButtonClicked(self)
//         //         }
//         //     }
//         default:
//             break
//         }
//     }
//
//     func initWebSheetPage(initAbcjsText: String) {
//
//         if #available(iOS 14.0, *) {
//             frontSheetView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
//         } else {
//             // Fallback on earlier versions
//             frontSheetView.configuration.preferences.javaScriptEnabled = true
//         }
//
//         // 웹 파일 로딩
//         frontSheetView.uiDelegate = self
//         frontSheetView.navigationDelegate = self
//         let pageName = "index"
//         guard let url = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "web") else {
//             return
//         }
//         frontSheetView.loadFileURL(url, allowingReadAccessTo: url)
//         frontSheetView.scrollView.isScrollEnabled = false
//
//         injectAbcjsText(from: initAbcjsText, needReload: false)
//
//         // 자바스크립트 -> 네이티브 앱 연결
//         // 브리지 등록
//         frontSheetView.configuration.userContentController.add(self, name: "notePlayback")
//
//         // inject JS to capture console.log output and send to iOS
//         let source = """
//             function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); }
//             window.console.log = captureLog;
//         """
//         let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
//         frontSheetView.configuration.userContentController.addUserScript(script)
//         // register the bridge script that listens for the output
//         frontSheetView.configuration.userContentController.add(self, name: "logHandler")
//
//     }
// }
//
// extension FlashcardsViewController: ScoreWebInjection {
//
//     func startTimer() {
//         frontSheetView.evaluateJavaScript("startTimer()")
//     }
//
//     func stopTimer() {
//         frontSheetView.evaluateJavaScript("stopTimer()")
//     }
//
//     func injectAbcjsText(from abcjsText: String, needReload: Bool = true) {
//
//         let abcjsTextFixed = charFixedAbcjsText(abcjsText)
//
//         if needReload {
//             stopTimer()
//             frontSheetView.evaluateJavaScript(generateAbcJsInjectionSource(from: abcjsTextFixed))
//         } else {
//             let injectionSource = generateAbcJsInjectionSource(from: abcjsTextFixed)
//             let injectionScript = WKUserScript(source: injectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//             frontSheetView.configuration.userContentController.addUserScript(injectionScript)
//         }
//
//     }
// }
