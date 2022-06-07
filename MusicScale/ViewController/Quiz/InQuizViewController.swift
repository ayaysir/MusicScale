//
//  InQuizViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/07.
//

import UIKit

/**
  - quizViewModel
  - displayNextQuestionHandler
  - displayEndQuizHandler
  - displayNilQuestionHandler
  - loadFirstQuestion(_:)
 */
class InQuizViewController: UIViewController {
    
    typealias DisplayHandler = (_ newQuestion: QuizQuestion) -> ()
    typealias Handler = () -> ()
    
    var quizViewModel: QuizViewModel!
    var displayNextQuestionHandler: DisplayHandler!
    var displayEndQuizHandler: Handler!
    var displayNilQuestionHandler: Handler!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNextQuestionHandler = { newQuestion in
            print(newQuestion)
        }
        
        displayEndQuizHandler = { [unowned self] in
            navigationItem.leftBarButtonItem?.title = ""
            navigationItem.leftBarButtonItem?.isEnabled = false
            
            simpleAlert(self, message: "End", title: "End") { action in
                self.quizViewModel.removeSavedLeitnerSystem()
                let introVC = initVCFromStoryboard(storyboardID: .QuizIntroTableViewController) as! QuizIntroTableViewController
                introVC.quizViewModel = self.quizViewModel
                self.navigationController?.setViewControllers([introVC], animated: true)
            }
        }
        
        displayNilQuestionHandler = {
            simpleAlert(self, message: "Error")
        }
    }
    
    func loadFirstQuestion() {
        // 최초 질문 불러오기
        if !quizViewModel.isAllQuestionFinished {
            displayNextQuestionHandler(quizViewModel.currentQuestion!)
        }
    }
    
    func progressNextQuestion(_ isCurrentSuccess: Bool) {
        
        guard let newQuestion = quizViewModel.submitResultAndGetNextQuestion(currentSuccess: isCurrentSuccess) else {
            if quizViewModel.isAllQuestionFinished {
                displayEndQuizHandler()
                return
            }
            displayNilQuestionHandler()
            return
        }
        
        displayNextQuestionHandler(newQuestion)
    }
}
