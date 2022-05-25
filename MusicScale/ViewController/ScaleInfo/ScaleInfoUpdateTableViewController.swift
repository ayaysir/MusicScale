//
//  ScaleInfoUpdate.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/24.
//

import UIKit
import WebKit

protocol ScaleInfoUpdateTVCDelegate: AnyObject {
    func didFinishedUpdate(_ controller: ScaleInfoUpdateTableViewController, viewModel: ScaleInfoViewModel)
}

class ScaleInfoUpdateTableViewController: UITableViewController {
    
    enum SubmitMode {
        case create, update
    }
    
    @IBOutlet weak var txfScaleName: UITextField!
    @IBOutlet weak var txvScaleAliases: UITextView!
    @IBOutlet weak var txvComment: UITextView!
    @IBOutlet weak var barBtnSubmit: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var segAccidental: UISegmentedControl!
    
    @IBOutlet weak var lblCautionAscAndDescDiff: UILabel!
    
    weak var updateDelegate: ScaleInfoUpdateTVCDelegate?
    
    var mode: SubmitMode = .update
    var infoViewModel: ScaleInfoViewModel?
    var degreesViewModel: ScaleDegreesUpdateViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ===== 공통 작업 =====
        loadWebSheetPage()
        lblCautionAscAndDescDiff.text = ""
        txfScaleName.addTarget(self, action: #selector(scaleNameChanged), for: .editingChanged)
        
        // ===== 분기별 작업 =====
        switch mode {
        case .create:
            break
        case .update:
            guard let infoViewModel = infoViewModel else {
                return
            }

            txfScaleName.text = infoViewModel.name
            txvScaleAliases.text = infoViewModel.nameAliasFormatted
            txvComment.text = infoViewModel.comment
            
            print(infoViewModel.entity)
            
            // 편집용
            degreesViewModel = ScaleDegreesUpdateViewModel(ascDegrees: infoViewModel.degreesAscending, descDegrees: infoViewModel.degreesDescending)
        }
    }
    
    // MARK: - @objc
    @objc func scaleNameChanged(_ textField: UITextField) {
        webView.evaluateJavaScript("""
        document.querySelector(".abcjs-meta-top tspan").textContent = "C \(textField.text!)"
        """)
    }
    
    // MARK: - @IBAction
    @IBAction func btnActInputNumber(_ sender: UIButton) {
        print(#function, sender.tag)
        var degreeText = ""
        switch segAccidental.selectedSegmentIndex {
        case 0:
            degreeText = ""
        case 1:
            degreeText = Music.Accidental.sharp.textValue
        case 2:
            degreeText = Music.Accidental.flat.textValue
        case 3:
            degreeText = Music.Accidental.natural.textValue
        default:
            break
        }
        
        degreeText += "\(sender.tag)"
        degreesViewModel.onEditDegreesAsc.append(degreeText)
        lblCautionAscAndDescDiff.text! = degreesViewModel.degreesAsc
        
        /**
         버튼 누를때마다
         - 오름차순(내림차순) 순으로 되어있는지 확인: 각 degree 별 semitone 확인해서 크거나 작은 값은 입력 못하게
         - 앞에 기호(플랫:오름차순;샤프:내림차순) 있을 때 Default를 입력한다면 자동으로 natural 붙게
         - 악보 업데이트
         */
    }
    
    @IBAction func btnActBackspaceNote(_ sender: UIButton) {
        print(#function)
        // lblCautionAscAndDescDiff.text!.remove(at: lblCautionAscAndDescDiff.text!.index(before: lblCautionAscAndDescDiff.text!.endIndex))
        _ = degreesViewModel.onEditDegreesAsc.popLast()
        lblCautionAscAndDescDiff.text! = degreesViewModel.degreesAsc
    }
    
    
    @IBAction func barBtnActSubmit(_ sender: UIBarButtonItem) {
        // ===== 공통 작업 =====
        
        // ===== 분기별 작업 =====
        switch mode {
        case .create:
            break
        case .update:
            guard let infoViewModel = infoViewModel else {
                return
            }
            
            let entity = infoViewModel.entity
            entity.name = txfScaleName.text
            
            // let filtered = txvScaleAliases.text.range(of: "[^\n]+(\n)", options: .regularExpression)
            let aliasComponents = txvScaleAliases.text.components(separatedBy: "\n")
            entity.nameAlias = aliasComponents.filter { $0 != "" }.joined(separator: ";")
            print(entity.nameAlias!)
            entity.comment = txvComment.text
            
            do {
                try ScaleInfoCDService.shared.saveManagedContext()
            
                infoViewModel.reloadInfoFromEntity()
                updateDelegate?.didFinishedUpdate(self, viewModel: infoViewModel)
                navigationController?.popViewController(animated: true)
            
            } catch {
                print("error: update failed:", error)
            }
        }
    }
    
}

extension ScaleInfoUpdateTableViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, ScoreWebInjection {
    
    func startTimer() {
        webView.evaluateJavaScript("startTimer()")
    }
    
    func stopTimer() {
        webView.evaluateJavaScript("stopTimer()")
    }
    
    func injectAbcjsText(from abcjsText: String, needReload: Bool) {
        
        let abcjsTextFixed = charFixedAbcjsText(abcjsText)
        
        if needReload {
            stopTimer()
            webView.evaluateJavaScript(generateAbcJsInjectionSource(from: abcjsTextFixed))
        } else {
            let injectionSource = generateAbcJsInjectionSource(from: abcjsTextFixed)
            let injectionScript = WKUserScript(source: injectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(injectionScript)
        }
    }
    
    func loadWebSheetPage() {

        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
            webView.configuration.preferences.javaScriptEnabled = true
        }
        
        // 웹 파일 로딩
        // ===== 공통 작업 =====
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let pageName = "index"
        guard let url = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "web") else {
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url)
        webView.scrollView.isScrollEnabled = false
        
        // ===== 분기별 작업 =====
        switch mode {
        case .create:
            break
        case .update:
            let abcjsText = infoViewModel!.abcjsTextForEditAsc
            injectAbcjsText(from: abcjsText, needReload: false)
            
        }
        
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
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        // ... //
        case "logHandler":
            print("console log:", message.body)
        default:
            break
        }
    }
    
    
}
