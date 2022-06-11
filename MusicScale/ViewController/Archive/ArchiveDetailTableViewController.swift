//
//  ArchiveDetailTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/11.
//

import UIKit

class ArchiveDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnDislike: UIButton!
    
    @IBOutlet weak var btnSelectScale: UIButton!
    
    
    enum CRUDMode {
        case read, create
    }
    
    var mode: CRUDMode = .read
    
    func isMode(_ mode: CRUDMode) -> Bool {
        return self.mode == mode
    }
    
    private let SECTION_FIRST = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonTitle()
        
        btnSelectScale.isHidden = isMode(.read)
    }
    
    func setButtonTitle() {
        btnPlay.setTitle("", for: .normal)
        btnLike.setTitle("", for: .normal)
        btnDislike.setTitle("", for: .normal)
    }
    
    @IBAction func btnActSelectScale(_ sender: Any) {
        guard isMode(.create) else {
            return
        }
        
        let scaleListVC = initVCFromStoryboard(storyboardID: .ScaleListTableViewController) as! ScaleListTableViewController
        scaleListVC.mode = .uploadSelect
        navigationController?.pushViewController(scaleListVC, animated: true)
    }
    
}

extension ArchiveDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_FIRST {
            switch mode {
            case .read:
                return ""
            case .create:
                return "Select a scale"
            }
        }
        
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
}
