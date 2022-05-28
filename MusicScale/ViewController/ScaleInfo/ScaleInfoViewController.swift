//
//  ScaleInfoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/14.
//

import UIKit
import DropDown
import AudioToolbox

protocol ScaleInfoVCDelgate: AnyObject {
    func didInfoUpdated(_ controller: ScaleInfoViewController, indexPath: IndexPath?)
}

class ScaleInfoViewController: UIViewController {
    
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
    
    // 나중에 UserDefaults 등으로 교체
    var configStore = ScaleInfoVCConfigStore.shared
    // var tempCurrentOrder: DegreesOrder = .ascending
    // var tempCurrentTempo: Double = 120
    // var tempCurrentEnharmonicMode: EnharmonicMode = .standard
    
    var selectedIndexPath: IndexPath?
    weak var delegate: ScaleInfoVCDelgate?
    
    var infoVC: ScaleSubInfoTableViewController?
    var webSheetVC: ScoreWebViewController?
    var pianoVC: PianoViewController?
    
    var scaleInfoViewModel: ScaleInfoViewModel!
    
    let transposeDropDown = DropDown()
    let enharmonicDropDown = DropDown()
    
    let conductor = NoteSequencerConductor()
    
    var playTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTransposeDropDown()
        initEnharmonicDropDown()
        
        self.title = scaleInfoViewModel.name
        
        conductor.start()
        
        // loadFromConfigStore()는 prepare에서 실행
        
        // 피아노 이용 가능 키 표시 - 최초 페이지 열었을 때
        pianoVC?.adjustKeyPosition(key: scaleInfoViewModel.currentKey.playableKey)
        pianoVC?.octaveShift = scaleInfoViewModel.currentOctaveShift
        changeAvailableKeys()
        
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
    
    @IBAction func btnActPlayAndStop(_ sender: UIButton) {
        if conductor.sequencer.isPlaying {
            stopSequencer()
            return
        }
        startSequencer()
    }
    
    @IBAction func stepActChangeTempo(_ sender: UIStepper) {
        let tempo = sender.value
        changeTempo(tempo: tempo)
    }
    
    @IBAction func stepActChangeOctaveShift(_ sender: UIStepper) {
        changeOctaveShift(Int(sender.value))
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "InfoSegue":
            infoVC = segue.destination as? ScaleSubInfoTableViewController
            infoVC?.scaleInfoViewModel = scaleInfoViewModel
            infoVC?.delegate = self
        case "WebSheetSegue":
            webSheetVC = segue.destination as? ScoreWebViewController
            // 최초 정보 로딩
            loadFromConfigStore()
            webSheetVC?.scaleInfoViewModel = scaleInfoViewModel
            webSheetVC?.delegate = self
        case "PianoSegue":
            pianoVC = segue.destination as? PianoViewController
            pianoVC?.parentContainerView = containerViewPiano
        case "UpdateScaleInfoSegue":
            print("UpdateScaleInfoSegue")
            let updateVC = segue.destination as! ScaleInfoUpdateTableViewController
            updateVC.infoViewModel = scaleInfoViewModel
            updateVC.mode = .update
            updateVC.updateDelegate = self
        default:
            break
        }
    }

}

// MARK: - Custom methods
extension ScaleInfoViewController {
    
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
        
        // reinjectAbcjsText()
        
        // customEnharmonics
        // TOOO
        
        // stepTranspose.maximumValue = Double(Music.Key.allCases.count - 1)
    }
    
    private func reinjectAbcjsText() {
        webSheetVC?.injectAbcjsText(from: configStore.degreesOrder == .ascending ? scaleInfoViewModel.abcjsTextAscending : scaleInfoViewModel.abcjsTextDescending, needReload: true)
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
        self.btnEnharmonic.setTitle("\(mode)", for: .normal)
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
            print(scaleInfoViewModel.availableIntNoteArrayInDescOrder)
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
        btnPlayAndStop.setTitle("Play", for: .normal)
        
        playTimer?.invalidate()
        
    }
    
    func startSequencer() {
        stopSequencer()
        webSheetVC?.startTimer()
        let targetSemitones = configStore.degreesOrder == .ascending ? scaleInfoViewModel.playbackSemitoneAscending : scaleInfoViewModel.playbackSemitoneDescending
        self.conductor.addScaleToSequencer(semintones: targetSemitones!)
        self.conductor.isPlaying = true
        
        btnPlayAndStop.setTitle("Stop", for: .normal)
        
        playTimer = Timer.scheduledTimer(timeInterval: scaleInfoViewModel.expectedPlayTime, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
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
        infoVC?.refreshViewInfo(isUpdated: true)
        delegate?.didInfoUpdated(self, indexPath: selectedIndexPath)
        changeAvailableKeys()
        reinjectAbcjsText()
        
    }
}

// MARK: - ScaleSubInfoTVCDelegate
extension ScaleInfoViewController: ScaleSubInfoTVCDelegate {
    
    func didMyPriorityUpdated(_ controller: ScaleSubInfoTableViewController, viewModel: ScaleInfoViewModel) {
        self.scaleInfoViewModel = viewModel
        // List TableView에 변경사항 반영
        delegate?.didInfoUpdated(self, indexPath: selectedIndexPath)
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
        let dataSource = ["Scale's default", "Sharp(♯) and natural", "Flat(♭) and natural", "Custom"]
        let selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            changeEnharmonicMode(mode: .init(rawValue: index)!)
          }
        _ = dropDownCommon(dropDown: targetDropDown, dataSource: dataSource, selectionAction: selectionAction)
    }
    
}


