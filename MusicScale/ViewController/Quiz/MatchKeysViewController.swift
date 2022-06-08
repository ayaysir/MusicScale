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
    @IBOutlet weak var lblQuizProgressInfo: UILabel!
    @IBOutlet weak var containerViewPiano: UIView!
    @IBOutlet weak var viewWebContainer: UIView!
    
    var pianoVC: PianoViewController?
    
    var currentPlayableKey: Music.PlayableKey?
    var currentEditViewModel: QuizEditKeyViewModel?
    
    private var firstrun: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewWebContainer.backgroundColor = UIColor(named: "OpaqueBackgroundColor")
        
        webkitView = WKWebView(frame: CGRect(origin: .zero, size: viewWebContainer.frame.size))
        webkitView.isUserInteractionEnabled = false
        viewWebContainer.addSubview(webkitView)
        
        displayNextQuestionHandler = { [unowned self] newQuestion in
            self.displayName(question: newQuestion)
            
            let tempo = playbackConfigStore.tempo
            let scaleInfoVM = SimpleScaleInfoViewModel(scaleInfo: newQuestion.scaleInfo, currentKey: newQuestion.key, currentTempo: tempo, currentEnharmonicMode: quizStore.enharmonicMode)
            
            currentEditViewModel = QuizEditKeyViewModel(scaleInfo: newQuestion.scaleInfo, key: newQuestion.key, order: newQuestion.isAscending ? .ascending : .descending)
            
            setPianoPosition(playableKey: newQuestion.key.playableKey)
            
            if firstrun {
                
                // currentQuizQuestion = newQuestion
                // currentScaleInfoVM = scaleInfoVM
                
                // let abcjsText = scaleInfoVM.abcjsTextForFlashcard(isAscending: newQuestion.isAscending)
                initWebSheetPage(initAbcjsText: currentEditViewModel!.abcjsTextOnEdit)
                firstrun = false
            }
            
            refreshSheetView()
        }
        
        loadFirstQuestion()
    }
    
    @IBAction func btnActSuccess(_ sender: Any) {
        progressNextQuestion(true)
    }
    
    @IBAction func btnActFailed(_ sender: Any) {
        progressNextQuestion(false)
    }
    
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
    
    // MARK: - Custom methods
    
    func refreshSheetView() {
        if let currentEditViewModel = currentEditViewModel {
            injectAbcjsText(from: currentEditViewModel.abcjsTextOnEdit, needReload: true)
            self.highlightLastNote()
        }
        
    }
    
    func displayName(question: QuizQuestion) {
        lblKeyName.text = "\(question.scaleInfo.name) : \(question.key) : \(question.isAscending ? "ASC" : "DESC")"
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

// MARK: - PianoVCDelegate
extension MatchKeysViewController: PianoVCDelegate {
    func didKeyPressed(_ controller: PianoViewController, keyInfo: PianoKeyInfo) {
        guard let currentPlayableKey = currentPlayableKey else { return }
        guard let currentEditViewModel = currentEditViewModel else { return }
        let intNotation = keyInfo.keyIndex - PianoKeyHelper.findRootKeyPosition(playableKey: currentPlayableKey)
        
        print(currentPlayableKey, keyInfo, intNotation)
        currentEditViewModel.addKey(intNotation: intNotation)
        
        injectAbcjsText(from: currentEditViewModel.abcjsTextOnEdit, needReload: true)
        highlightLastNote()
    }
}
