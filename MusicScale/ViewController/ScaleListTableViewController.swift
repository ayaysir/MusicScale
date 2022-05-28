//
//  ScaleListTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import UIKit

class ScaleListTableViewController: UITableViewController {
    
    let scaleInfoViewModel = ScaleInfoListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scaleInfoViewModel.infoCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScaleListCell", for: indexPath) as? ScaleListCell else {
            return UITableViewCell()
        }

        guard let infoViewModel = scaleInfoViewModel.getScaleInfoViewModelOf(index: indexPath.row) else {
            return UITableViewCell()
        }
        cell.configure(infoViewModel: infoViewModel)

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sender: [String: Any] = [
            "indexPath": indexPath,
            "viewModel": scaleInfoViewModel.getScaleInfoViewModelOf(index: indexPath.row)!
        ]
        performSegue(withIdentifier: "DetailViewSegue", sender: sender)
    }

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
            
        default:
            break
        }
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

// MARK: - ScaleListCell
class ScaleListCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameAlias: UILabel!
    @IBOutlet weak var cosmosViewMyPriority: CosmosView!
    
    override func prepareForReuse() {
        cosmosViewMyPriority.prepareForReuse()
    }
    
    func configure(infoViewModel: ScaleInfoViewModel) {
        lblName.text = infoViewModel.name
        lblNameAlias.text = infoViewModel.nameAlias
        
        cosmosViewMyPriority.settings.passTouchesToSuperview = false
        cosmosViewMyPriority.rating = Double(infoViewModel.priorityForDisplayBoth)
    }
}
