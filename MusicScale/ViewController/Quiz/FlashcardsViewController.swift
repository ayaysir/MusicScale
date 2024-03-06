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
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnRemind: UIButton!
    @IBOutlet weak var viewBannerContainer: UIView!
    @IBOutlet weak var cnstBannerHeight: NSLayoutConstraint!
    
    /// 앞면: 문제, 뒷면: 정답
    private var backAnswerLabel: UILabel!
    
    private var showingBack = false
    private let flipDuration = 0.5
    private var firstrun = true
    
    // var currentQuestion: QuizQuestion?
    var currentScaleInfoVM: SimpleScaleInfoViewModel?
    
    var prevDayQuestionPercent: Float = 0.0
    
    /// 문제 시작부터 정답까지 몇 초 걸렸는지 타이머
    private var timer: Timer?
    private var elapsedSeconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBannerAds(self, container: viewBannerContainer)
        
        // Override displayNextQuestionHandler
        displayNextQuestionHandler = { [unowned self] newQuestion in
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                self.elapsedSeconds += 1
            })
            
            if showingBack {
                flip(false)
            }
            
            self.backAnswerLabel.text = newQuestion.labelTitle
            let tempo = playbackConfigStore.tempo
            let scaleInfoVM = SimpleScaleInfoViewModel(scaleInfo: newQuestion.scaleInfo, currentKey: newQuestion.key, currentTempo: tempo, currentEnharmonicMode: quizStore.enharmonicMode)
            
            currentQuestion = newQuestion
            currentScaleInfoVM = scaleInfoVM
            
            let abcjsText = scaleInfoVM.abcjsTextForFlashcard(isAscending: newQuestion.isAscending)
            
            quizViewModel.incrementTryCount()
            
            if firstrun {
                initWebSheetPage(initAbcjsText: abcjsText)
                firstrun = false
                updateProgressViews(isBeforeSubmit: true)
                return
            }
                
            injectAbcjsText(from: abcjsText, needReload: true)
            updateProgressViews(isBeforeSubmit: true)
        }
        
        DispatchQueue.main.async { [self] in
            if !AdsManager.SHOW_AD {
                cnstBannerHeight.constant = 0
                viewBannerContainer.layoutIfNeeded()
            }
            
            cardContainerView.layoutIfNeeded()
            
            btnPlay.setTitle("", for: .normal)
            btnOK.layer.cornerRadius = btnOK.frame.size.width * 0.06
            btnRemind.layer.cornerRadius = btnRemind.frame.size.width * 0.06
            
            btnRemind.titleLabel?.adjustsFontSizeToFitWidth = true
            
            let cardRect = CGRect(origin: .zero, size: cardContainerView.frame.size)
            cardContainerView.backgroundColor = UIColor(named: "OpaqueBackgroundColor")
            cardContainerView.layer.borderWidth = 1.0
            cardContainerView.layer.borderColor = UIColor.systemGray3.cgColor
            
            webkitView = WKWebView(frame: cardRect)
            webkitView.isUserInteractionEnabled = false
            
            backAnswerLabel = UILabel(frame: cardRect)
            backAnswerLabel.textAlignment = .center
            backAnswerLabel.numberOfLines = 0
            if view.frame.width > 500 {
                let fontSize = view.frame.width * 0.07
                backAnswerLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
            } else {
                backAnswerLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
            }
            backAnswerLabel.adjustsFontSizeToFitWidth = true
            backAnswerLabel.lineBreakMode = .byWordWrapping
            
            // card flip
            backAnswerLabel.contentMode = .scaleAspectFill
            webkitView.contentMode = .scaleAspectFill
            
            cardContainerView.addSubview(webkitView)
            webkitView.translatesAutoresizingMaskIntoConstraints = false
            // lblCardText.spanSuperview()
            
            webkitView.layer.zPosition = -10

            loadFirstQuestion()
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(flipTrue))
        singleTap.numberOfTapsRequired = 1
        cardContainerView.addGestureRecognizer(singleTap)
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
        OrientationUtil.lockOrientation(.all)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { [unowned self] coordinator in
            view.layoutIfNeeded()
            let cardRect = CGRect(origin: .zero, size: cardContainerView.frame.size)
            webkitView.frame = cardRect
            backAnswerLabel.frame = cardRect
        }
    }
    
    func flip(_ animation: Bool = true) {
        guard let toView = showingBack ? webkitView : backAnswerLabel,
              let fromView = showingBack ? backAnswerLabel : webkitView else {
            return
        }
        
        UIView.transition(from: fromView, to: toView, duration: animation ? flipDuration : 0.01, options: .transitionFlipFromRight, completion: nil)
        
        toView.translatesAutoresizingMaskIntoConstraints = toView == backAnswerLabel
        
        // toView.spanSuperview()
        showingBack = !showingBack
    }
    
    @objc func flipTrue() {
        flip(true)
    }
    
    @IBAction func btnActRemindQuestion(_ sender: UIButton) {
        sendToRemind()
    }
    
    @IBAction func btnActSuccessQuestion(_ sender: UIButton) {
        sendToSuccess()
    }
    
    @IBAction func btnActPlay(_ sender: UIButton) {
        playOrStop()
    }
    
    func resetTimer() -> Int {
        timer?.invalidate()
        timer = nil
        let storedSeconds = self.elapsedSeconds
        self.elapsedSeconds = 0
        return storedSeconds
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
    
    private func sendToSuccess() {
        updateProgressViews(isBeforeSubmit: false)
        progressNextQuestion(true)
        stopSequencer()
        
        setQuizStatFromCurrentQuestion(true, elapsedSeconds: resetTimer())
        
        view.makeToast("Success! Let’s keep this momentum going!".localized(), duration: 1.6, position: .top)
    }
    
    private func sendToRemind() {
        updateProgressViews(isBeforeSubmit: false)
        progressNextQuestion(false)
        stopSequencer()
        
        setQuizStatFromCurrentQuestion(true, elapsedSeconds: resetTimer())
        
        view.makeToast("Again! Let's try harder!".localized(), duration: 1.6, position: .top)
    }
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
           let currentQuizQuestion = currentQuestion,
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

extension FlashcardsViewController {
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else {
            return
        }
        
        switch key.keyCode {
        case .keyboardSpacebar:
            playOrStop()
        case .keyboardReturnOrEnter:
            sendToSuccess()
        case .keyboardDeleteOrBackspace:
            sendToRemind()
        case .keyboardUpArrow, .keyboardDownArrow, .keyboardLeftArrow, .keyboardRightArrow:
            flipTrue()
        default:
            break
        }
    }
}
