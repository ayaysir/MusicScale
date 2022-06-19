//
//  QuizSelectKeyTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/02.
//

import UIKit

protocol QuizSelectKeyTVCDelegate: AnyObject {
    func didUpdated(_ controller: QuizSelectKeyTableViewController, newCount: Int)
}

class QuizSelectKeyTableViewController: UITableViewController {
    
    var quizStore = QuizConfigStore.shared
    let totalKeyList = Music.Key.allCases
    var availableKeyList: Set<Music.Key> = []
    
    weak var delegate: QuizSelectKeyTVCDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        availableKeyList = quizStore.availableKeys
        
        availableKeyList.forEach { key in
            if let firstIndex = totalKeyList.firstIndex(of: key) {
                let indexPath = IndexPath(row: firstIndex, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                let cell = tableView.cellForRow(at: indexPath)
                toggleCheckmark(cell!, isCheckmark: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        quizStore.availableKeys = availableKeyList
        
        if let delegate = delegate {
            delegate.didUpdated(self, newCount: availableKeyList.count)
        }
    }
    
    func toggleCheckmark(_ cell: UITableViewCell, isCheckmark: Bool) {
        // background color
        if isCheckmark {
            // cell.backgroundColor = UIColor.init(fromGooglePicker: "245, 180, 83")
            cell.backgroundColor = .systemGray5
            cell.accessoryType = .checkmark
        } else {
            cell.backgroundColor = .clear
            cell.accessoryType = .none
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Music.Key.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath) as? KeyCell else {
            return UITableViewCell()
        }
        
        // Configure the cell...
        let currentKey = totalKeyList[indexPath.row]
        cell.configure(key: currentKey)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        toggleCheckmark(cell, isCheckmark: true)
        availableKeyList.insert(totalKeyList[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        toggleCheckmark(cell, isCheckmark: false)
        availableKeyList.remove(totalKeyList[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if availableKeyList.count == 1 {
            simpleAlert(self, message: "You must select at least 1 key.")
            return nil
        }
        return indexPath
    }
}

class KeyCell: UITableViewCell {
    
    @IBOutlet weak var lblKeyName: UILabel!
    
    func configure(key: Music.Key) {
        lblKeyName.text = key.textValue
    }
}
