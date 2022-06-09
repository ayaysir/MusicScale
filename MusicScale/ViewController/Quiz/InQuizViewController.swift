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
    
    var quizViewModel: QuizViewModel!
    var displayNextQuestionHandler: DisplayHandler!
    var displayEndQuizHandler: Handler!
    var displayNilQuestionHandler: Handler!
    
    var webkitView: WKWebView!
    let conductor = NoteSequencerConductor()
    var playTimer: Timer?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conductor.start()
        
        displayNextQuestionHandler = { newQuestion in
            print(newQuestion)
        }
        
        displayEndQuizHandler = { [unowned self] in
            navigationItem.leftBarButtonItem?.title = ""
            navigationItem.leftBarButtonItem?.isEnabled = false
            
            simpleAlert(self, message: "End", title: "End") { action in
                self.quizViewModel.removeSavedLeitnerSystem()
                let introVC = initVCFromStoryboard(storyboardID: .QuizIntroTableViewController) as! QuizIntroTableViewController
                introVC.quizViewModel = self.quizViewModel
                self.navigationController?.setViewControllers([introVC], animated: true)
            }
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
    
    func initWebSheetPage(initAbcjsText: String) {
        
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
        
        injectAbcjsText(from: initAbcjsText, needReload: false)
        
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
    
    func injectAbcjsText(from abcjsText: String, needReload: Bool = true) {
        
        let abcjsTextFixed = charFixedAbcjsText(abcjsText)

        if needReload {
            stopTimer()
            webkitView.evaluateJavaScript(generateAbcJsInjectionSource(from: abcjsTextFixed))
        } else {
            let injectionSource = generateAbcJsInjectionSource(from: abcjsTextFixed)
            let injectionScript = WKUserScript(source: injectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            webkitView.configuration.userContentController.addUserScript(injectionScript)
        }
        
    }
}
