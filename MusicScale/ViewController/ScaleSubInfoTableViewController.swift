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
    @IBOutlet weak var lblPriority: UILabel!
    @IBOutlet weak var lblPattern: UILabel!
    @IBOutlet weak var lblIntegerNotation: UILabel!
    @IBOutlet weak var txvComment: UITextView!
    
    var scaleInfoViewModel: ScaleInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblName.text = scaleInfoViewModel.name
        lblNameAlias.text = scaleInfoViewModel.nameAlias
        lblPattern.text = scaleInfoViewModel.ascendingPattern
        lblIntegerNotation.text = scaleInfoViewModel.ascendingIntegerNotation
        lblPriority.text = (1...scaleInfoViewModel.defaultPriority).reduce("") { partialResult, _ in
            return partialResult + "⭐️"
        }
        txvComment.text = scaleInfoViewModel.comment
    }

    // MARK: - Table view data source


    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
