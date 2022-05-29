//
//  ScaleListTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import UIKit

class ScaleListTableViewController: UITableViewController {
    
    let scaleListViewModel = ScaleInfoListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        scaleListViewModel.handleDataReloaded = {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func barBtnActEdit(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            // Edit mode off
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            toggleStarRatingViewForCurrentVisibleCells(isEditing: false)
        } else {
            // Edit mode on
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            toggleStarRatingViewForCurrentVisibleCells(isEditing: true)
            
        }
    }
    
    @IBAction func barBnActAdd(_ sender: Any) {
        performSegue(withIdentifier: "CreateScaleInfoSegue", sender: nil)
    }
    
    // MARK: - Custome Methods
    func toggleStarRatingViewForCurrentVisibleCells(isEditing: Bool) {
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            let cell = tableView.cellForRow(at: indexPath) as! ScaleListCell
            cell.cosmosViewMyPriority.isHidden = isEditing
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scaleListViewModel.infoCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScaleListCell", for: indexPath) as? ScaleListCell else {
            return UITableViewCell()
        }

        guard let infoViewModel = scaleListViewModel.getScaleInfoViewModelOf(index: indexPath.row) else {
            return UITableViewCell()
        }
        cell.configure(infoViewModel: infoViewModel)
        
        if tableView.isEditing {
            cell.cosmosViewMyPriority.isHidden = true
        } else {
            cell.cosmosViewMyPriority.isHidden = false
        }

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // // Override to support editing the table view.
    // override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //     if editingStyle == .delete {
    //         // Delete the row from the data source
    //         // tableView.deleteRows(at: [indexPath], with: .fade)
    //         print("dlete")
    //     } else if editingStyle == .insert {
    //         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //     }
    // }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print(#function, indexPath)
        
        if tableView.isEditing {
            
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
                
                let cell = tableView.cellForRow(at: indexPath) as! ScaleListCell
                let entity = cell.infoViewModel.entity
                
                simpleDestructiveYesAndNo(self, message: "Do you want to delete? It cannot be recovered.", title: "Delete") { action in
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
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sender: [String: Any] = [
            "indexPath": indexPath,
            "viewModel": scaleListViewModel.getScaleInfoViewModelOf(index: indexPath.row)!
        ]
        performSegue(withIdentifier: "DetailViewSegue", sender: sender)
    }
    
    // // Override to support rearranging the table view.
    // override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    //
    // }
    //
    // // Override to support conditional rearranging of the table view.
    // override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    //     // Return false if you do not want the item to be re-orderable.
    //     return true
    // }

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
        
        cosmosViewMyPriority.settings.passTouchesToSuperview = false
        cosmosViewMyPriority.rating = Double(infoViewModel.priorityForDisplayBoth)
    }
}
