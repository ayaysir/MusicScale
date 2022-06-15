//
//  ScaleSubInfoTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import UIKit
import DropDown

protocol ScaleSubInfoTVCDelegate: AnyObject {
    func didMyPriorityUpdated(_ controller: ScaleSubInfoTableViewController, viewModel: ScaleInfoViewModel)
}

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
    @IBOutlet weak var lblDegreesAsc: UILabel!
    
    weak var delegate: ScaleSubInfoTVCDelegate?
    
    var scaleInfoViewModel: ScaleInfoViewModel!
    var priorityDropDown = DropDown()
    let starRatingVM = StarRatingViewModel()
    
    private var originalCommentWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalCommentWidth = txvComment.frame.size.width
        
        initDropDownOnPriorityLabel()
        refreshViewInfo()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let originalSize = super.tableView(tableView, heightForRowAt: indexPath)
        
        switch indexPath {
        case cellAliasIndexPath:
            let aliasCount = scaleInfoViewModel.nameAlias.components(separatedBy: ";").count
            if aliasCount <= 1 {
                return originalSize
            }
            let cellHeight = getLabelHeight(text: scaleInfoViewModel.nameAliasFormatted, font: lblNameAlias.font)
            if cellHeight > MIN_CELL_SIZE {
                return cellHeight + 10
            }
        case cellCommentIndexPath:
            if scaleInfoViewModel.comment == "" {
                return 0
            }
            
            return txvComment.frame.height
        default:
            break
        }
        
        return originalSize
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

// MARK: - Custom Methods
extension ScaleSubInfoTableViewController {
    
    func initDropDownOnPriorityLabel() {
        
        let labelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelPriorityAction))
        lblPriority.addGestureRecognizer(labelTapRecognizer)
        
        priorityDropDown.dataSource = starRatingVM.dataSource
        priorityDropDown.cornerRadius = 10
        priorityDropDown.anchorView = lblPriority
        
        priorityDropDown.bottomOffset = CGPoint(x: -40, y: 0)
        priorityDropDown.selectionAction = { index, item in
            
            let rating = item.count
            print(item, rating)
            self.lblPriority.attributedText = self.starRatingVM.starTextAttributedStr(fillCount: rating)
            self.scaleInfoViewModel.updateMyPriority(rating)
            
            if let delegate = self.delegate {
                delegate.didMyPriorityUpdated(self, viewModel: self.scaleInfoViewModel)
            }
        }
    }
    
    @objc func labelPriorityAction(sender: UITapGestureRecognizer) {
        priorityDropDown.show()
    }
    
    func refreshViewInfo(isUpdated: Bool = false) {
        lblName.text = scaleInfoViewModel.name
        lblNameAlias.text = scaleInfoViewModel.nameAliasFormatted
        lblPattern.text = scaleInfoViewModel.ascendingPattern
        lblIntegerNotation.text = scaleInfoViewModel.ascendingIntegerNotation
        lblDegreesAsc.text = scaleInfoViewModel.degreesAscending
        
        let fillColor: UIColor = scaleInfoViewModel.isPriorityCustomized ? .orange : .systemGray3
        lblPriority.attributedText = starRatingVM.starTextAttributedStr(fillCount: scaleInfoViewModel.priorityForDisplayBoth, fillColor: fillColor)
        
        txvComment.text = scaleInfoViewModel.comment
        txvComment.sizeToFit()
        txvComment.frame.size.width = originalCommentWidth
        
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
