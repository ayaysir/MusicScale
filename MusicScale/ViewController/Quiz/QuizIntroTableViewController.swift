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
    @IBOutlet weak var lblTypeOfQuestDetail: UILabel!
    @IBOutlet weak var lblEnharmonicModeDetail: UILabel!
    
    @IBOutlet weak var cellAscending: UITableViewCell!
    @IBOutlet weak var cellDescending: UITableViewCell!
    
    let ascCellIndexPath = IndexPath(row: 0, section: 3)
    let descCellIndexPath = IndexPath(row: 1, section: 3)
    let selectScaleCellIndexPath = IndexPath(row: 0, section: 1)
    let typeOfQuestIndexPath = IndexPath(row: 0, section: 0)
    let enharmonicModeIndexPath = IndexPath(row: 1, section: 0)
    let buttonSection: Int = 4
    
    let overlayView = UIView(frame: CGRect(origin: CGPoint(x: -100, y: -100), size: CGSize(width: 4000, height: 4000)))
    let overlayViewTag: Int = 85843945
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 기존 저장 LeitnerSystem 오브젝트가 있는 경우 리다리렉트
        if quizStore.savedLeitnerSystem != nil {
            let inProgressVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuizInProgressViewController") as! QuizInProgressViewController
            inProgressVC.quizViewModel = quizViewModel
            inProgressVC.introVC = self
            navigationController?.setViewControllers([inProgressVC], animated: false)
            return
        }
        
        if let viewWithTag = view.viewWithTag(overlayViewTag) {
            viewWithTag.removeFromSuperview()
        }
        
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
        
        // typesOfQuestions
        lblTypeOfQuestDetail.text = quizStore.typeOfQuestions.titleValue
        
        // enharmonic Mode
        lblEnharmonicModeDetail.text = quizStore.enharmonicMode.titleValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnActStartQuiz(_ sender: UIButton) {
        
        guard quizStore.ascSelected || quizStore.descSelected else {
            simpleAlert(self, message: "You must select at least one of Ascending and Descending order.")
            return
        }
        
        guard quizStore.selectedScaleInfoId.count > 0 else {
            simpleAlert(self, message: "You must select at least one target scale.")
            return
        }
        
        quizViewModel.refreshQuestionList()
        
        let inProgressVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuizInProgressViewController") as! QuizInProgressViewController
        inProgressVC.quizViewModel = quizViewModel
        inProgressVC.introVC = self
        
        switch quizStore.typeOfQuestions {
        case .matchKeys:
            let matchVC = initVCFromStoryboard(storyboardID: .MatchKeysViewController) as! MatchKeysViewController
            matchVC.quizViewModel = quizViewModel
            
            navigationController?.setViewControllers([inProgressVC, matchVC], animated: true)
        case .guessName:
            let flashcardVC = initVCFromStoryboard(storyboardID: .FlashcardsViewController) as! FlashcardsViewController
            flashcardVC.quizViewModel = quizViewModel
            
            navigationController?.setViewControllers([inProgressVC, flashcardVC], animated: true)
        }
    }
    

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == buttonSection {
            return 1
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rect = tableView.rectForRow(at: indexPath)
        
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
        
        // 스케일 선택하기
        if indexPath == selectScaleCellIndexPath {
            let scaleListVC = initVCFromStoryboard(storyboardID: .ScaleListTableViewController) as! ScaleListTableViewController
            scaleListVC.mode = .quizSelect
            scaleListVC.quizDelegate = self
            scaleListVC.quizViewModel = quizViewModel
            navigationController?.pushViewController(scaleListVC, animated: true)
        }
        
        if indexPath == typeOfQuestIndexPath {
            let actionTitles = quizViewModel.typeOfQuestions.map { $0.titleValue }
            simpleActionSheets(self, actionTitles: actionTitles, title: "Types of Questions", message: "", sourceView: tableView, sourceRect: rect) { [self] actionIndex in
                if let type = QuizType.init(rawValue: actionIndex) {
                    quizStore.typeOfQuestions = type
                    lblTypeOfQuestDetail.text = type.titleValue
                }
            }
        }
        
        if indexPath == enharmonicModeIndexPath {
            let actionTitles = EnharmonicMode.titleValues
            simpleActionSheets(self, actionTitles: actionTitles, title: "Select Enharmonic Mode", message: "", sourceView: tableView, sourceRect: rect) { actionIndex in
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
        case "MatchKeysSegue":
            let matchKeysVC = segue.destination as! MatchKeysViewController
            matchKeysVC.quizViewModel = quizViewModel
            
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
        lblSelectKeysDetail.text = selectedCountText.replacingOccurrences(of: "#count#", with: "\(count)")
    }
}

// MARK: - ScaleListTVCDelegate
extension QuizIntroTableViewController: ScaleListQuizDelegate {
    
    func didQuizListSubmitted(_ controller: ScaleListTableViewController, newCount: Int) {
        updateScaleCountLabel(newCount)
    }
    
    func updateScaleCountLabel(_ count: Int) {
        lblSelectScalesDetail.text = selectedCountText.replacingOccurrences(of: "#count#", with: "\(count)")
    }
}
