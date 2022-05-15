//
//  ScaleInfoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/14.
//

import UIKit

class ScaleInfoViewController: UIViewController {
    
    @IBOutlet weak var lblScaleName: UILabel!
    
    @IBOutlet weak var containerViewInfo: UIView!
    @IBOutlet weak var containerViewWebSheet: UIView!
    @IBOutlet weak var containerViewPiano: UIView!
    
    var infoVC: ScaleSubInfoTableViewController?
    var webSheetVC: ScaleDetailWebViewController?
    var pianoVC: PianoViewController?
    
    var scaleInfo: ScaleInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblScaleName.text = scaleInfo.name
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "InfoSegue":
            infoVC = segue.destination as? ScaleSubInfoTableViewController
            infoVC?.scaleInfo = scaleInfo
        case "WebSheetSegue":
            webSheetVC = segue.destination as? ScaleDetailWebViewController
        case "PianoSegue":
            pianoVC = segue.destination as? PianoViewController
        default:
            break
        }
    }

}
