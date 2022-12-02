//
//  StatsViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/20.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var txvQuizLog: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let result = try QuizStatsCDService.shared.readEntityList()
            
            if result.count == 0 {
                txvQuizLog.text = "There is no records.".localized()
                return
            }
            
            txvQuizLog.text = result.reduce("") { partialResult, entity in
                return partialResult + "\(entity)\n"
            }
        } catch {
            txvQuizLog.text = "An error occurred while retrieving data.".localized()
        }
    }
    
    @IBAction func barBtnActExportToCSV(_ sender: Any) {
        do {
            let list = try QuizStatsCDService.shared.getQuizStats()
            let fileName = "UltimateScale - \(Date().ymdText) - QuizStats"
            let headers = QuizStat.CodingKeys.allCases.map { $0.rawValue }
            
            let url = try FileUtil.createTempCSVFile(fileName: fileName, codableList: list, headers: headers)
            popActivityView(self, shareList: [url as NSURL])
        } catch {
            simpleAlert(self, message: "CSV Export: Error occurred: \(error.localizedDescription)")
            print("CSV Export: Error occurred:", error)
        }
    }
    
}
