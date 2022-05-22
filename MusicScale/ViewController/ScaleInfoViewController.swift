//
//  ScaleInfoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/14.
//

import UIKit
import DropDown

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
    
    @IBOutlet weak var lblTempo: UILabel!
    
    // 나중에 UserDefaults 등으로 교체
    var tempCurrentOrder: DegreesOrder = .ascending
    var tempCurrentTempo: Double = 120
    var tempCurrentEnharmonicMode: EnharmonicMode = .standard
    
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
        
        stepTranspose.maximumValue = Double(Music.Key.allCases.count - 1)
        stepTempo.value = tempCurrentTempo
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
            tempCurrentOrder = .ascending
            changeOrder()
        case 1:
            tempCurrentOrder = .descending
            changeOrder()
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
        tempCurrentTempo = sender.value
        lblTempo.text = "\(Int(sender.value))"
        changeTempo()
    }
    
    @IBAction func stepActChangeOctaveShift(_ sender: UIStepper) {
        changeOctaveShift()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "InfoSegue":
            infoVC = segue.destination as? ScaleSubInfoTableViewController
            infoVC?.scaleInfoViewModel = scaleInfoViewModel
        case "WebSheetSegue":
            webSheetVC = segue.destination as? ScoreWebViewController
            webSheetVC?.scaleInfoViewModel = scaleInfoViewModel
            webSheetVC?.delegate = self
        case "PianoSegue":
            pianoVC = segue.destination as? PianoViewController
            pianoVC?.parentContainerView = containerViewPiano
        default:
            break
        }
    }

}

// MARK: - Custom methods
extension ScaleInfoViewController {
    
    private func reinjectAbcjsText() {
        webSheetVC?.injectAbcjsText(from: tempCurrentOrder == .ascending ? scaleInfoViewModel.abcjsTextAscending : scaleInfoViewModel.abcjsTextDescending, needReload: true)
        stopSequencer()
    }
    
    func changeTempo() {
        scaleInfoViewModel.currentTempo = tempCurrentTempo
        conductor.tempo = Float(tempCurrentTempo)

        reinjectAbcjsText()
    }
    
    func changeOctaveShift() {
        scaleInfoViewModel.currentOctaveShift = Int(stepOctaveShift.value)
        if let pianoVC = pianoVC {
            pianoVC.octaveShift = scaleInfoViewModel.currentOctaveShift
        }
        reinjectAbcjsText()
    }
    
    func changeOrder() {
        reinjectAbcjsText()
    }
    
    func changeEnharmonicMode(mode: EnharmonicMode) {
        
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
        
        tempCurrentEnharmonicMode = mode
        
        self.btnTranspose.setTitle(scaleInfoViewModel.currentKey.textValue, for: .normal)
        self.btnEnharmonic.setTitle("\(mode)", for: .normal)
        scaleInfoViewModel.currentEnharmonicMode = tempCurrentEnharmonicMode
        
        reinjectAbcjsText()

    }
    
    func transpose(noteStr: String) {
        
        self.btnTranspose.setTitle(noteStr, for: .normal)
        
        if let targetKey = Music.Key.getKeyFromNoteStr(noteStr) {
            scaleInfoViewModel.currentKey = targetKey
            reinjectAbcjsText()
            
            // change keyboard start position
            let playableKey = targetKey.playableKey
            pianoVC?.adjustKeyPosition(key: playableKey)
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
        let targetSemitones = tempCurrentOrder == .ascending ? scaleInfoViewModel.playbackSemitoneAscending : scaleInfoViewModel.playbackSemitoneDescending
        self.conductor.addScaleToSequencer(semintones: targetSemitones!)
        self.conductor.isPlaying = true
        
        btnPlayAndStop.setTitle("Stop", for: .normal)
        
        playTimer = Timer.scheduledTimer(timeInterval: scaleInfoViewModel.expectedPlayTime, target: self, selector: #selector(stopSequencer), userInfo: nil, repeats: false)
    }
    
    @objc func skf() {
        stopSequencer()
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
        let dataSource = Music.Key.allCases.map { $0.textValue }
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


