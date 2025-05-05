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
  func didCompareScaleChange(_ controller: ScaleSubInfoTableViewController, index: Int)
}

class ScaleSubInfoTableViewController: UITableViewController {
  
  let MIN_CELL_SIZE: CGFloat = 30.0
  
  // ======== SECTION & INDEXPATH ========
  private let cellAliasIndexPath = IndexPath(row: 1, section: 1)
  private let cellCommentIndexPath = IndexPath(row: 0, section: 2)
  
  private let cellAdBannerIndexPath = IndexPath(row: 1, section: 0)
  private let cellComparisonIndexPath = IndexPath(row: 0, section: 0)
  // ======================================
  
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblNameAlias: UILabel!
  @IBOutlet weak var lblPriority: UILabel!
  @IBOutlet weak var lblPattern: UILabel!
  @IBOutlet weak var lblIntegerNotation: UILabel!
  @IBOutlet weak var txvComment: UITextView!
  @IBOutlet weak var tblCellNameAlias: UITableViewCell!
  @IBOutlet weak var lblDegreesAsc: UILabel!
  @IBOutlet weak var viewBannerAdsContainer: UIView!
  @IBOutlet weak var segCompareList: UISegmentedControl!
  
  weak var delegate: ScaleSubInfoTVCDelegate?
  
  var scaleInfoViewModel: ScaleInfoViewModel!
  
  var priorityDropDown = DropDown()
  let starRatingVM = StarRatingViewModel()
  
  // 한 개만 보여주는 모드인지, 여러 개 보여주는 모드인지?
  var comparisonViewModel: ScaleComparisonViewModel? {
    didSet {
      changeSegmentListForComparison()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initDropDownOnPriorityLabel()
    refreshViewInfo()
    
    DispatchQueue.main.async {
      // 광고
      setupBannerAds(self, container: self.viewBannerAdsContainer)
      
      self.txvComment.layoutIfNeeded()
      self.tableView.reloadData()
    }
  }
  
  // MARK: - @IBActions
  
  @IBAction func segActChangeScale(_ sender: UISegmentedControl) {
    delegate?.didCompareScaleChange(self, index: sender.selectedSegmentIndex)
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
      
      return UITableView.automaticDimension
    case cellComparisonIndexPath:
      if !isMultipleInfoMode() {
        return 0
      }
    default:
      break
    }
    
    return originalSize
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch section {
    case cellAdBannerIndexPath.section:
      if !AdsManager.SHOW_AD && !isMultipleInfoMode() {
        return 0
      } else if !AdsManager.SHOW_AD && isMultipleInfoMode() {
        return 1
      }
    default:
      break
    }
    
    return super.tableView(tableView, numberOfRowsInSection: section)
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case cellAdBannerIndexPath.section:
      if !AdsManager.SHOW_AD && !isMultipleInfoMode() {
        return 0.1
      }
    default:
      break
    }
    
    return super.tableView(tableView, heightForHeaderInSection: section)
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    switch section {
    case cellAdBannerIndexPath.section:
      if !AdsManager.SHOW_AD && !isMultipleInfoMode() {
        return 0.1
      }
    default:
      break
    }
    
    return super.tableView(tableView, heightForFooterInSection: section)
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
  }
  
}

// MARK: - Custom Methods
extension ScaleSubInfoTableViewController {
  
  func isMultipleInfoMode() -> Bool {
    guard let comparisonViewModel = comparisonViewModel else {
      return false
    }
    
    return comparisonViewModel.isComparisonAllowed
  }
  
  func changeSegmentListForComparison() {
    guard let comparisonViewModel = comparisonViewModel else {
      return
    }
    
    segCompareList.replaceSegments(segments: comparisonViewModel.totalSegmentVMsName)
    segCompareList.selectedSegmentIndex = 0
    
    tableView.reloadData()
  }
  
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
      self.lblPriority.attributedText =  self.starRatingVM.starTextAttributedStr(fillCount: rating)
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
    DispatchQueue.main.async { [unowned self] in
      
      lblName.text = scaleInfoViewModel.name
      lblNameAlias.text = scaleInfoViewModel.nameAliasFormatted
      lblPattern.text = scaleInfoViewModel.ascendingPattern
      lblIntegerNotation.text = scaleInfoViewModel.ascendingIntegerNotation
      lblDegreesAsc.text = scaleInfoViewModel.degreesAscending
      
      let fillColor: UIColor = scaleInfoViewModel.isPriorityCustomized ? .orange : .systemGray3
      lblPriority.attributedText = starRatingVM.starTextAttributedStr(fillCount: scaleInfoViewModel.priorityForDisplayBoth, fillColor: fillColor)
      
      txvComment.text = scaleInfoViewModel.comment
      // txvComment.sizeToFit()
      // txvComment.frame.size.width = originalCommentWidth
      
      if isUpdated {
        tableView.reloadRows(at: [cellAliasIndexPath, cellCommentIndexPath], with: .none)
      }
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
