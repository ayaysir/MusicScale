//
//  QuizIntroTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/02.
//

import UIKit

class QuizIntroTableViewController: UITableViewController {
    
    let selectedCountText = "#count# selected"
    
    var quizStore = QuizConfigStore.shared
    var quizViewModel = QuizViewModel()

    @IBOutlet weak var lblSelectKeys: UILabel!
    @IBOutlet weak var lblSelectScaleList: UILabel!
    @IBOutlet weak var lblSelectScalesDetail: UILabel!
    @IBOutlet weak var lblSelectKeysDetail: UILabel!
    @IBOutlet weak var lblNumOfQuestDetail: UILabel!
    @IBOutlet weak var lblTypeOfQuestDetail: UILabel!
    @IBOutlet weak var lblEnharmonicModeDetail: UILabel!
    
    @IBOutlet weak var cellAscending: UITableViewCell!
    @IBOutlet weak var cellDescending: UITableViewCell!
    
    let ascCellIndexPath = IndexPath(row: 0, section: 3)
    let descCellIndexPath = IndexPath(row: 1, section: 3)
    let selectScaleCellIndexPath = IndexPath(row: 0, section: 1)
    
    let numbOfQuestIndexPath = IndexPath(row: 0, section: 0)
    let typeOfQuestIndexPath = IndexPath(row: 1, section: 0)
    let enharmonicModeIndexPath = IndexPath(row: 2, section: 0)
    
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
        
        // numberOfQuestions
        lblNumOfQuestDetail.text = quizViewModel.numOfQuestText(from:  quizStore.numberOfQuestions)
        
        // typesOfQuestions
        lblTypeOfQuestDetail.text = quizStore.typeOfQuestions.titleValue
        
        // enharmonic Mode
        lblEnharmonicModeDetail.text = quizStore.enharmonicMode.titleValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnActStartQuiz(_ sender: UIButton) {
        quizViewModel.questionList.forEach { print($0) }
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
            scaleListVC.quizViewModel = quizViewModel
            navigationController?.pushViewController(scaleListVC, animated: true)
        }
        
        if indexPath == numbOfQuestIndexPath {
            let actionTitles = quizViewModel.numOfQuestTexts
            simpleActionSheets(self, actionTitles: actionTitles, title: "Number of Questions") { actionIndex in
                let number = self.quizViewModel.numberOfQuestions(of: actionIndex)
                self.quizStore.numberOfQuestions = number
                self.lblNumOfQuestDetail.text = actionTitles[actionIndex]
            }
        }
        
        if indexPath == typeOfQuestIndexPath {
            let actionTitles = quizViewModel.typeOfQuestions.map { $0.titleValue }
            simpleActionSheets(self, actionTitles: actionTitles, title: "Types of Questions", message: "") { [self] actionIndex in
                if let type = QuizType.init(rawValue: actionIndex) {
                    quizStore.typeOfQuestions = type
                    lblTypeOfQuestDetail.text = type.titleValue
                }
            }
        }
        
        if indexPath == enharmonicModeIndexPath {
            let actionTitles = EnharmonicMode.titleValues
            simpleActionSheets(self, actionTitles: actionTitles, title: "Select Enharmonic Mode", message: "") { actionIndex in
                guard let mode = EnharmonicMode(rawValue: actionIndex) else {
                    return
                }
                self.quizStore.enharmonicMode = mode
                self.lblEnharmonicModeDetail.text = mode.titleValue
            }
        }
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
        lblSelectKeysDetail.text =  selectedCountText.replacingOccurrences(of: "#count#", with: "\(count)")
    }
}

// MARK: - ScaleListTVCDelegate
extension QuizIntroTableViewController: ScaleListTVCDelegate {
    
    func didQuizListSubmitted(_ controller: ScaleListTableViewController, newCount: Int) {
        updateScaleCountLabel(newCount)
    }
    
    func updateScaleCountLabel(_ count: Int) {
        lblSelectScalesDetail.text = selectedCountText.replacingOccurrences(of: "#count#", with: "\(count)")
    }
}
