//
//  ScaleInfoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/14.
//

import UIKit
import DropDown
import AudioToolbox
import GoogleMobileAds

protocol ScaleInfoVCDelgate: AnyObject {
    func didInfoUpdated(_ controller: ScaleInfoViewController, indexPath: IndexPath?)
}

class ScaleInfoViewController: UIViewController {
    private var interstitial: GADInterstitialAd?
    
    @IBOutlet weak var containerViewInfo: UIView!
    @IBOutlet weak var containerViewWebSheet: UIView!
    @IBOutlet weak var containerViewPiano: UIView!
    
    @IBOutlet weak var btnTranspose: UIButton!
    @IBOutlet weak var btnEnharmonic: UIButton!
    @IBOutlet weak var btnPlayAndStop: UIButton!
    
    @IBOutlet weak var stepTranspose: UIStepper!
    @IBOutlet weak var stepTempo: UIStepper!
    @IBOutlet weak var stepOctaveShift: UIStepper!
    
    @IBOutlet weak var segDegreesOrder: UISegmentedControl!
    
    @IBOutlet weak var lblTempo: UILabel!
    @IBOutlet weak var lblOctaveShift: UILabel!
    
    @IBOutlet weak var viewPlayConfig: UIView!
    
    @IBOutlet weak var barBtnUpdate: UIBarButtonItem!
    
    @IBOutlet weak var cnstSheetPropoHeight: NSLayoutConstraint!
    @IBOutlet weak var cnstPianoHeight: NSLayoutConstraint!
    private var originialCnstSheetPropoHeight: NSLayoutConstraint!
    private var originalCnstPianoHeight: NSLayoutConstraint!
    
    var configStore = ScaleInfoVCConfigStore.shared
    var selectedIndexPath: IndexPath?
    weak var delegate: ScaleInfoVCDelgate?
    
    var infoVC: ScaleSubInfoTableViewController?
    var webSheetVC: ScoreWebViewController?
    var pianoVC: PianoViewController?
    
    /*
     비교 모드(Comparison Mode)
     1. 비교모드가 아닌 경우 빈 배열, 한 개의 ScaleInfoVM
     2. 비교모드인 경우 배열에 여러 개의 ScaleInfoVM 넣어놓고
        segmentControl 바뀔 때마다 scaleInfoVM 변수 교체 -> re-render entire VC
     */
    var scaleInfoViewModel: ScaleInfoViewModel!
    var comparisonViewModel: ScaleComparisonViewModel?
    
    let transposeDropDown = DropDown()
    let enharmonicDropDown = DropDown()
    
    // private let conductor = NoteSequencerConductor()
    let conductor = GlobalConductor.shared
    private var playTimer: Timer?
    
    var staffWidth: Int? {
        if isPad && isLandscape {
            return 700
        }
        
        return DEF_STAFFWIDTH
    }
    
    // MARK: - VC life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 최초 실행 후 한 번만 하면 되는 작업들
        
        TrackingTransparencyPermissionRequest()
        
        backupConstraintsConstant()
        
        initTransposeDropDown()
        initEnharmonicDropDown()
        
        addCornerRadiusToButtons()
        scaleUpAllSteppers()
        
        hideTabBarWhenLandscape(self)
        
        updateMultiplierRefelectOrientation()
        redrawPianoViewWhenOrientationChange()
        
        addLongpressGestureForPlaySameTime()
        
        // 뷰모델 변경되면 다시 해야되는 작업들
        
        // VC 타이틀 변경
        self.title = scaleInfoViewModel.name
        
        // loadFromConfigStore()는 prepare에서 실행
        
        // 피아노 이용 가능 키 표시 - 최초 페이지 열었을 때
        setAvailableKeyAndOctaveShift()
        
        // 전면 광고 준비
        prepareFullScreenAd()
        
        // 스와이프로 뒤로가기 비활성화
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isPhone {
            OrientationUtil.lockOrientation(.portrait)
        }
        
        conductor.tempo = Float(configStore.tempo)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isPhone {
            OrientationUtil.lockOrientation(.portrait, andRotateTo: .portrait)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSequencer()
        showTabBar(self)
        OrientationUtil.lockOrientation(.all)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        // 뒤로 가기 사이에 전면 광고를 표시하려면 willMove에 추가
        interstitial?.present(fromRootViewController: self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        hideTabBarWhenLandscape(self)
        updateMultiplierRefelectOrientation()
        
        coordinator.animate(alongsideTransition: nil) { _ in
            self.redrawPianoViewWhenOrientationChange()
            self.reinjectAbcjsText()
        }
    }
    
    // MARK: - Init methods
    
    /// 피아노 이용 가능 키 표시
    func setAvailableKeyAndOctaveShift() {
        pianoVC?.adjustKeyPosition(key: scaleInfoViewModel.currentKey.playableKey)
        pianoVC?.octaveShift = scaleInfoViewModel.currentOctaveShift
        changeAvailableKeys()
    }
    
    /// 방향 전환시 피아노 뷰 다시 그리기 (coordinator.animate(alongsideTransition: nil) {...})
    func redrawPianoViewWhenOrientationChange() {
        self.view.layoutIfNeeded()
        pianoVC?.parentContainerView = containerViewPiano
        pianoVC?.setPiano()
        setAvailableKeyAndOctaveShift()
    }
    
    private func setContainersMultiplier(sheetMultipler: CGFloat, pianoMultiplier: CGFloat) {
        cnstSheetPropoHeight = cnstSheetPropoHeight.setMultiplier(multiplier: sheetMultipler)
        cnstPianoHeight = cnstPianoHeight.setMultiplier(multiplier: pianoMultiplier)
        containerViewWebSheet.layoutIfNeeded()
        containerViewPiano.layoutIfNeeded()
    }
    
    private func updateMultiplierRefelectOrientation() {
        if isLandscape {
            // sheet: 0.22 -> 10% 증가
            // piano: 0.235 ->
            setContainersMultiplier(sheetMultipler: 0.32, pianoMultiplier: 0.335)
        } else {
            setContainersMultiplier(sheetMultipler: originialCnstSheetPropoHeight.multiplier, pianoMultiplier: originalCnstPianoHeight.multiplier)
        }
    }
    
    private func scaleUpAllSteppers() {
        let stepperScale: CGFloat = 0.7
        viewPlayConfig.subviews.forEach { view in
            if type(of: view) == UIStepper.self {
                view.transform = CGAffineTransform(scaleX: stepperScale, y: stepperScale)
            }
        }
    }
    
    private func addCornerRadiusToButtons() {
        btnPlayAndStop.layer.cornerRadius = btnPlayAndStop.frame.width * 0.5
        btnEnharmonic.layer.cornerRadius = 5
        btnTranspose.layer.cornerRadius = 5
    }
    
    private func backupConstraintsConstant() {
        originialCnstSheetPropoHeight = cnstSheetPropoHeight
        originalCnstPianoHeight = cnstPianoHeight
    }
    
    private func addLongpressGestureForPlaySameTime() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(btnPlayLongPressed))
        // longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delaysTouchesBegan = true
        btnPlayAndStop.addGestureRecognizer(longPressRecognizer)
    }
    
    private func prepareFullScreenAd() {
        Task {
            interstitial = try await setupFullAds(self)
            interstitial?.fullScreenContentDelegate = self
        }
    }
    
    // MARK: - Outlet Action
    @IBAction func btnActTranspose(_ sender: UIButton) {
        transposeDropDown.anchorView = sender
        transposeDropDown.show()
    }
    
    @IBAction func btnActEnharmonicNotes(_ sender: UIButton) {
        enharmonicDropDown.anchorView = sender
        enharmonicDropDown.show()
    }
    
    @IBAction func stepActTranspose(_ sender: UIStepper) {
        let index = Int(sender.value)
        // print(#function, index, sender.maximumValue)
        let noteStr = transposeDropDown.dataSource[index]
        transpose(noteStr: noteStr)
    }
    
    @IBAction func segActChangeOrder(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            changeOrder(.ascending)
        case 1:
            changeOrder(.descending)
        default:
            break
        }
    }
    
    @IBAction func btnActPlayAndStop(_ sender: UITapGestureRecognizer) {
        if conductor.sequencer.isPlaying {
            stopSequencer()
            return
        }
        startSequencer()
    }
    
    @objc func btnPlayLongPressed(_ gesture: UILongPressGestureRecognizer) {
        if conductor.sequencer.isPlaying {
            return
        }
        
        if gesture.state == .began {
            Vibration.warning.vibrate()
            startAllNotesAtSameTime()
        }
    }
    
    @IBAction func stepActChangeTempo(_ sender: UIStepper) {
        let tempo = sender.value
        changeTempo(tempo: tempo)
    }
    
    @IBAction func stepActChangeOctaveShift(_ sender: UIStepper) {
        changeOctaveShift(Int(sender.value))
    }
    
    @IBAction func btnActExpandInfo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.tintColor = .systemYellow
            // 0으로 설정시 크기 복구가 안됨
            setContainersMultiplier(sheetMultipler: 0.0001, pianoMultiplier: 0.0001)
        } else {
            sender.tintColor = .systemGray3
            updateMultiplierRefelectOrientation()
        }
        redrawPianoViewWhenOrientationChange()
    }
    
    @IBAction func btnActCompare(_ sender: Any) {
        let scaleListVC = initVCFromStoryboard(storyboardID: .ScaleListTableViewController) as! ScaleListTableViewController
        
        scaleListVC.mode = .compareSelect
        if comparisonViewModel == nil {
            comparisonViewModel = ScaleComparisonViewModel(firstScaleInfoVM: scaleInfoViewModel)
            barBtnUpdate.isEnabled = false
            barBtnUpdate.title = nil
        }
        
        scaleListVC.comparisonViewModel = comparisonViewModel
        scaleListVC.compareDelegate = self
        

        navigationController?.pushViewController(scaleListVC, animated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "InfoSegue":
            infoVC = segue.destination as? ScaleSubInfoTableViewController
            renderInfoSegue()
        case "WebSheetSegue":
            webSheetVC = segue.destination as? ScoreWebViewController
            renderWebSheetSegue()
        case "PianoSegue":
            pianoVC = segue.destination as? PianoViewController
            renderPianoSegue()
        case "UpdateScaleInfoSegue":
            let updateVC = segue.destination as! ScaleInfoUpdateTableViewController
            updateVC.infoViewModel = scaleInfoViewModel
            updateVC.mode = .update
            updateVC.updateDelegate = self
        default:
            break
        }
    }
    
    // MARK: - render each subVCs
    
    private func renderInfoSegue() {
        guard let infoVC = infoVC else {
            return
        }

        infoVC.scaleInfoViewModel = scaleInfoViewModel
        infoVC.delegate = self
    }
    
    private func renderWebSheetSegue() {
        guard let webSheetVC = webSheetVC else {
            return
        }
        
        loadFromConfigStore()   // 최초 정보 로딩
        webSheetVC.scaleInfoViewModel = scaleInfoViewModel
        webSheetVC.delegate = self
        webSheetVC.staffWidth = staffWidth
    }
    
    private func renderPianoSegue() {
        guard let pianoVC = pianoVC else {
            return
        }

        view.layoutIfNeeded()
        pianoVC.parentContainerView = containerViewPiano
    }
    // MARK: - refresh VC for Multiple Comparison mode
    
    func reloadInfoViews() {
        // VC 타이틀 변경
        self.title = scaleInfoViewModel.name
        
        // 피아노 이용 가능 키 표시 - 최초 페이지 열었을 때
        setAvailableKeyAndOctaveShift()
        
        renderInfoSegue()
        // isUpdate: 별명 필드와 코멘트 필드의 셀 높이를 변경하는 역할
        infoVC?.refreshViewInfo(isUpdated: true)
        
        renderWebSheetSegue()
        webSheetVC?.renderAbjcsText(needReload: true)
        
        renderPianoSegue()
    }
}

extension ScaleInfoViewController {
    
    // MARK: - Custom methods
    
    private func loadFromConfigStore() {
        // tempo
        let tempo = configStore.tempo
        changeTempo(tempo: tempo, initChange: true)
        
        // order
        let order = configStore.degreesOrder
        changeOrder(order, initChange: true)
        
        // octaveShift
        let octaveShift = configStore.octaveShift
        changeOctaveShift(octaveShift, initChange: true)
        
        // transpose
        let transposeStr = configStore.transpose
        transpose(noteStr: transposeStr ?? "C", initChange: true)
        
        // EnharmonicMode
        let mode = configStore.enharmonicMode
        changeEnharmonicMode(mode: mode, initChange: true)
        
        // customEnharmonics
    }
    
    private func reinjectAbcjsText() {
        webSheetVC?.injectAbcjsText(from: configStore.degreesOrder == .ascending ? scaleInfoViewModel.abcjsTextAscending : scaleInfoViewModel.abcjsTextDescending, needReload: true, staffWidth: staffWidth)
        stopSequencer()
    }
    
    func changeTempo(tempo: Double, initChange: Bool = false) {
        stepTempo.value = tempo
        scaleInfoViewModel.currentTempo = tempo
        conductor.tempo = Float(tempo)
        lblTempo.text = "\(Int(tempo))"
        
        if !initChange {
            reinjectAbcjsText()
            configStore.tempo = tempo
        }
    }
    
    func changeOctaveShift(_ shift: Int, initChange: Bool = false) {
        scaleInfoViewModel.currentOctaveShift = shift
        stepOctaveShift.value = Double(shift)
        lblOctaveShift.text = "\(shift)"
        
        if let pianoVC = pianoVC {
            pianoVC.octaveShift = scaleInfoViewModel.currentOctaveShift
        }
        
        if !initChange {
            reinjectAbcjsText()
            configStore.octaveShift = shift
        }
    }
    
    func changeOrder(_ order: DegreesOrder, initChange: Bool = false) {
        // 다른 곳에서 사용시 configStore.degreesOrder 등으로 사용
        
        configStore.degreesOrder = order
        changeAvailableKeys()
        
        if !initChange {
            reinjectAbcjsText()
        } else {
            segDegreesOrder.selectedSegmentIndex = order == .ascending ? 0 : 1
        }
    }
    
    func changeEnharmonicMode(mode: EnharmonicMode, initChange: Bool = false) {
        
        let currentKeyAccidentalValue = scaleInfoViewModel.currentKey.accidentalValue
        
        switch mode {
        case .standard, .userCustom:
            transposeDropDown.dataSource = Music.Key.allCases.map { $0.textValue }
        case .sharpAndNatural:
            transposeDropDown.dataSource = Music.Key.sharpKeys.map { $0.textValue }
            if currentKeyAccidentalValue == "flat" {
                scaleInfoViewModel.currentKey = scaleInfoViewModel.currentKey.enharmonicKey
            }
        case .flatAndNatural:
            transposeDropDown.dataSource = Music.Key.flatKeys.map { $0.textValue }
            if currentKeyAccidentalValue == "sharp" {
                scaleInfoViewModel.currentKey = scaleInfoViewModel.currentKey.enharmonicKey
            }
        }
        
        stepTranspose.maximumValue = Double(transposeDropDown.dataSource.count) - 1
        
        let stepIndex = transposeDropDown.dataSource.firstIndex(of: scaleInfoViewModel.currentKey.textValue)!
        stepTranspose.value = Double(stepIndex)
        
        // tempCurrentEnharmonicMode = mode
        
        self.btnTranspose.setTitle(scaleInfoViewModel.currentKey.textValue, for: .normal)
        self.btnEnharmonic.setTitle(mode.titleValue, for: .normal)
        scaleInfoViewModel.currentEnharmonicMode = mode
        
        if !initChange {
            reinjectAbcjsText()
            configStore.enharmonicMode = mode
        }
    }
    
    func transpose(noteStr: String, initChange: Bool = false) {
        
        self.btnTranspose.setTitle(noteStr, for: .normal)
        
        if let targetKey = Music.Key.getKeyFromNoteStr(noteStr) {
            scaleInfoViewModel.currentKey = targetKey
            
            // change keyboard start position
            let playableKey = targetKey.playableKey
            pianoVC?.adjustKeyPosition(key: playableKey)
            
            // 피아노 이용 가능 키 표시 - Transpose 했을때
            changeAvailableKeys()
            
            if !initChange {
                reinjectAbcjsText()
                configStore.transpose = noteStr
            }
        }
    }
    
    private func changeAvailableKeys() {
        // 피아노 이용 가능 키 표시
        if scaleInfoViewModel.isAscAndDescDifferent && configStore.degreesOrder == .descending {
            pianoVC?.updateAvailableKeys(integerNotations: scaleInfoViewModel.availableIntNoteArrayInDescOrder)
        } else {
            pianoVC?.updateAvailableKeys(integerNotations: scaleInfoViewModel.ascendingIntegerNotationArray)
        }
    }
    
    @objc func stopSequencer() {
        webSheetVC?.stopTimer()
        conductor.sequencer.stop()
        conductor.sequencer.rewind()
        conductor.isPlaying = false
        // btnPlayAndStop.setTitle("Play", for: .normal)
        btnPlayAndStop.setImage(UIImage(systemName: "play.fill"), for: .normal)
        btnPlayAndStop.backgroundColor = .systemPink
        
        playTimer?.invalidate()
    }
    
    func startSequencer() {
        stopSequencer()
        webSheetVC?.startTimer()
        let targetSemitones = configStore.degreesOrder == .ascending ? scaleInfoViewModel.playbackSemitoneAscending : scaleInfoViewModel.playbackSemitoneDescending
        self.conductor.addScaleToSequencer(semitones: targetSemitones!)
        self.conductor.isPlaying = true
        
        btnPlayAndStop.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        btnPlayAndStop.backgroundColor = .systemPink
        playTimer = Timer.scheduledTimer(timeInterval: self.conductor.sequencer.length.seconds, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
    }
    
    /// 길게 누르면 모든 음을 동시에 재생
    func startAllNotesAtSameTime() {
        stopSequencer()
        let targetSemitones = configStore.degreesOrder == .ascending ? scaleInfoViewModel.playbackSemitoneAscending : scaleInfoViewModel.playbackSemitoneDescending
        conductor.addSacleToSequencerForPlayAllNoteOnce(semitones: targetSemitones!)
        self.conductor.isPlaying = true
        
        btnPlayAndStop.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        btnPlayAndStop.backgroundColor = .blue
        playTimer = Timer.scheduledTimer(timeInterval: self.conductor.sequencer.length.seconds, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
    }
}

// MARK: - ScoreWebVCDelegate
extension ScaleInfoViewController: ScoreWebVCDelegate {
    
    func didStartButtonClicked(_ controller: ScoreWebViewController) {
        startSequencer()
    }
    
    func didStopButtonClicked(_ controller: ScoreWebViewController) {
        stopSequencer()
    }
}

// MARK: - ScaleInfoUpdateTVCDelegate
extension ScaleInfoViewController: ScaleInfoUpdateTVCDelegate {
    
    func didFinishedUpdate(_ controller: ScaleInfoUpdateTableViewController, viewModel: ScaleInfoViewModel) {
        self.scaleInfoViewModel = viewModel
        self.title = viewModel.name
        infoVC?.refreshViewInfo(isUpdated: true)
        delegate?.didInfoUpdated(self, indexPath: selectedIndexPath)
        changeAvailableKeys()
        reinjectAbcjsText()
        
        // tempo bug fix
        conductor.tempo = Float(configStore.tempo)
    }
}

// MARK: - ScaleSubInfoTVCDelegate
extension ScaleInfoViewController: ScaleSubInfoTVCDelegate {
    
    func didCompareScaleChange(_ controller: ScaleSubInfoTableViewController, index: Int) {
        guard let comparisonViewModel = comparisonViewModel else { return }
        scaleInfoViewModel = comparisonViewModel.totalSegmentVMs[index]
        reloadInfoViews()
        stopSequencer()
    }
    
    func didMyPriorityUpdated(_ controller: ScaleSubInfoTableViewController, viewModel: ScaleInfoViewModel) {
        self.scaleInfoViewModel = viewModel
        // List TableView에 변경사항 반영
        delegate?.didInfoUpdated(self, indexPath: selectedIndexPath)
    }
}

// MARK: - ScaleListCompareDelegate
extension ScaleInfoViewController: ScaleListCompareDelegate {
    
    func didCompareListSubmitted(_ controller: ScaleListTableViewController, updatedVM: ScaleComparisonViewModel) {
        // print(#function)
        // updatedVM.printTotalSegmentVmsName()
        comparisonViewModel = updatedVM
        infoVC?.comparisonViewModel = comparisonViewModel
        
        if !updatedVM.isComparisonAllowed && barBtnUpdate.title == nil {
            barBtnUpdate.title = "Update".localized()
            barBtnUpdate.isEnabled = true
        }
        
        scaleInfoViewModel = updatedVM.firstScaleInfoVM
        reloadInfoViews()
    }
}

// MARK: - DropDown
extension ScaleInfoViewController {
    
    private func dropDownCommon(dropDown: DropDown, dataSource: [String], selectionAction: SelectionClosure?) -> DropDown {
        
        // style
        dropDown.cornerRadius = 10
        dropDown.cellHeight = 30
        
        dropDown.dataSource = dataSource
        dropDown.selectionAction = selectionAction
        
        return dropDown
    }
    
    func initTransposeDropDown() {
        
        let targetDropDown = transposeDropDown
        var dataSource: [String] {
            switch configStore.enharmonicMode {
            case .standard, .userCustom:
                return Music.Key.allCases.map { $0.textValue }
            case .sharpAndNatural:
                return Music.Key.sharpKeys.map { $0.textValue }
            case .flatAndNatural:
                return Music.Key.flatKeys.map { $0.textValue }
            }
        }
        
        let selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            transpose(noteStr: item)
            stepTranspose.value = Double(index)
        }
        _ = dropDownCommon(dropDown: targetDropDown, dataSource: dataSource, selectionAction: selectionAction)
    }
    
    func initEnharmonicDropDown() {
        
        let targetDropDown = enharmonicDropDown
        let dataSource = EnharmonicMode.titleValues
        let selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            changeEnharmonicMode(mode: .init(rawValue: index)!)
          }
        _ = dropDownCommon(dropDown: targetDropDown, dataSource: dataSource, selectionAction: selectionAction)
    }
}

extension ScaleInfoViewController: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        view.isUserInteractionEnabled = true
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        view.isUserInteractionEnabled = true
    }
}
