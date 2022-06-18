//
//  QuizFinishedViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import UIKit

class QuizFinishedViewController: UIViewController {
    
    var quizViewModel: QuizViewModel!
    
    @IBOutlet weak var btnGoHome: UIButton!
    @IBOutlet weak var tableViewStats: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewStats.delegate = self
        tableViewStats.dataSource = self
        
        btnGoHome.layer.cornerRadius = 5
    }
    
    @IBAction func btnActGoToTop(_ sender: Any) {
        let topVC = initVCFromStoryboard(storyboardID: .QuizIntroTableViewController)
        navigationController?.setViewControllers([topVC], animated: true)
        quizViewModel.removeSavedLeitnerSystem()
    }
    
    
    // MARK: - Navigation
}

extension QuizFinishedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quizViewModel.statsInfoForTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatCell", for: indexPath) as? CellWithStyleRightDetail else {
            return UITableViewCell()
        }
        
        let statElement = quizViewModel.statsInfoForTable[indexPath.row]
        
        cell.configure(title: statElement.name, detail: "\(statElement.value)")
        return cell
    }
}

class CellWithStyleRightDetail: UITableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(title: String, detail: String) {
        let lblTitle = self.contentView.subviews[0] as! UILabel
        let lblDetail = self.contentView.subviews[1] as!
        UILabel
        
        lblTitle.text = title
        lblDetail.text = detail
    }
}
