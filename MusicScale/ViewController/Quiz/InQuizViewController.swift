//
//  InQuizViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/07.
//

import UIKit
import WebKit

enum PlayMode {
  case onEdit, answer, together
}

protocol ConductorPlay {
  func playOrStop(playMode: PlayMode?)
  func startSequencer(playMode: PlayMode?)
  func stopSequencer()
}

/**
 - quizViewModel
 - displayNextQuestionHandler
 - displayEndQuizHandler
 - displayNilQuestionHandler
 - loadFirstQuestion(_:)
 */
class InQuizViewController: UIViewController {
  
  typealias DisplayHandler = (_ newQuestion: QuizQuestion) -> ()
  typealias Handler = () -> ()
  
  let quizStore = QuizConfigStore.shared
  let playbackConfigStore = ScaleInfoVCConfigStore.shared
  let quizStatService = QuizStatsCDService.shared
  
  var quizViewModel: QuizViewModel!
  var displayNextQuestionHandler: DisplayHandler!
  var displayEndQuizHandler: Handler!
  var displayNilQuestionHandler: Handler!
  
  var webkitView: WKWebView!
  // let conductor = NoteSequencerConductor()
  let conductor = GlobalConductor.shared
  var playTimer: Timer?
  
  var currentQuestion: QuizQuestion?
  var currentQuizStatEntity: QuizStatEntity?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    TrackingTransparencyPermissionRequest()
    
    displayNextQuestionHandler = { newQuestion in
      print(newQuestion)
      self.quizViewModel.incrementTryCount()
    }
    
    displayEndQuizHandler = { [unowned self] in
      // Move to FinishedVC
      let finishedVC = initVCFromStoryboard(storyboardID: .QuizFinishedViewController) as! QuizFinishedViewController
      finishedVC.quizViewModel = self.quizViewModel
      self.navigationController?.setViewControllers([finishedVC], animated: true)
    }
    
    displayNilQuestionHandler = {
      simpleAlert(self, message: "Error")
    }
  }
  
  func loadFirstQuestion() {
    // 최초 질문 불러오기
    if !quizViewModel.isAllQuestionFinished {
      displayNextQuestionHandler(quizViewModel.currentQuestion!)
    }
  }
  
  func progressNextQuestion(_ isCurrentSuccess: Bool) {
    
    guard let newQuestion = quizViewModel.submitResultAndGetNextQuestion(currentSuccess: isCurrentSuccess) else {
      if quizViewModel.isAllQuestionFinished {
        displayEndQuizHandler()
        return
      }
      displayNilQuestionHandler()
      return
    }
    
    displayNextQuestionHandler(newQuestion)
  }
  
  /// 통계 기록: 다음 진행 버튼을 누르는 시점에 (progressNextQuestion 직전) / isAnsweredCorrectly, elapsedSeconds, studyStatus
  private func updateQuizStat(currentQuestion: QuizQuestion) {
    // add stats info
    
    let scaleName = currentQuestion.scaleInfo.name
    let key = currentQuestion.key.rawValue
    let order = currentQuestion.isAscending ? "ascending" : "descending"
    let typeOfQuestion = quizViewModel.currentType.identifier
    let isAnsweredCorrectly = false // 알 수 없음
    let solveDate = Date()
    let elapsedSeconds: Int16 = 0 // 알 수 없음
    let studyStatus = "" // 알 수 없음
    
    do {
      currentQuizStatEntity = try quizStatService.createQuizStatEntity(
        scaleName: scaleName,
        key: key,
        order: order,
        typeOfQuestion: typeOfQuestion,
        isAnsweredCorrectly: isAnsweredCorrectly,
        solveDate: solveDate,
        elapsedSeconds: elapsedSeconds,
        studyStatus: studyStatus
      )
    } catch {
      print(error)
    }
  }
  
  func setQuizStatFromCurrentQuestion(_ isSuccess: Bool, elapsedSeconds: Int) {
    guard let currentQuizQuestion = currentQuestion else {
      return
    }
    
    updateQuizStat(currentQuestion: currentQuizQuestion)
    currentQuizStatEntity?.isAnsweredCorrectly = isSuccess
    
    currentQuizStatEntity?.elapsedSeconds = Int16(elapsedSeconds)
    currentQuizStatEntity?.studyStatus = String(quizViewModel.leitnerSystem.getCurrentQuestionStatus()?.boxNumber ?? -99)
    
    do {
      try quizStatService.saveManagedContext()
    } catch {
      print(error)
    }
  }
}

extension InQuizViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    switch message.name {
    case "logHandler":
      print("console log:", message.body)
    default:
      break
    }
  }
  
  func initWebSheetPage(initAbcjsText: String, staffWidth: Int? = DEF_STAFFWIDTH) {
    
    if #available(iOS 14.0, *) {
      webkitView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    } else {
      // Fallback on earlier versions
      webkitView.configuration.preferences.javaScriptEnabled = true
    }
    
    // 웹 파일 로딩
    webkitView.uiDelegate = self
    webkitView.navigationDelegate = self
    let pageName = "index"
    guard let url = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "web") else {
      return
    }
    webkitView.loadFileURL(url, allowingReadAccessTo: url)
    webkitView.scrollView.isScrollEnabled = false
    
    injectAbcjsText(from: initAbcjsText, needReload: false, staffWidth: staffWidth)
    
    // 자바스크립트 -> 네이티브 앱 연결
    // 브리지 등록
    webkitView.configuration.userContentController.add(self, name: "notePlayback")
    
    // inject JS to capture console.log output and send to iOS
    let source = """
            function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); }
            window.console.log = captureLog;
        """
    let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    webkitView.configuration.userContentController.addUserScript(script)
    // register the bridge script that listens for the output
    webkitView.configuration.userContentController.add(self, name: "logHandler")
    
  }
}

extension InQuizViewController: ScoreWebInjection {
  
  func startTimer() {
    webkitView.evaluateJavaScript("startTimer()")
  }
  
  func stopTimer() {
    webkitView.evaluateJavaScript("stopTimer()")
  }
  
  func injectAbcjsText(from abcjsText: String, needReload: Bool = true, staffWidth: Int? = DEF_STAFFWIDTH) {
    
    let abcjsTextFixed = charFixedAbcjsText(abcjsText)
    
    if needReload {
      stopTimer()
      webkitView.evaluateJavaScript(generateAbcJsInjectionSource(from: abcjsTextFixed, staffWidth: staffWidth))
    } else {
      let injectionSource = generateAbcJsInjectionSource(from: abcjsTextFixed, staffWidth: staffWidth)
      let injectionScript = WKUserScript(source: injectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
      webkitView.configuration.userContentController.addUserScript(injectionScript)
    }
  }
}
