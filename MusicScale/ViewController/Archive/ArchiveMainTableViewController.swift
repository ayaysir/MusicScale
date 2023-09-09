//
//  ArchiveMainTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import UIKit

class ArchiveMainTableViewController: UITableViewController {
    
    @IBOutlet weak var barBtnAddDummy: UIBarButtonItem!
    
    var viewModel: PostListViewModel!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchCategoryList: [SearchCategory] = []
    var isFiltering: Bool {
        let isActive = searchController.isActive
        let isSearchBarHasText = searchController.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if viewModel == nil {
            viewModel = PostListViewModel()
            
            // check network status
            if Reachability.isConnectedToNetwork() {
                showLoadingSpinner()
            }
            
            viewModel.bindHandler = {
                print("load success", self.viewModel.filteredCount)
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.hideLoadingSpinner()
            }
            viewModel.likeCountsBindHandler = {
                self.tableView.reloadData()
            }
            viewModel.changeOrderHandler = {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TrackingTransparencyPermissionRequest()
        
        barBtnAddDummy.title = ""
        barBtnAddDummy.isEnabled = false
        
        searchInit()
        
        if !Reachability.isConnectedToNetwork() {
            simpleAlert(self, message: "No internet connection.".localized())
            SwiftSpinner.hide()
        }
    }
    
    private struct ArchiveDetailSegueSender {
        var mode: ArchiveDetailTableViewController.CRUDMode
        var object: Any?
    }
    
    @IBAction func barBtnActUpload(_ sender: Any) {
        performSegue(withIdentifier: "ArchiveDetailSegue", sender: ArchiveDetailSegueSender(mode: .create, object: nil))
    }
    
    @IBAction func barBtnAddDummy(_ sender: Any) {
        let uuid = UUID()
        let scaleInfo = ScaleInfo(id: uuid, name: uuid.uuidString, nameAlias: uuid.uuidString, degreesAscending: "1 2 3 4 5 6 7", degreesDescending: "", defaultPriority: 3, comment: uuid.uuidString, links: "", isDivBy12Tet: true, displayOrder: 3, myPriority: 0, createdDate: Date(), modifiedDate: Date(), groupName: "gro1")
        let post = Post(scaleInfo: scaleInfo)
        FirebasePostManager.shared.addPost(postRequest: post, completionHandler: nil, errorHandler: nil)
    }
    
    @IBAction func barBtnActSort(_ sender: UIBarButtonItem) {
        
        let ascText = "Ascending by upload date".localized()
        let descText = "Descending by upload date".localized()
        let currentText = "current_sort".localized()
        let currentWithBracket = "(\(currentText)"
        
        let actionTitles = [
            "\(ascText) \(viewModel.isDescending ? "" : currentWithBracket)",
            "\(descText) \(viewModel.isDescending ? currentWithBracket : "")",
        ]
        let rect = sender.frame
        
        simpleActionSheets(self, actionTitles: actionTitles, actionStyles: nil, title: "Sort Order".localized(), message: "", sourceView: nil, sourceRect: rect) { actionIndex in
            
            if self.viewModel.isDescending != (actionIndex == 1) {
                self.viewModel.isDescending = actionIndex != 0
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        
        let postVM = viewModel.postViewModel(at: indexPath.row)
        cell.configure(postViewModel: postVM)
        cell.configureLikeInfo(likeCounts: viewModel.likeInfo(documentID: postVM.documentID))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sender = ArchiveDetailSegueSender(mode: .read, object: viewModel.postViewModel(at: indexPath.row))
        performSegue(withIdentifier: "ArchiveDetailSegue", sender: sender)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if AdsManager.SHOW_AD {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            setupBannerAds(self, container: footerView)
            return footerView
        }
        
        return super.tableView(tableView, viewForFooterInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return AdsManager.SHOW_AD ? 50 : super.tableView(tableView, heightForFooterInSection: section)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ArchiveDetailSegue":
            let detailVC = segue.destination as! ArchiveDetailTableViewController
            let sender = sender as! ArchiveDetailSegueSender
            detailVC.mode = sender.mode
            
            if sender.mode == .read {
                let postVM = sender.object as! PostViewModel
                detailVC.postViewModel = postVM
            }
        default:
            break
        }
    }
    
    // MARK: - Custom methods
    
    func searchInit() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchCategoryList = SearchCategory.allCases
        searchController.searchBar.scopeButtonTitles = SearchCategory.allCases.map { $0.textValue }
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        // self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func showLoadingSpinner() {
        if let currentClassInstance = UIApplication.topViewController(), currentClassInstance == self {
            SwiftSpinner.show("Loading data...".localized())
        }
    }
    
    func hideLoadingSpinner() {
        if let currentClassInstance = UIApplication.topViewController(), currentClassInstance == self {
            SwiftSpinner.hide()
        }
    }

}

extension ArchiveMainTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchCategory = searchCategoryList[searchController.searchBar.selectedScopeButtonIndex]
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.filter(searchText: searchText, searchCategory: searchCategory)
    }
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAliases: UILabel!
    @IBOutlet weak var lblUploadDate: UILabel!
    @IBOutlet weak var progressLikeDislike: UIProgressView!
    
    private let COLOR_LIKE: UIColor = .systemGreen
    private let COLOR_DISLIKE: UIColor = .systemPink
    private let COLOR_NONE: UIColor = .systemGray3
    
    private(set) var postViewModel: PostViewModel!
    
    override func prepareForReuse() {
        
    }
    
    func configure(postViewModel: PostViewModel) {
        self.postViewModel = postViewModel
        
        lblTitle.text = postViewModel.name
        lblAliases.text = postViewModel.alias
        lblUploadDate.text = postViewModel.relativeCreatedTimeStr ?? ""
        
    }
    
    func configureLikeInfo(likeCounts: LikeCounts?) {
        
        if likeCounts == nil || likeCounts?.totalCount == 0 {
            progressLikeDislike.progressTintColor = COLOR_NONE
            progressLikeDislike.trackTintColor = COLOR_NONE
            progressLikeDislike.setProgress(0.5, animated: false)
        } else {
            progressLikeDislike.progressTintColor = COLOR_DISLIKE
            progressLikeDislike.trackTintColor = COLOR_LIKE
            progressLikeDislike.setProgress(Float(likeCounts!.dislikePercent), animated: false)
        }
    }
}
