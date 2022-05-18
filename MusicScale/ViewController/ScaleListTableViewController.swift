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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let service = ScaleInfoCDService.shared
        do {
            try service.deleteAllCoreData()
            getSampleScaleDataFromLocal { infoList in
                for info in infoList {
                    try service.saveCoreData(scaleInfo: info)
                }
            }
        } catch {
            print(error)
        }
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

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
        return true
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
        performSegue(withIdentifier: "DetailViewSegue", sender: scaleInfoViewModel.getScaleInfoViewModelOf(index: indexPath.row))
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
            guard let receivedInfoViewModel = sender as? ScaleInfoViewModel else {
                return
            }
            scaleInfoVC?.scaleInfoViewModel = receivedInfoViewModel
            
        default:
            break
        }
    }
}

class ScaleListCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameAlias: UILabel!
    
    func configure(infoViewModel: ScaleInfoViewModel) {
        lblName.text = infoViewModel.name
        lblNameAlias.text = infoViewModel.nameAlias
    }
}
