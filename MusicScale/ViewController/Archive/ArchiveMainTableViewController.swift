//
//  ArchiveMainTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import UIKit

class ArchiveMainTableViewController: UITableViewController {
    
    let firebaseManager = FirebaseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.signInAnonymously { user in
            
            let scaleInfo = ScaleInfo(id: UUID(), name: "test", nameAlias: "testalias", degreesAscending: "1 2 3", degreesDescending: "3 2 1", defaultPriority: 5, comment: "fff\nfff", links: "", isDivBy12Tet: true, displayOrder: 10, myPriority: 3, createdDate: Date(), modifiedDate: Date(), groupName: "")
            let request = PostCreateRequest(scaleInfo: scaleInfo)
            self.firebaseManager.addPost(postRequest: request, completionHandler: nil, errorHandler: nil)
            
            self.firebaseManager.deletePost(documentID: "2Gs9rT8W2C0QXTKPfRlf")
        }
    }
    
    @IBAction func barBtnActUpload(_ sender: Any) {
        performSegue(withIdentifier: "ArchiveDetailSegue", sender: ArchiveDetailTableViewController.CRUDMode.create)
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)

        // Configure the cell...

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
