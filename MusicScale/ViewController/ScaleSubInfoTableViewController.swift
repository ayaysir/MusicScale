//
//  ScaleSubInfoTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import UIKit

class ScaleSubInfoTableViewController: UITableViewController {
    
    let MIN_CELL_SIZE: CGFloat = 30.0
    let cellAliasIndexPath = IndexPath(row: 1, section: 0)
    let cellCommentIndexPath = IndexPath(row: 0, section: 1)

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameAlias: UILabel!
    @IBOutlet weak var lblPriority: UILabel!
    @IBOutlet weak var lblPattern: UILabel!
    @IBOutlet weak var lblIntegerNotation: UILabel!
    @IBOutlet weak var txvComment: UITextView!
    
    @IBOutlet weak var tblCellNameAlias: UITableViewCell!
    
    var scaleInfoViewModel: ScaleInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshViewInfo()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath {
        case cellAliasIndexPath:
            let cellHeight = getLabelHeight(text: scaleInfoViewModel.nameAliasFormatted, font: lblNameAlias.font)
            if cellHeight > MIN_CELL_SIZE {
                return cellHeight * 1.1
            }
        case cellCommentIndexPath:
            let cellHeight = getLabelHeight(text: scaleInfoViewModel.comment, font: txvComment.font!, width: txvComment.frame.width)

            return cellHeight * 1.22
        default:
            break
        }
        
        return MIN_CELL_SIZE
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension ScaleSubInfoTableViewController {
    
    func refreshViewInfo(isUpdated: Bool = false) {
        lblName.text = scaleInfoViewModel.name
        lblNameAlias.text = scaleInfoViewModel.nameAliasFormatted
        lblPattern.text = scaleInfoViewModel.ascendingPattern
        lblIntegerNotation.text = scaleInfoViewModel.ascendingIntegerNotation
        // lblPriority.text = (1...scaleInfoViewModel.defaultPriority).reduce("") { partialResult, _ in
        //     return partialResult + "★"
        // }
        
        let priority = scaleInfoViewModel.defaultPriority
        lblPriority.text = String(repeating: "★", count: priority) + String(repeating: "☆", count: 5 - priority)
        txvComment.text = scaleInfoViewModel.comment
        txvComment.sizeToFit()
        
        
        if isUpdated {
            tableView.reloadRows(at: [cellAliasIndexPath, cellCommentIndexPath], with: .none)
        }
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
