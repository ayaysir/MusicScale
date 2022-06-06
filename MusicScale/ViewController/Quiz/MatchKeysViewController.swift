//
//  MatchKeysViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/06.
//

import UIKit

class MatchKeysViewController: UIViewController {
    
    var quizViewModel: QuizViewModel!

    @IBOutlet weak var lblKeyName: UILabel!
    @IBOutlet weak var lblQuizProgressInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !quizViewModel.isAllQuestionFinished {
            displayName(question: quizViewModel.currentQuestion!)
        }
        
        // let title = navigationItem.leftBarButtonItem?.title
        // navigationItem.leftBarButtonItem = UIBarButtonItem(title: title ?? "< scc", style: .plain, target: self, action: #selector(backAction))
    }
    
    // @objc func backAction() {
    //     print(#function)
    //     if quizViewModel.isAllQuestionFinished {
    //         navigationController?.popViewController(animated: true)
    //     } else {
    //         navigationController?.popToViewController(self, animated: true)
    //     }
    // }
    
    @IBAction func btnActSuccess(_ sender: Any) {
        progressNextQuestion(true)
    }
    
    @IBAction func btnActFailed(_ sender: Any) {
        progressNextQuestion(false)
    }
    
    func displayName(question: QuizQuestion) {
        lblKeyName.text = "\(question.scaleInfo.name) : \(question.key) : \(question.isAscending ? "ASC" : "DESC")"
        lblQuizProgressInfo.text = quizViewModel.quizStatus
    }
    
    func progressNextQuestion(_ isCurrentSuccess: Bool) {
        
        guard let newQuestion = quizViewModel.submitResultAndGetNextQuestion(currentSuccess: isCurrentSuccess) else {
            if quizViewModel.isAllQuestionFinished {
                navigationItem.leftBarButtonItem?.title = ""
                navigationItem.leftBarButtonItem?.isEnabled = false
                simpleAlert(self, message: "End", title: "End") { action in
                    self.quizViewModel.removeSavedLeitnerSystem()
                    let introVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuizIntroTableViewController") as! QuizIntroTableViewController
                    introVC.quizViewModel = self.quizViewModel
                    self.navigationController?.setViewControllers([introVC], animated: true)
                }
                return
            }
            simpleAlert(self, message: "Error")
            return
        }
        displayName(question: newQuestion)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
