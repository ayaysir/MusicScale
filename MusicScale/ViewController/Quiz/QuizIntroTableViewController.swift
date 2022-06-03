//
//  QuizIntroTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/02.
//

import UIKit

class QuizIntroTableViewController: UITableViewController {
    
    let selectKeyTitle = "Select the keys..."
    let selectScaleTitle = "Select the scales..."
    let selectedCountText = "(#count# selected)"
    
    var quizStore = QuizConfigStore.shared

    @IBOutlet weak var lblSelectKeys: UILabel!
    @IBOutlet weak var lblSelectScaleList: UILabel!
    @IBOutlet weak var cellAscending: UITableViewCell!
    @IBOutlet weak var cellDescending: UITableViewCell!
    
    let ascCellIndexPath = IndexPath(row: 0, section: 3)
    let descCellIndexPath = IndexPath(row: 1, section: 3)
    let selectScaleCellIndexPath = IndexPath(row: 0, section: 1)
    
    override func viewWillAppear(_ animated: Bool) {
        
        // key count
        updateKeyCountLabel(quizStore.availableKeys.count)
        
        // order state
        if quizStore.ascSelected {
            cellAscending.accessoryType = .checkmark
        }
        
        if quizStore.descSelected {
            cellDescending.accessoryType = .checkmark
        }
        
        // scale count
        updateScaleCountLabel(quizStore.selectedScaleInfoId.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath == ascCellIndexPath || indexPath == descCellIndexPath {
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
            
            let newState = cell.accessoryType == .checkmark
            
            if indexPath == ascCellIndexPath {
                quizStore.ascSelected = newState
            } else {
                quizStore.descSelected = newState
            }
            
            cell.isSelected = false
        }
        
        if indexPath == selectScaleCellIndexPath {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let scaleListVC = storyboard.instantiateViewController(withIdentifier: "ScaleListTableViewController") as! ScaleListTableViewController
            scaleListVC.mode = .quizSelect
            scaleListVC.quizDelegate = self
            navigationController?.pushViewController(scaleListVC, animated: true)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "SelectKeySegue":
            let keyVC = segue.destination as! QuizSelectKeyTableViewController
            keyVC.delegate = self
        default:
            break
        }
    }
}

// MARK: - QuizSelectKeyTVCDelegate
extension QuizIntroTableViewController: QuizSelectKeyTVCDelegate {
    
    func didUpdated(_ controller: QuizSelectKeyTableViewController, newCount: Int) {
        updateKeyCountLabel(newCount)
    }
    
    func updateKeyCountLabel(_ count: Int){
        lblSelectKeys.text = selectKeyTitle + " " + selectedCountText.replacingOccurrences(of: "#count#", with: "\(count)")
    }
}

// MARK: - ScaleListTVCDelegate
extension QuizIntroTableViewController: ScaleListTVCDelegate {
    
    func didQuizListSubmitted(_ controller: ScaleListTableViewController, newCount: Int) {
        updateScaleCountLabel(newCount)
    }
    
    func updateScaleCountLabel(_ count: Int) {
        lblSelectScaleList.text = selectScaleTitle + " " + selectedCountText.replacingOccurrences(of: "#count#", with: "\(count)")
    }
}
