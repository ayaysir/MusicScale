//
//  ScaleSubInfoTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import UIKit

class ScaleSubInfoTableViewController: UITableViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameAlias: UILabel!
    @IBOutlet weak var lblInterval: UILabel!
    @IBOutlet weak var lblPriority: UILabel!
    @IBOutlet weak var txvComment: UITextView!
    
    var scaleInfo: ScaleInfo!
    
    let musicSheetHelper = MusicSheetHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblName.text = scaleInfo.name
        lblNameAlias.text = scaleInfo.nameAlias
        lblInterval.text = "WHWHWHWH"
        lblPriority.text = (1...scaleInfo.defaultPriority).reduce("") { partialResult, _ in
            return partialResult + "⭐️"
        }
        txvComment.text = scaleInfo.comment
    }

    // MARK: - Table view data source


    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
