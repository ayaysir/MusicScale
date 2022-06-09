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
    private var backAnswerLabel: UILabel = UILabel()
    
    private var showingBack = false
    private let flipDuration = 0.5
    private var firstrun = true
    
    var currentQuizQuestion: QuizQuestion?
    var currentScaleInfoVM: SimpleScaleInfoViewModel?
    
    var prevDayQuestionPercent: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                updateProgressViews(isBeforeSubmit: true)
                return
            }
                
            injectAbcjsText(from: abcjsText, needReload: true)
            updateProgressViews(isBeforeSubmit: true)
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
        updateProgressViews(isBeforeSubmit: false)
        progressNextQuestion(false)
        stopSequencer()
    }
    
    @IBAction func btnActSuccessQuestion(_ sender: Any) {
        updateProgressViews(isBeforeSubmit: false)
        progressNextQuestion(true)
        stopSequencer()
    }
    
    @IBAction func btnActPlay(_ sender: UIButton) {
        playOrStop()
    }
    
    func updateProgressViews(isBeforeSubmit: Bool) {
        // day 0: 문제 진행 프로그레스
        // day 1~ : 완료한 문제 프로그레스
        let (isPhaseOne, percent) = quizViewModel.studyingProgress(isBeforeSubmit: isBeforeSubmit)
        if !isPhaseOne {
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

extension FlashcardsViewController: ConductorPlay {
    
    func playOrStop(playMode: PlayMode? = nil) {
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
        playTimer?.invalidate()
        
        btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func startSequencer(playMode: PlayMode? = nil) {
        stopSequencer()
        
        if let currentScaleInfoVM = currentScaleInfoVM,
           let currentQuizQuestion = currentQuizQuestion,
           let semitones = currentQuizQuestion.isAscending ? currentScaleInfoVM.playbackSemitoneAscending : currentScaleInfoVM.playbackSemitoneDescending
        {
            conductor.tempo = Float(currentScaleInfoVM.currentTempo)
            startTimer()
            self.conductor.addScaleToSequencer(semitones: semitones)
            self.conductor.isPlaying = true
            btnPlay.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            playTimer = Timer.scheduledTimer(timeInterval: currentScaleInfoVM.expectedPlayTime, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
        }
    }
}
