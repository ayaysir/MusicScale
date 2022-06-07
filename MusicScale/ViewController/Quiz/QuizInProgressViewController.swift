//
//  QuizInProgressViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/07.
//

import UIKit

class QuizInProgressViewController: UIViewController {
    
    var quizViewModel: QuizViewModel!
    var introVC: QuizIntroTableViewController!
    
    @IBOutlet weak var btnGiveUp: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        if quizViewModel.isAllQuestionFinished {
            navigationController?.setViewControllers([introVC], animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnActContinue(_ sender: Any) {
        switch QuizConfigStore.shared.typeOfQuestions {
        case .matchKeys:
            let matchVC = initVCFromStoryboard(storyboardID: .MatchKeysViewController) as! MatchKeysViewController
            matchVC.quizViewModel = quizViewModel
            navigationController?.setViewControllers([self, matchVC], animated: true)
        case .guessName:
            let flashcardVC = initVCFromStoryboard(storyboardID: .FlashcardsViewController) as! FlashcardsViewController
            flashcardVC.quizViewModel = quizViewModel
            navigationController?.setViewControllers([self, flashcardVC], animated: true)
        }
        
        
    }
    
    @IBAction func btnActGiveUp(_ sender: Any) {
        QuizConfigStore.shared.savedLeitnerSystem = nil
        
        navigationController?.setViewControllers([introVC], animated: true)
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
