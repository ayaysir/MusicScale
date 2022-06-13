//
//  ArchiveDetailTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import UIKit
import WebKit

class ArchiveDetailTableViewController: UITableViewController {
    
    enum CRUDMode {
        case read, create
    }
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnDislike: UIButton!
    @IBOutlet weak var btnSelectScale: UIButton!
    
    @IBOutlet weak var lblAscAndDescIsSame: UILabel!
    @IBOutlet weak var segAscDesc: UISegmentedControl!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAlias: UILabel!
    @IBOutlet weak var lblIntNotation: UILabel!
    @IBOutlet weak var lblPattern: UILabel!
    @IBOutlet weak var lblPriority: UILabel!
    @IBOutlet weak var txvComment: UITextView!
    
    @IBOutlet weak var lblUploader: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblUpdatedDate: UILabel!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var lblDownloadCount: UILabel!
    
    @IBOutlet weak var barBtnDownloadOr: UIBarButtonItem!
    @IBOutlet weak var barBtnDeleteOr: UIBarButtonItem!
    
    private let starRatingVM = StarRatingViewModel()
    
    private let conductor = NoteSequencerConductor()
    private var playTimer: Timer?
    private let playbackTempo: Float = 120.0
    
    var currentInfoVM: SimpleScaleInfoViewModel? {
        switch mode {
        case .read:
            return infoViewModelForCreateMode
        case .create:
            return infoViewModelForCreateMode
        }
    }
    
    var currentOrder: DegreesOrder {
        return segAscDesc.selectedSegmentIndex == 0 ? .ascending : .descending
    }
    
    var postViewModel: Any = ""
    private var infoViewModelForCreateMode: ScaleInfoViewModel! {
        didSet {
            if isMode(.create) {
                setLabelsFromInfoVM()
            }
        }
    }
    
    var mode: CRUDMode = .read
    func isMode(_ mode: CRUDMode) -> Bool {
        return self.mode == mode
    }
    
    private let SECTION_FIRST = 0
    private let SECTION_PREVIEW = 1
    private let SECTION_INFO = 2
    private let SECTION_RELIABILITY = 3
    private let SECTION_COMMENT = 4
    private let SECTION_METADATA = 5
    
    private let cellAliasIndexPath = IndexPath(row: 1, section: 2)
    private let cellCommentIndexPath = IndexPath(row: 0, section: 4)
    
    private var selectedSomeScale: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var originalCommentWidth: CGFloat!
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        switch mode {
        case .read:
            break
        case .create:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 공통
        setButtonTitle()
        btnSelectScale.isHidden = isMode(.read)
        originalCommentWidth = txvComment.frame.size.width
        loadWebSheetPage()
        conductor.start()
        conductor.tempo = playbackTempo
        
        // 분기
        switch mode {
        case .read:
            break
        case .create:
            
            setButtonTitleForCreateMode()
            
            lblUploader.text = "Anonymous (\(FirebaseAuthManager.shared.currentUser?.uid[0..<4] ?? ""))"
        }
    }
    
    // MARK: - set initial design
    
    func setButtonTitle() {
        btnPlay.setTitle("", for: .normal)
        btnLike.setTitle("", for: .normal)
        btnDislike.setTitle("", for: .normal)
    }
    
    func setButtonTitleForCreateMode() {
        barBtnDeleteOr.title = ""
        barBtnDeleteOr.isEnabled = false
        
        barBtnDownloadOr.title = "Submit"
    }
    
    func setButtonTitleForReadMode() {
        
    }
    
    // MARK: - @IBAction
    
    @IBAction func segActAscDesc(_ sender: UISegmentedControl) {
        
        guard let currentInfoVM = currentInfoVM else {
            return
        }
        
        if conductor.isPlaying {
            stopSequencer()
        }
        
        let order: DegreesOrder = sender.selectedSegmentIndex == 0 ? .ascending : .descending
        injectAbcjsText(from: currentInfoVM.abcjsText(order: order), needReload: true)
    }
    
    
    @IBAction func btnActPlay(_ sender: Any) {
        playOrStop()
    }
        
    @IBAction func btnActSelectScale(_ sender: Any) {
        guard isMode(.create) else {
            return
        }
        
        let scaleListVC = initVCFromStoryboard(storyboardID: .ScaleListTableViewController) as! ScaleListTableViewController
        
        scaleListVC.mode = .uploadSelect
        scaleListVC.uploadDelegate = self
        
        navigationController?.pushViewController(scaleListVC, animated: true)
    }
    
    @IBAction func barBtnActDownloadOr(_ sender: UIBarButtonItem) {
        switch mode {
        case .read:
            break
        case .create:
            guard let infoVM = infoViewModelForCreateMode else {
                return
            }
            let post = Post(scaleInfo: infoVM.scaleInfo)
            SwiftSpinner.show("Uploading...")
            FirebasePostManager.shared.addPost(postRequest: post, completionHandler: { documentID in
                
                SwiftSpinner.hide()
                simpleAlert(self, message: "upload success: \(documentID)", title: "Success") { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            }, errorHandler: nil)
            
        }
    }
    
    // MARK: - prepare segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "":
            break
        default:
            break
        }
    }
    
    // MARK: - Handle data change
    
    private func setLabelsFromInfoVM() {
        
        guard let currentInfoVM = currentInfoVM else {
            return
        }
        
        self.title = currentInfoVM.name
        
        lblAscAndDescIsSame.text = currentInfoVM.isAscAndDescDifferent ? "Diff" : "Same"
        
        lblName.text = currentInfoVM.name
        lblAlias.text = currentInfoVM.nameAliasFormatted
        lblIntNotation.text = currentInfoVM.ascendingIntegerNotation
        lblPattern.text = currentInfoVM.ascendingPattern
        lblPriority.attributedText = starRatingVM.starTextAttributedStr(fillCount: currentInfoVM.defaultPriority)
        txvComment.text = currentInfoVM.comment
        
        txvComment.text = currentInfoVM.comment
        txvComment.sizeToFit()
        txvComment.frame.size.width = originalCommentWidth
        
        tableView.reloadData()
        
        // 악보
        injectAbcjsText(from: currentInfoVM.abcjsText(order: currentOrder), needReload: true)
    }
    
    private func needHideSectionsBeforeSelectScale(_ section: Int) -> Bool {
        return !selectedSomeScale && isMode(.create) && section != SECTION_FIRST && section != SECTION_METADATA
    }
    
    func getLabelHeight(text: String, font: UIFont = UIFont.systemFont(ofSize: 15), width: CGFloat = 1000) -> CGFloat {
        let refLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        refLabel.lineBreakMode = .byWordWrapping
        refLabel.numberOfLines = 0
        refLabel.font = font
        refLabel.text = text
        refLabel.sizeToFit()
        
        return refLabel.frame.height
    }
}

// MARK: - Table View overriding

extension ArchiveDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_METADATA && isMode(.create) {
            return 1
        }
        
        // Create mode일 때 신뢰도 섹션 숨김
        if isMode(.create) && section == SECTION_RELIABILITY {
            return 0
        }
        
        if needHideSectionsBeforeSelectScale(section) {
            return 0
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_FIRST {
            switch mode {
            case .read:
                return ""
            case .create:
                return "Select a scale"
            }
        }
        
        // Create mode일 때 신뢰도 섹션 숨김
        if isMode(.create) && section == SECTION_RELIABILITY {
            return ""
        }
        
        if needHideSectionsBeforeSelectScale(section) {
            return ""
        }
        
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if needHideSectionsBeforeSelectScale(section) {
            return ""
        }
        
        // Create mode일 때 신뢰도 섹션 숨김
        if isMode(.create) && section == SECTION_RELIABILITY {
            return ""
        }
        
        return super.tableView(tableView, titleForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let originalSize = super.tableView(tableView, heightForRowAt: indexPath)
        
        switch indexPath {
        case cellAliasIndexPath:
            if let currentInfoVM = currentInfoVM {
                let aliasCount = currentInfoVM.nameAlias.components(separatedBy: ";").count
                if aliasCount <= 1 {
                    return originalSize
                }
                
                let cellHeight = getLabelHeight(text: currentInfoVM.nameAliasFormatted, font: lblAlias.font)
                if cellHeight > originalSize {
                    return cellHeight + 10
                }
            }
        case cellCommentIndexPath:
            if let currentInfoVM = currentInfoVM {
                if currentInfoVM.comment == "" {
                    return 0
                }
                
                return txvComment.frame.height
            }
        default:
            break
        }
        
        return originalSize
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Create mode일 때 신뢰도 섹션 숨김
        if isMode(.create) && section == SECTION_RELIABILITY {
            return 0.1
        }
        
        if needHideSectionsBeforeSelectScale(section) {
            return 0.1
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Create mode일 때 신뢰도 섹션 숨김
        if isMode(.create) && section == SECTION_RELIABILITY {
            return 0.1
        }
        
        if needHideSectionsBeforeSelectScale(section) {
            return 0.1
        }
        
        return super.tableView(tableView, heightForFooterInSection: section)
    }
}

// MARK: - ScaleListUploadDelegate

extension ArchiveDetailTableViewController: ScaleListUploadDelegate {
    func didUploadScaleSelected(_ controller: ScaleListTableViewController, infoViewModel: ScaleInfoViewModel) {
        infoViewModel.currentTempo = Double(playbackTempo)
        self.infoViewModelForCreateMode = infoViewModel
        selectedSomeScale = true
    }
}

// MARK: - WebDelegate & ScoreWebInjection

extension ArchiveDetailTableViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, ScoreWebInjection {
    
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
        // 초기에 로딩되지 않으므로 제외
        
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
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("An error occurred!: \(error)")
    }
    
}

// MARK: - ConductorPlay

extension ArchiveDetailTableViewController: ConductorPlay {

    func playOrStop(playMode: PlayMode? = nil) {
        if conductor.sequencer.isPlaying {
            stopSequencer()
            return
        }
        startSequencer()
    }

    func startSequencer(playMode: PlayMode? = nil) {
        stopSequencer()
        
        if let currentInfoVM = currentInfoVM, let targetSemitones = currentInfoVM.playbackSemitones(order: currentOrder) {
            
            self.conductor.addScaleToSequencer(semitones: targetSemitones)
            self.conductor.isPlaying = true
            
            btnPlay.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            
            playTimer = Timer.scheduledTimer(timeInterval: conductor.sequencer.length.seconds, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
            startTimer()
        }
    }

    @objc func stopSequencer() {
        if conductor.isPlaying {
            stopTimer()
            conductor.sequencer.stop()
            conductor.sequencer.rewind()
            conductor.isPlaying = false
            
            btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
            playTimer?.invalidate()
        }
    }
}
