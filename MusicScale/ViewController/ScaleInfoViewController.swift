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
    
    var infoVC: ScaleSubInfoTableViewController?
    var webSheetVC: ScaleDetailWebViewController?
    var pianoVC: PianoViewController?
    
    var scaleInfoViewModel: ScaleInfoViewModel!
    
    let transposeDropDown = DropDown()
    let enharmonicDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTransposeDropDown()
        initEnharmonicDropDown()
        
        self.title = scaleInfoViewModel.name
        
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
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "InfoSegue":
            infoVC = segue.destination as? ScaleSubInfoTableViewController
            infoVC?.scaleInfoViewModel = scaleInfoViewModel
        case "WebSheetSegue":
            webSheetVC = segue.destination as? ScaleDetailWebViewController
            webSheetVC?.scaleInfoViewModel = scaleInfoViewModel
        case "PianoSegue":
            pianoVC = segue.destination as? PianoViewController
        default:
            break
        }
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
        let dataSource = Music.PlayableKey.allCases.map { $0.textValueMixed }
        let selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
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
