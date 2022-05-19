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
    
    @IBOutlet weak var lblTempo: UILabel!
    
    // 나중에 UserDefaults 등으로 교체
    var tempCurrentOrder: DegreesOrder = .ascending
    var tempCurrentTempo: Double = 120
    
    var infoVC: ScaleSubInfoTableViewController?
    var webSheetVC: ScoreWebViewController?
    var pianoVC: PianoViewController?
    
    var scaleInfoViewModel: ScaleInfoViewModel!
    
    let transposeDropDown = DropDown()
    let enharmonicDropDown = DropDown()
    
    let conductor = NoteSequencerConductor()
    
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
        print(sender.value)
        let index = Int(sender.value)
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
        scaleInfoViewModel.setCurrentTempo(tempCurrentTempo)
        conductor.tempo = Float(tempCurrentTempo)
        print(conductor.tempo)
        reinjectAbcjsText()
    }
    
    func changeOrder() {
        reinjectAbcjsText()
    }
    
    func transpose(noteStr: String) {
        
        self.btnTranspose.setTitle(noteStr, for: .normal)
        
        if let targetKey = Music.Key.getKeyFromNoteStr(noteStr) {
            scaleInfoViewModel.setCurrentKey(targetKey)
            reinjectAbcjsText()
            
            // change keyboard start position
            let playableKey = targetKey.playableKey
            pianoVC?.adjustKeyPosition(key: playableKey)
        }
    }
    
    func stopSequencer() {
        webSheetVC?.stopTimer()
        conductor.sequencer.stop()
        conductor.sequencer.rewind()
        btnPlayAndStop.setTitle("Play", for: .normal)
    }
    
    func startSequencer() {
        stopSequencer()
        webSheetVC?.startTimer()
        let targetSemitones = tempCurrentOrder == .ascending ? scaleInfoViewModel.playbackSemitoneAscending : scaleInfoViewModel.playbackSemitoneDescending
        conductor.addScaleToSequencer(semintones: targetSemitones!)
        btnPlayAndStop.setTitle("Stop", for: .normal)
        conductor.sequencer.play()
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
        let dataSource = ["Default", "Sharp(♯) only", "Flat(♭) only"]
        let selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
          }
        _ = dropDownCommon(dropDown: targetDropDown, dataSource: dataSource, selectionAction: selectionAction)
    }
    
}


