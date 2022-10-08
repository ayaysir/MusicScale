//
//  ScaleListTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import UIKit
import PanModal

protocol ScaleListQuizDelegate: AnyObject {
    func didQuizListSubmitted(_ controller: ScaleListTableViewController, newCount: Int)
}

protocol ScaleListUploadDelegate: AnyObject {
    func didUploadScaleSelected(_ controller: ScaleListTableViewController, infoViewModel: ScaleInfoViewModel)
}

class ScaleListTableViewController: UITableViewController {
    
    @IBOutlet weak var barBtnEdit: UIBarButtonItem!
    @IBOutlet weak var barBtnAdd: UIBarButtonItem!
    
    let scaleListViewModel = ScaleInfoListViewModel()
    var quizViewModel: QuizViewModel!
    
    weak var quizDelegate: ScaleListQuizDelegate?
    weak var uploadDelegate: ScaleListUploadDelegate?
    
    enum ListMode {
        case main, quizSelect, uploadSelect
    }
    var mode: ListMode = .main
    
    lazy var sortVC: SortViewController & PanModalPresentable = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SortViewController") as! SortViewController
        vc.delegate = self
        return vc
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchCategoryList: [SearchCategory] = []
    var isFiltering: Bool {
        let isActive = searchController.isActive
        let isSearchBarHasText = searchController.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TrackingTransparencyPermissionRequest()
        
        searchInit()
        scaleListViewModel.handleDataReloaded = {
            self.tableView.reloadData()
        }
        
        switch mode {
        case .main:
            break
        case .quizSelect:
            barBtnEdit.isEnabled = false
            barBtnEdit.title = ""
            navigationItem.leftItemsSupplementBackButton = true
            
            changeSelectAllButtonTitle()
        case .uploadSelect:
            barBtnEdit.isEnabled = false
            barBtnEdit.title = ""
            navigationItem.leftItemsSupplementBackButton = true
            barBtnAdd.isEnabled = false
            barBtnAdd.title = ""
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    @objc func getNewEntityFromArchive(_ notification: Notification) {
        if let newEntity = notification.object as? ScaleInfoEntity {
            scaleListViewModel.addCreatedInfoToList(entity: newEntity)
            print(#function, "newEntity has received.")
        }
    }
    
    func changeSelectAllButtonTitle() {
        if mode == .quizSelect {
            let infoCount = scaleListViewModel.getInfoCount(isFiltering: isFiltering)
            if quizViewModel.idListCount == infoCount {
                barBtnAdd.title = "Deselect All".localized()
            } else {
                barBtnAdd.title = "Select All".localized()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .downloadedFromArchive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getNewEntityFromArchive(_:)), name: .downloadedFromArchive, object: nil)
        
        // NotificationCenter.default.removeObserver(self, name: .networkIsOffline, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(a), name: .networkIsOffline, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let quizDelegate = quizDelegate {
            quizDelegate.didQuizListSubmitted(self, newCount: quizViewModel.idListCount)
            quizViewModel.saveScaleListToConfigStore()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func barBtnActEdit(_ sender: UIBarButtonItem) {
        
        guard mode == .main else {
            return
        }
        
        if tableView.isEditing {
            // Edit mode off
            tableView.setEditing(false, animated: true)
            sender.title = "Edit".localized()
            toggleStarRatingViewForCurrentVisibleCells(isEditing: false)
        } else {
            // Edit mode on
            tableView.setEditing(true, animated: true)
            sender.title = "Done".localized()
            toggleStarRatingViewForCurrentVisibleCells(isEditing: true)
        }
    }
    
    @IBAction func barBtnActAdd(_ sender: UIBarButtonItem) {
        switch mode {
        case .main:
            performSegue(withIdentifier: "CreateScaleInfoSegue", sender: nil)
        case .quizSelect:
            // Select All
            let infoCount = scaleListViewModel.getInfoCount(isFiltering: isFiltering)
            if quizViewModel.idListCount == infoCount {
                deselectAllCell()
            } else {
                selectAllCell()
            }
        case .uploadSelect:
            break
        }
    }
    
    func selectAllCell() {
        guard mode == .quizSelect else { return }
        
        let count = scaleListViewModel.getInfoCount(isFiltering: isFiltering)
        for row in 0..<count {
            let infoVM = scaleListViewModel.getScaleInfoVM(isFiltering: isFiltering, index: row)
            if let id = infoVM?.id {
                quizViewModel.appendIdToScaleList(id)
            }
        }
        tableView.reloadData()
        changeSelectAllButtonTitle()
    }
    
    func deselectAllCell() {
        guard mode == .quizSelect else { return }
        
        let count = scaleListViewModel.getInfoCount(isFiltering: isFiltering)
        for row in 0..<count {
            let infoVM = scaleListViewModel.getScaleInfoVM(isFiltering: isFiltering, index: row)
            if let id = infoVM?.id {
                quizViewModel.removeId(id)
            }
        }
        if let first = scaleListViewModel.getScaleInfoVM(isFiltering: isFiltering, index: 0) {
            quizViewModel.appendIdToScaleList(first.id)
        }
        tableView.reloadData()
        changeSelectAllButtonTitle()
    }
    
    @IBAction func barBtnActSort(_ sender: Any) {
        self.presentPanModal(sortVC)
    }
    
    
    // MARK: - Custome Methods
    func searchInit() {
        self.navigationItem.searchController = searchController
        
        // iOS 14 이하 버전에서 검색 시 배경 흐려지는거 방지
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.scopeButtonTitles = SearchCategory.allCases.map { $0.textValue }
        searchCategoryList = SearchCategory.allCases
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        // self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func toggleStarRatingViewForCurrentVisibleCells(isEditing: Bool) {
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            let cell = tableView.cellForRow(at: indexPath) as! ScaleListCell
            cell.cosmosViewMyPriority.isHidden = isEditing
        }
    }
    
    func currentInfoViewModel(indexPath: IndexPath) -> ScaleInfoViewModel? {
        if isFiltering {
            return scaleListViewModel.getSearchedInfoViewModelOf(index: indexPath.row)
        } else {
            return scaleListViewModel.getScaleInfoViewModelOf(index: indexPath.row)
        }
    }
    
    func toggleCheckmark(of cell: ScaleListCell, isCheckmark: Bool) {
        let backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.2)
        
        cell.accessoryType = isCheckmark ? .checkmark : .none
        cell.cosmosViewMyPriority.isHidden = isCheckmark
        cell.backgroundColor = isCheckmark ? backgroundColor : .clear
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !isFiltering ? scaleListViewModel.infoCount : scaleListViewModel.searchInfoCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScaleListCell", for: indexPath) as? ScaleListCell else {
            return UITableViewCell()
        }
        
        let infoViewModel: ScaleInfoViewModel? = {
            if isFiltering {
                return scaleListViewModel.getSearchedInfoViewModelOf(index: indexPath.row)
            } else {
                return  scaleListViewModel.getScaleInfoViewModelOf(index: indexPath.row)
            }
            
        }()
        
        guard let infoViewModel = infoViewModel else {
            return UITableViewCell()
        }
        
        cell.configure(infoViewModel: infoViewModel)
        cell.cosmosViewMyPriority.isHidden = tableView.isEditing ? true : false
        
        if mode == .quizSelect {
            cell.selectionStyle = .none
            let containsId = quizViewModel.containsId(infoViewModel.id)
            toggleCheckmark(of: cell, isCheckmark: containsId)
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if tableView.isEditing {
            
            let delete = UIContextualAction(style: .destructive, title: "Delete".localized()) { (action, sourceView, completionHandler) in
                
                let cell = tableView.cellForRow(at: indexPath) as! ScaleListCell
                let entity = cell.infoViewModel.entity
                
                simpleDestructiveYesAndNo(self, message: "Do you want to delete? It cannot be recovered.".localized(), title: "Delete".localized()) { action in
                    self.scaleListViewModel.deleteScaleInfo(entity: entity)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    completionHandler(true)
                }
            }
            
            let swipeAction = UISwipeActionsConfiguration(actions: [delete])
            swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
            return swipeAction
        } else {
            let config = UISwipeActionsConfiguration()
            config.performsFirstActionWithFullSwipe = false
            return config
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentViewModel = currentInfoViewModel(indexPath: indexPath)!
        
        switch mode {
        case .main:
            let sender: [String: Any] = [
                "indexPath": indexPath,
                "viewModel": currentViewModel
            ]
            performSegue(withIdentifier: "DetailViewSegue", sender: sender)
        case .quizSelect:
            
            let cell = tableView.cellForRow(at: indexPath) as! ScaleListCell
            let isSelected = cell.accessoryType == .checkmark
            
            if isSelected {
                if quizViewModel.idListCount <= 1 {
                    simpleAlert(self, message: "At least one scale must be selected.".localized())
                    return
                }
                
                quizViewModel.removeId(currentViewModel.id)
                toggleCheckmark(of: cell, isCheckmark: false)
            } else {
                quizViewModel.appendIdToScaleList(currentViewModel.id)
                toggleCheckmark(of: cell, isCheckmark: true)
            }
            
            changeSelectAllButtonTitle()
        case .uploadSelect:
            if let uploadDelegate = uploadDelegate {
                uploadDelegate.didUploadScaleSelected(self, infoViewModel: currentViewModel)
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        print(fromIndexPath, to)
        let fromEntity = (tableView.cellForRow(at: fromIndexPath) as! ScaleListCell).infoViewModel.entity
        
        scaleListViewModel.changeOrder(from: fromEntity, toIndex: to)
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        if SortFilterConfigStore.shared.currentState == .displayOrder {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if AdsManager.SHOW_AD {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            setupBannerAds(self, container: view)
            return view
        }
        
        return super.tableView(tableView, viewForFooterInSection: section)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return AdsManager.SHOW_AD ? 50 : super.tableView(tableView, heightForFooterInSection: section)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "DetailViewSegue":
            let scaleInfoVC = segue.destination as? ScaleInfoViewController
            let sender = sender as! [String: Any]
            scaleInfoVC?.selectedIndexPath = sender["indexPath"] as? IndexPath
            guard let receivedInfoViewModel = sender["viewModel"] as? ScaleInfoViewModel else {
                return
            }
            scaleInfoVC?.scaleInfoViewModel = receivedInfoViewModel
            scaleInfoVC?.delegate = self
        case "CreateScaleInfoSegue":
            let createVC = segue.destination as! ScaleInfoUpdateTableViewController
            createVC.mode = .create
            createVC.createDelegate = self
        default:
            break
        }
    }
}

// MARK: - UISearchBarDelegate, UISearchResultsUpdating
extension ScaleListTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchCategory = searchCategoryList[searchController.searchBar.selectedScopeButtonIndex]
        guard let searchText = searchController.searchBar.text else { return }
        scaleListViewModel.search(searchText: searchText, searchCategory: searchCategory)
    }
}

// MARK: - ScaleInfoVCDelgate
extension ScaleListTableViewController: ScaleInfoVCDelgate {
    
    func didInfoUpdated(_ controller: ScaleInfoViewController, indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            tableView.reloadData()
            return
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - ScaleInfoUpdateTVCDelegate
extension ScaleListTableViewController: ScaleInfoUpdateTVCDelegate {
    
    func didFinishedCreate(_ controller: ScaleInfoUpdateTableViewController, entity: ScaleInfoEntity) {
        scaleListViewModel.addCreatedInfoToList(entity: entity)
        tableView.reloadData()
    }
}

// MARK: - SortVCDelegate
extension ScaleListTableViewController: SortVCDelegate {
    
    func didSortDone(_ controller: SortViewController, sortInfo: SortInfo) {
        
        // 검색중엔 정렬 버튼이 안나옴
        // searchController.searchBar.text = ""
        // searchController.resignFirstResponder()
        // scaleListViewModel.resetSearch()
        
        switch sortInfo.state {
        case .none:
            break
        case .displayOrder:
            scaleListViewModel.orderByUserSequence()
        case .name:
            scaleListViewModel.orderByNameDisplayOrder(order: sortInfo.order)
        case .priority:
            scaleListViewModel.orderByDisplayedPriority(order: sortInfo.order)
        }
    }
}

// MARK: - ScaleListCell
class ScaleListCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameAlias: UILabel!
    @IBOutlet weak var cosmosViewMyPriority: CosmosView!
    
    private(set) var infoViewModel: ScaleInfoViewModel!
    
    override func prepareForReuse() {
        cosmosViewMyPriority.prepareForReuse()
    }
    
    func configure(infoViewModel: ScaleInfoViewModel) {
        
        self.infoViewModel = infoViewModel
        
        lblName.text = infoViewModel.name
        lblNameAlias.text = infoViewModel.nameAlias
        
        if infoViewModel.myPriority <= 0 {
            cosmosViewMyPriority.filledColor = .systemGray3
        } else {
            cosmosViewMyPriority.filledColor = .orange
        }
        
        cosmosViewMyPriority.settings.passTouchesToSuperview = false
        cosmosViewMyPriority.rating = Double(infoViewModel.priorityForDisplayBoth)
        
        cosmosViewMyPriority.didTouchCosmos = { rating in
            self.cosmosViewMyPriority.filledColor = .orange
        }
        cosmosViewMyPriority.didFinishTouchingCosmos = { rating in
            infoViewModel.updateMyPriority(Int(rating))
        }
    }
    
    func changeAccesoryType(_ type: UITableViewCell.AccessoryType) {
        self.accessoryType = type
    }
}
