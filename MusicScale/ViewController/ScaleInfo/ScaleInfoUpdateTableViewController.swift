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
    func didFinishedCreate(_ controller: ScaleInfoUpdateTableViewController, entity: ScaleInfoEntity)
}

extension ScaleInfoUpdateTVCDelegate {
    func didFinishedUpdate(_ controller: ScaleInfoUpdateTableViewController, viewModel: ScaleInfoViewModel) {}
    func didFinishedCreate(_ controller: ScaleInfoUpdateTableViewController, entity: ScaleInfoEntity) {}
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
    @IBOutlet weak var segAscDesc: UISegmentedControl!
    
    @IBOutlet weak var swtActivateDesc: UISwitch!
    
    @IBOutlet weak var lblCautionAscAndDescDiff: UILabel!
    
    @IBOutlet weak var cosmosDefaultPriority: CosmosView!
    
    weak var updateDelegate: ScaleInfoUpdateTVCDelegate?
    weak var createDelegate: ScaleInfoUpdateTVCDelegate?
    
    var mode: SubmitMode = .update
    var infoViewModel: ScaleInfoViewModel?
    var degreesViewModel: ScaleDegreesUpdateViewModel!
    
    // var defaultPriority = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ===== 공통 작업 =====
        loadWebSheetPage()
        txfScaleName.addTarget(self, action: #selector(scaleNameChanged), for: .editingChanged)
        
        // cosmosDefaultPriority.didFinishTouchingCosmos = {
        //     rating in
        //     print(rating)
        //     self.defaultPriority = Int(rating)
        // }
        
        // ===== 분기별 작업 =====
        switch mode {
        case .create:
            
            cosmosDefaultPriority.rating = 3.0
            
            degreesViewModel = ScaleDegreesUpdateViewModel()
            injectAbcjsText(from: degreesViewModel.abcjsTextOnEditDegreesAsc, needReload: false)
            
        case .update:
            guard let infoViewModel = infoViewModel else {
                return
            }
            
            cosmosDefaultPriority.rating = Double(infoViewModel.defaultPriority)

            txfScaleName.text = infoViewModel.name
            txvScaleAliases.text = infoViewModel.nameAliasFormatted
            txvComment.text = infoViewModel.comment
            
            print(infoViewModel.entity)
            
            // 편집용
            degreesViewModel = ScaleDegreesUpdateViewModel(ascDegrees: infoViewModel.degreesAscending, descDegrees: infoViewModel.degreesDescending)
            degreesViewModel.setScaleName(infoViewModel.name)
            if infoViewModel.degreesDescending != "" && infoViewModel.degreesDescending != infoViewModel.degreesAscending {
                swtActivateDesc.isOn = true
                segAscDesc.isEnabled = true
            }
            
            print(degreesViewModel.onEditDegreesDesc)
        }
    }
    
    // MARK: - @objc
    
    @objc func scaleNameChanged(_ textField: UITextField) {
        webView.evaluateJavaScript("""
        document.querySelector(".abcjs-meta-top tspan").textContent = "C \(textField.text!)"
        """)
    }
    
    // MARK: - @IBAction
    
    @IBAction func swtActEnableDescending(_ sender: UISwitch) {
        if sender.isOn {
            segAscDesc.isEnabled = true
        } else {
            segAscDesc.selectedSegmentIndex = 0
            segAscDesc.isEnabled = false
        }
    }
    
    @IBAction func segActAscDesc(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            injectAbcjsText(from: degreesViewModel.abcjsTextOnEditDegreesAsc, needReload: true)
        case 1:
            injectAbcjsText(from: degreesViewModel.abcjsTextOnEditDegreesDesc, needReload: true)
        default:
            break
        }
    }
    
    @IBAction func btnActInputNumber(_ sender: UIButton) {
        
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
        
        degreesViewModel.setScaleName(txfScaleName.text ?? "")
        let order: DegreesOrder = segAscDesc.selectedSegmentIndex == 0 ? .ascending : .descending
        
        if (order == .ascending ? degreesViewModel.onEditDegreesAsc : degreesViewModel.onEditDegreesDesc).count > 20 {
            self.tableView.makeToast("⚠️ degreesViewModel.onEditDegreesAsc.count must be 20 or less.", position: .center)
            return
        }
        
        // 오름차순(내림차순) 순으로 되어있는지 확인: 각 degree 별 semitone 확인해서 크거나 작은 값은 입력 못하게
        if let prevDegree = order == .ascending
            ? degreesViewModel.onEditDegreesAsc.last
            : degreesViewModel.onEditDegreesDesc.last
        {
            let prevInteger = degreesViewModel.getInteger(degree: prevDegree)
            let currInteger = degreesViewModel.getInteger(degree: degreeText)
            
            let prevNumPair = degreesViewModel.getNumPair(degree: prevDegree)
            let currNumPair = degreesViewModel.getNumPair(degree: degreeText)
            
            let isNoteOrderWrong = order == .ascending ? (prevInteger > currInteger) : (prevInteger < currInteger)
            let wrongNoteOrderMessage = order == .ascending
            ? "⚠️ ASC: prevInteger must be less than currInteger."
            : "⚠️ DESC: prevInteger must be greater than currInteger."
            
            let pairHasTargetPrefix = order == .ascending
            ? (prevNumPair.prefix == "_" || prevNumPair.prefix == "__")
            : (prevNumPair.prefix == "^" || prevNumPair.prefix == "^^")
            
            if isNoteOrderWrong {
                self.tableView.makeToast(wrongNoteOrderMessage, position: .center)
                return
            }
            
            if pairHasTargetPrefix && prevNumPair.number == currNumPair.number && currNumPair.prefix == "" {
                degreeText = Music.Accidental.natural.textValue + degreeText
            }
        }
        
        switch order {
        case .ascending:
            degreesViewModel.onEditDegreesAsc.append(degreeText)
            injectAbcjsText(from: degreesViewModel.abcjsTextOnEditDegreesAsc, needReload: true)
        case .descending:
            degreesViewModel.onEditDegreesDesc.append(degreeText)
            injectAbcjsText(from: degreesViewModel.abcjsTextOnEditDegreesDesc, needReload: true)
        }
        
        highlightLastNote()
        
        /**
         버튼 누를때마다
         - 오름차순(내림차순) 순으로 되어있는지 확인: 각 degree 별 semitone 확인해서 크거나 작은 값은 입력 못하게
         - 앞에 기호(플랫:오름차순;샤프:내림차순) 있을 때 Default를 입력한다면 자동으로 natural 붙게
         - 악보 업데이트
         */
    }
    
    @IBAction func btnActBackspaceNote(_ sender: UIButton) {
        
        degreesViewModel.setScaleName(txfScaleName.text ?? "")
        
        let order: DegreesOrder = segAscDesc.selectedSegmentIndex == 0 ? .ascending : .descending
        switch order {
        case .ascending:
            _ = degreesViewModel.onEditDegreesAsc.popLast()
            injectAbcjsText(from: degreesViewModel.abcjsTextOnEditDegreesAsc, needReload: true)
        case .descending:
            _ = degreesViewModel.onEditDegreesDesc.popLast()
            injectAbcjsText(from: degreesViewModel.abcjsTextOnEditDegreesDesc, needReload: true)
        }
        
        highlightLastNote()
    }
    
    
    @IBAction func barBtnActSubmit(_ sender: UIBarButtonItem) {
        
        // Degrees 유효성 검사
        // ASC: 반드시 1로 시작
        // DESC: 반드시 1로 끝남
        
        let isDescEnabled = swtActivateDesc.isOn
        let degreeNaturalOne = "\(Music.Accidental.natural.textValue)1"
        
        // ===== 유효성 검사 =====
        //ASC: 반드시 1로 시작
        guard degreesViewModel.onEditDegreesAsc.first == "1" || degreesViewModel.onEditDegreesAsc.first == degreeNaturalOne else {
            print("ASC: 반드시 1로 시작")
            return
        }
        
        // DESC: 반드시 1로 끝남
        if isDescEnabled {
            guard degreesViewModel.onEditDegreesDesc.last == "1" || degreesViewModel.onEditDegreesDesc.last == degreeNaturalOne else {
                print("DESC: 반드시 1로 끝남")
                return
            }
        }
        
        // txfScaleName: 50자 정도 초과 못하게
        guard let scaleName = txfScaleName.text,
              scaleName.count >= 2 && scaleName.count <= 50 else {
            return
        }
        
        // rating: 1 ~ 5
        let ratingInt = Int(cosmosDefaultPriority.rating)
        guard ratingInt.between(1...5) else {
            return
        }
        
        // txfComment: 2000자 부근까지
        guard let comment = txvComment.text, comment.count <= 2000 else {
            return
        }
        
        // ===== 공통 작업 =====
        
        // ===== 분기별 작업 =====
        switch mode {
        case .create:
            
            let degreesAscending = degreesViewModel.degreesAsc
            let degreesDescending = isDescEnabled ? degreesViewModel.degreesDesc : ""
            
            // ScaleInfo 생성
            let createdInfo = ScaleInfo(id: UUID(),
                                        name: scaleName,
                                        nameAlias: convertScaleAliases(),
                                        degreesAscending: degreesAscending,
                                        degreesDescending: degreesDescending,
                                        defaultPriority: ratingInt,
                                        comment: comment,
                                        links: "",
                                        isDivBy12Tet: true,
                                        displayOrder: 1,
                                        myPriority: 0,
                                        createdDate: Date(),
                                        modifiedDate: Date(),
                                        groupName: "")
            
            do {
                let entity = try ScaleInfoCDService.shared.saveCoreData(scaleInfo: createdInfo)
                createDelegate?.didFinishedCreate(self, entity: entity)
                navigationController?.popViewController(animated: true)
            } catch {
                print("error: create failed:", error)
            }
        case .update:
            guard let infoViewModel = infoViewModel else {
                return
            }
            
            let entity = infoViewModel.entity
            entity.name = scaleName
            entity.nameAlias = convertScaleAliases()
            entity.comment = comment
            entity.degreesAscending = degreesViewModel.degreesAsc
            
            // 기본 별점 변경
            entity.defaultPriority = Int16(cosmosDefaultPriority.rating)
            

            if isDescEnabled {
                entity.degreesDescending = degreesViewModel.degreesDesc
            } else {
                entity.degreesDescending = ""
            }
            
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

extension ScaleInfoUpdateTableViewController {
    
    func convertScaleAliases() -> String {
        // let filtered = txvScaleAliases.text.range(of: "[^\n]+(\n)", options: .regularExpression)
        let aliasComponents = txvScaleAliases.text.components(separatedBy: "\n")
        return aliasComponents.filter { $0 != "" }.joined(separator: ";")
        // print(entity.nameAlias!)
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
    
    func highlightLastNote() {
        
        if mode == .create && degreesViewModel == nil {
            return
        }
        
        var cursorIndex: Int {
            switch segAscDesc.selectedSegmentIndex {
            case 0:
                return degreesViewModel.onEditDegreesAsc.count - 1
            case 1:
                return degreesViewModel.onEditDegreesDesc.count - 1
            default:
                return -99
            }
        }
        
        guard cursorIndex >= 0 else {
            return
        }
        
        webView.evaluateJavaScript("""
        document.querySelector(".abcjs-n\(cursorIndex)").classList.add("abcjs-highlight");
        """)
        // { result, error in
        //     print(result)
        //     print(error)
        // }
        
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
            // degreesViewModel이 로딩이 안된 상태이므로 viewDidLoad에서 실행
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        highlightLastNote()
    }
    
}
