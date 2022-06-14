//
//  ArchiveMainTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import UIKit

class ArchiveMainTableViewController: UITableViewController {
    
    var viewModel: PostListViewModel!
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(Date().timeIntervalSince1970 * 1000)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if viewModel == nil {
            showLoadingSpinner()
            viewModel = PostListViewModel()
            viewModel.bindHandler = {
                print("load success", self.viewModel.posts.count)
                self.tableView.reloadData()
                self.hideLoadingSpinner()
            }
            viewModel.likeCountsBindHandler = {
                self.tableView.reloadData()
            }
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
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
    
    func showLoadingSpinner() {
        if let currentClassInstance = UIApplication.topViewController(), currentClassInstance == self {
            SwiftSpinner.show("Loading...")
        }
    }
    
    func hideLoadingSpinner() {
        if let currentClassInstance = UIApplication.topViewController(), currentClassInstance == self {
            SwiftSpinner.hide()
        }
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {

        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)

        // Sets loading text
        loadingLabel.textColor = .red
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)

        // Sets spinner
        spinner.style = .medium
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()

        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        // loadingView.backgroundColor = .black.withAlphaComponent(0.2)
        // loadingView.layer.cornerRadius = 10
        
        
        // background color
        // let overlayView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 5000, height: 5000)))
        // overlayView.backgroundColor = .black
        // // overlayView.alpha = 0.4
        
        // navigationController?.view.addSubview(overlayView)
        
        tableView.addSubview(loadingView)
    }

    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {

        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true

    }

}

extension ArchiveMainTableViewController {
    
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
