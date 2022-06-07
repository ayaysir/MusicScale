//
//  MatchKeysViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/06.
//

import UIKit

class MatchKeysViewController: InQuizViewController {
    
    // var quizViewModel: QuizViewModel!

    @IBOutlet weak var lblKeyName: UILabel!
    @IBOutlet weak var lblQuizProgressInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNextQuestionHandler = { newQuestion in
            self.displayName(question: newQuestion)
        }
        
        loadFirstQuestion()
    }
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
