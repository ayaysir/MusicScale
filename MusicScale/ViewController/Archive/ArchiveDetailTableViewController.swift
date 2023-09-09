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
    @IBOutlet weak var btnSelectScale: UIButton!
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnDislike: UIButton!
    @IBOutlet weak var progressLikeDislike: UIProgressView!
    @IBOutlet weak var lblDislikeStatus: UILabel!
    @IBOutlet weak var lblLikeStatus: UILabel!
    
    // @IBOutlet weak var lblAscAndDescIsSame: UILabel!
    @IBOutlet weak var segAscDesc: UISegmentedControl!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAlias: UILabel!
    @IBOutlet weak var lblIntNotation: UILabel!
    @IBOutlet weak var lblPattern: UILabel!
    @IBOutlet weak var lblPriority: UILabel!
    @IBOutlet weak var txvComment: UITextView!
    @IBOutlet weak var lblDegreesAscending: UILabel!
    
    @IBOutlet weak var lblUploader: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var lblDownloadCount: UILabel!
    
    @IBOutlet weak var barBtnDownloadOr: UIBarButtonItem!
    @IBOutlet weak var barBtnDeleteOr: UIBarButtonItem!
    
    @IBOutlet weak var viewBannerContainer: UIView!
    
    private let starRatingVM = StarRatingViewModel()
    private let postManager = FirebasePostManager.shared
    
    // private let conductor = NoteSequencerConductor()
    let conductor = GlobalConductor.shared
    private var playTimer: Timer?
    private let playbackTempo: Float = 120.0
    
    // 데이터 목록
    var postViewModel: PostViewModel?
    var currentInfoVM: SimpleScaleInfoViewModel? {
        switch mode {
        case .read:
            return postViewModel?.scaleInfoVM
        case .create:
            return infoViewModelForCreateMode
        }
    }
    private var infoViewModelForCreateMode: ScaleInfoViewModel! {
        didSet {
            if isMode(.create) {
                setLabelsFromInfoVM()
            }
        }
    }
    
    var currentOrder: DegreesOrder {
        return segAscDesc.selectedSegmentIndex == 0 ? .ascending : .descending
    }
    
    var mode: CRUDMode = .read
    func isMode(_ mode: CRUDMode) -> Bool {
        return self.mode == mode
    }
    
    // === SECTION & INDEXPATH LIST ===
    private let SECTION_FIRST = 0
    private let SECTION_PREVIEW = 1
    private let SECTION_INFO = 2
    private let SECTION_RELIABILITY = 3
    private let SECTION_COMMENT = 4
    private let SECTION_METADATA = 5
    
    private let cellAliasIndexPath = IndexPath(row: 1, section: 2)
    private let cellCommentIndexPath = IndexPath(row: 0, section: 4)
    // ================================
    
    private let COLOR_LIKE: UIColor = .systemGreen
    private let COLOR_DISLIKE: UIColor = .systemPink
    private let COLOR_NONE: UIColor = .systemGray3
    private var currentLikeStatus: LikeStatus! {
        didSet {
            switch currentLikeStatus {
            case .like:
                btnLike.tintColor = COLOR_LIKE
                btnDislike.tintColor = COLOR_NONE
            case .dislike:
                btnLike.tintColor = COLOR_NONE
                btnDislike.tintColor = COLOR_DISLIKE
            default:
                btnLike.tintColor = COLOR_NONE
                btnDislike.tintColor = COLOR_NONE
            }
        }
    }
    private var currentLikeCounts: LikeCounts?
    
    private var selectedSomeScale: Bool = false {
        didSet {
            tableView.reloadData()
            barBtnDownloadOr.isEnabled = true
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch mode {
        case .read:
            getLikeStatus()
            getLikeCounts()
        case .create:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        switch mode {
        case .read:
            postManager.removeLikeCountListener()
        case .create:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TrackingTransparencyPermissionRequest()
        
        if isMode(.create) && !Reachability.isConnectedToNetwork() {
            simpleAlert(self, message: "No internet connection.".localized(), title: "Caution".localized()) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        // 공통
        setButtonTitle()
        
        loadWebSheetPage()
        // conductor.start()
        conductor.tempo = playbackTempo
        
        btnLike.tintColor = .clear
        btnDislike.tintColor = .clear
        
        // banner
        DispatchQueue.main.async { [unowned self] in
            btnSelectScale.setTitle("Select a scale...".localized(), for: .normal)
            btnSelectScale.isHidden = isMode(.read)
            if isMode(.read) {
                setupBannerAds(self, container: viewBannerContainer)
            }
        }
        
        // 분기
        switch mode {
        case .read:
            postViewModel?.currentTempo = Double(playbackTempo)
            setButtonTitleForReadMode()
            setMetadataLabelFromPostVM()
            setLabelsFromInfoVM()
            getPostCounts()
        case .create:
            setButtonTitleForCreateMode()
            let anonymousText = "Anonymous".localized()
            lblUploader.text = "\(anonymousText) (\(FirebaseAuthManager.shared.currentUser?.uid[0..<4] ?? ""))"
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
        
        barBtnDownloadOr.title = "Submit".localized()
        barBtnDownloadOr.isEnabled = true
    }
    
    func setButtonTitleForReadMode() {
        if let user = FirebaseAuthManager.shared.currentUser, user.uid == postViewModel?.authorUID {
            barBtnDeleteOr.title = "Delete".localized()
            barBtnDeleteOr.isEnabled = true
        } else {
            barBtnDeleteOr.title = ""
            barBtnDeleteOr.isEnabled = false
        }
        
        barBtnDownloadOr.title = "Download".localized()
        barBtnDownloadOr.isEnabled = true
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
        injectAbcjsText(from: currentInfoVM.abcjsTextForArchive(order: order), needReload: true)
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
            guard let postViewModel = postViewModel else {
                return
            }

            do {
                let newEntity = try postViewModel.writeToCoreData()
                postManager.updatePostCount(.download, documentID: postViewModel.documentID)
                postManager.readPostCount(.download, documentID: postViewModel.documentID) { (count: Int) in
                    self.lblDownloadCount.text = String(count)
                }
                
                simpleAlert(self, message: "Download was successful.".localized(), title: "Download".localized()) { _ in
                    NotificationCenter.default.post(name: .downloadedFromArchive, object: newEntity)
                }
            } catch {
                let localizedErrMsg = "Download failed: %@".localized()
                // simpleAlert(self, message: "Download failed: \(error.localizedDescription)")
                simpleAlert(self, message: localizedErrMsg)
            }
        case .create:
            // Submit
            guard let infoVM = infoViewModelForCreateMode else {
                simpleAlert(self, message: "You have not selected any scales to upload.".localized())
                return
            }
            let post = Post(scaleInfo: infoVM.scaleInfo)
            
            // setLoadingScreen()
            SwiftSpinner.show("Uploading...".localized())
            postManager.addPost(postRequest: post, completionHandler: { documentID in
                DispatchQueue.main.async {
                    SwiftSpinner.show(duration: 1.5, title: "Upload Completed!".localized(), animated: false) {
                        self.navigationController?.popViewController(animated: true)
                    }.addTapHandler({
                        SwiftSpinner.hide()
                        self.navigationController?.popViewController(animated: true)
                    }, subtitle: "Tap to dismiss".localized())
                }
            
            }, errorHandler: nil)
        }
    }
    
    @IBAction func btnActDeleteOr(_ sender: Any) {
        guard let postViewModel = postViewModel else {
            return
        }
        
        guard let user = FirebaseAuthManager.shared.currentUser else {
            return
        }

        if isMode(.read) && postViewModel.authorUID == user.uid {
            postManager.deletePost(documentID: postViewModel.documentID) { documentID in
                simpleAlert(self, message: "Delete was successful.".localized(), title: "Delete".localized()) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            } errorHandler: { err in
                let localizedErrMsg = "Failed to delete because an error occurred: %@".localized()
                // simpleAlert(self, message: "Failed to delete because an error occurred: \(err.localizedDescription)")
                simpleAlert(self, message: localizedErrMsg)
                return
            }
        }
    }
    
    @IBAction func btnLikeOrDislike(_ sender: UIButton) {
        guard let postViewModel = postViewModel, let currentLikeStatus = currentLikeStatus else {
            return
        }
        
        let oldStatus = currentLikeStatus
        
        // var newStatus: LikeStatus = .none
        switch sender {
        case btnLike:
            self.currentLikeStatus = currentLikeStatus == .like ? LikeStatus.none : .like
        case btnDislike:
            self.currentLikeStatus = currentLikeStatus == .dislike ? LikeStatus.none : .dislike
        default:
            break
        }
        
        postManager.updateLike(documentID: postViewModel.documentID, status: self.currentLikeStatus) { documentID in
            // 
        } errorHandler: { err in
            self.view.makeToast("Error has occured:".localized() + " \(err.localizedDescription)" , position: .center)
            self.currentLikeStatus = oldStatus
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
        
        // lblAscAndDescIsSame.text = currentInfoVM.isAscAndDescDifferent ? "Diff" : "Same"
        
        lblName.text = currentInfoVM.name
        lblAlias.text = currentInfoVM.nameAliasFormatted
        lblIntNotation.text = currentInfoVM.ascendingIntegerNotation
        lblPattern.text = currentInfoVM.ascendingPattern
        lblPriority.attributedText = starRatingVM.starTextAttributedStr(fillCount: currentInfoVM.defaultPriority)
        lblDegreesAscending.text = currentInfoVM.degreesAscending
        
        txvComment.text = currentInfoVM.comment
        
        tableView.reloadData()
        
        // 악보
        switch mode {
        case .read:
            break
        case .create:
            injectAbcjsText(from: currentInfoVM.abcjsTextForArchive(order: currentOrder), needReload: true)
        }
        
    }
    
    private func setMetadataLabelFromPostVM() {
        guard let postViewModel = postViewModel else {
            return
        }
        
        lblUploader.text = "Anonymous (\(postViewModel.authorUIDTruncated4))"
        lblCreatedDate.text = postViewModel.createdDateStr
        lblViewCount.text = "30"
        lblDownloadCount.text = "10"
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
    
    func getPostCounts() {
        // View, Download count
        guard let documentID = postViewModel?.documentID else {
            return
        }
        postManager.updatePostCount(.view, documentID: documentID)
        postManager.readPostCount(.view, documentID: documentID) { (count: Int) in
            self.lblViewCount.text = "\(count)"
        }
        postManager.readPostCount(.download, documentID: documentID) { (count: Int) in
            self.lblDownloadCount.text = "\(count)"
        }
    }
    
    // MARK: - Custom methods
    func getLikeStatus() {
        guard let postViewModel = postViewModel else {
            return
        }
        
        postManager.readLike(documentID: postViewModel.documentID) { like in
            self.currentLikeStatus = like?.status ?? LikeStatus.none
        }
    }
    
    func getLikeCounts() {
        guard let postViewModel = postViewModel else {
            return
        }
        
        postManager.listenTotalLikeCount(documentID: postViewModel.documentID) { [unowned self] (likeCounts: LikeCounts, recentChanges: Like?) in
            
            self.currentLikeCounts = likeCounts
            
            if likeCounts.totalCount == 0 {
                progressLikeDislike.progressTintColor = COLOR_NONE
                progressLikeDislike.trackTintColor = COLOR_NONE
                progressLikeDislike.setProgress(0.5, animated: true)
                
                lblLikeStatus.text = "0 (0%)"
                lblDislikeStatus.text = "0 (0%)"
            } else {
                progressLikeDislike.progressTintColor = COLOR_DISLIKE
                progressLikeDislike.trackTintColor = COLOR_LIKE
                progressLikeDislike.setProgress(Float(likeCounts.dislikePercent), animated: true)
                
                let roundedLikePercent = Int(round(likeCounts.likePercent * 100))
                let roundedDislikePercent = Int(round(likeCounts.dislikePercent * 100))
                lblLikeStatus.text = "\(likeCounts.likeCount) (\(roundedLikePercent)%)"
                lblDislikeStatus.text = "\(likeCounts.dislikeCount) (\(roundedDislikePercent)%)"
            }
        }
    }
}

// MARK: - Table View overriding

extension ArchiveDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Create mode일 때 Metadata는 uploader만 필요
        if isMode(.create) && section == SECTION_METADATA {
            return 1
        }
        
        // Create mode일 때 신뢰도 섹션 숨김
        if isMode(.create) && section == SECTION_RELIABILITY {
            return 0
        }
        
        // 광고
        if isMode(.read) && !AdsManager.SHOW_AD && section == SECTION_FIRST {
            return 0
        }
        
        // Create mode일 때 숨겨야 할 섹션들
        if needHideSectionsBeforeSelectScale(section) {
            return 0
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 모드에 따라 스케일 선택 또는 배너 광고
        if section == SECTION_FIRST {
            switch mode {
            case .read:
                return ""
            case .create:
                return "Select a scale".localized()
            }
        }
        
        // Create mode일 때 신뢰도 섹션 숨김
        if isMode(.create) && section == SECTION_RELIABILITY {
            return ""
        }
        
        // Create mode일 때 숨겨야 할 섹션들
        if needHideSectionsBeforeSelectScale(section) {
            return ""
        }
        
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // Preview Section
        if section == SECTION_PREVIEW {
            guard let infoVM = currentInfoVM else {
                return ""
            }
            
            return infoVM.isAscAndDescDifferent ? "This scale has different ascending and descending order.".localized() : "This scale has the same ascending and descending order.".localized()
        }
        
        // Create mode일 때 숨겨야 할 섹션들
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
                
                return UITableView.automaticDimension
            }
        case IndexPath(row: 0, section: SECTION_PREVIEW):
            return UITableView.automaticDimension
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
        
        // 광고
        if isMode(.read) && !AdsManager.SHOW_AD && section == SECTION_FIRST {
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
        
        
        // 광고
        if isMode(.read) && !AdsManager.SHOW_AD && section == SECTION_FIRST {
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
    
    func injectAbcjsText(from abcjsText: String, needReload: Bool, staffWidth: Int? = DEF_STAFFWIDTH) {
        
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
        if isMode(.read), let infoVM = currentInfoVM {
            injectAbcjsText(from: infoVM.abcjsTextForArchive(order: currentOrder), needReload: false)
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
