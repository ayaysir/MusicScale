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
    
    weak var delegate: ScaleSubInfoTVCDelegate?
    
    var scaleInfoViewModel: ScaleInfoViewModel!
    var priorityDropDown = DropDown()
    let starRatingVM = StarRatingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDropDownOnPriorityLabel()
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
        
        let fillColor: UIColor = {
            if scaleInfoViewModel.isPriorityCustomized {
                return .orange
            }
            return .systemGray3
        }()
        lblPriority.attributedText = starRatingVM.starTextAttributedStr(fillCount: scaleInfoViewModel.priorityForDisplayBoth, fillColor: fillColor)
        
        
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

struct StarRatingViewModel {
    
    let dataSource: [String] = [
        "★★★★★",
        "★★★★",
        "★★★",
        "★★",
        "★",
    ]
    
    func countStarText(_ starText: String) -> Int {
        return starText.count
    }
    
    func starTextWithBlankStars(fillCount: Int) -> String {
        return String(repeating: "★", count: fillCount) + String(repeating: "☆", count: 5 - fillCount)
    }
    
    func starTextAttributedStr(fillCount: Int, fillColor: UIColor = .orange) -> NSMutableAttributedString {
        
        let starTextAttr = NSMutableAttributedString(string: String(repeating: "★", count: 5))
        
        var strokeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.orange,
            .foregroundColor: fillColor,
            .strokeWidth: -1.25,
            .font: UIFont.systemFont(ofSize: 15),
        ]
        starTextAttr.addAttributes(strokeTextAttributes, range: NSRange(location: 0, length: fillCount))
        
        strokeTextAttributes[.foregroundColor] = UIColor.clear
        starTextAttr.addAttributes(strokeTextAttributes, range: NSRange(location: fillCount, length: 5 - fillCount))
        
        return starTextAttr
    }
}
