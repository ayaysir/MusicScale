//
//  ArchiveMainTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import UIKit

class ArchiveMainTableViewController: UITableViewController {
    
    var viewModel: PostListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        SwiftSpinner.show("Connecting \nto server...")
        viewModel = PostListViewModel()
        viewModel.bindHandler = {
            print("load success", self.viewModel.posts.count)
            self.tableView.reloadData()
            SwiftSpinner.hide()
        }
        
    }
    
    @IBAction func barBtnActUpload(_ sender: Any) {
        performSegue(withIdentifier: "ArchiveDetailSegue", sender: ArchiveDetailTableViewController.CRUDMode.create)
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }

        cell.configure(post: viewModel.posts[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ArchiveDetailSegue", sender: ArchiveDetailTableViewController.CRUDMode.read)
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
            let mode = sender as! ArchiveDetailTableViewController.CRUDMode
            detailVC.mode = mode
        default:
            break
        }
    }

}

extension ArchiveMainTableViewController {
    
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAliases: UILabel!
    @IBOutlet weak var lblUploadDate: UILabel!
    @IBOutlet weak var progressLikeDislike: UIProgressView!
    
    override func prepareForReuse() {
        
    }
    
    func configure(post: Post) {
        lblTitle.text = post.scaleInfo.name
        lblAliases.text = post.scaleInfo.nameAlias
        
    }
}

