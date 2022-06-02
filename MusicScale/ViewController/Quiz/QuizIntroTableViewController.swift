//
//  QuizIntroTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/02.
//

import UIKit

class QuizIntroTableViewController: UITableViewController {
    
    let selectKeyTitle = "Select the keys... (#count# selected)"

    @IBOutlet weak var lblSelectKeys: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateCountLabel(QuizConfigStore.shared.availableKeys.count)
    }

    // MARK: - Table view data source

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
        updateCountLabel(newCount)
    }
    
    func updateCountLabel(_ count: Int){
        lblSelectKeys.text = selectKeyTitle.replacingOccurrences(of: "#count#", with: "\(count)")
    }
}
