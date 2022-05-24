//
//  ScaleInfoUpdate.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/24.
//

import UIKit

protocol ScaleInfoUpdateTVCDelegate: AnyObject {
    func didFinishedUpdate(_ controller: ScaleInfoUpdateTableViewController, viewModel: ScaleInfoViewModel)
}

class ScaleInfoUpdateTableViewController: UITableViewController {
    
    enum SubmitMode {
        case create, update
    }
    
    @IBOutlet weak var txfScaleName: UITextField!
    @IBOutlet weak var txvScaleAliases: UITextView!
    @IBOutlet weak var txvComment: UITextView!
    @IBOutlet weak var barBtnSubmit: UIBarButtonItem!
    
    weak var updateDelegate: ScaleInfoUpdateTVCDelegate?
    
    var mode: SubmitMode = .update
    var viewModel: ScaleInfoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ===== 공통 작업 =====
        
        // ===== 분기별 작업 =====
        switch mode {
        case .create:
            break
        case .update:
            guard let viewModel = viewModel else {
                return
            }

            txfScaleName.text = viewModel.name
            txvScaleAliases.text = viewModel.nameAliasFormatted
            txvComment.text = viewModel.comment
            
            print(viewModel.entity)
        }
    }
    
    @IBAction func barBtnActSubmit(_ sender: UIBarButtonItem) {
        // ===== 공통 작업 =====
        
        // ===== 분기별 작업 =====
        switch mode {
        case .create:
            break
        case .update:
            guard let viewModel = viewModel else {
                return
            }
            
            let entity = viewModel.entity
            entity.name = txfScaleName.text
            
            // let filtered = txvScaleAliases.text.range(of: "[^\n]+(\n)", options: .regularExpression)
            let aliasComponents = txvScaleAliases.text.components(separatedBy: "\n")
            entity.nameAlias = aliasComponents.filter { $0 != "" }.joined(separator: ";")
            print(entity.nameAlias!)
            entity.comment = txvComment.text
            
            do {
                try ScaleInfoCDService.shared.saveManagedContext()
            
                viewModel.reloadInfoFromEntity()
                updateDelegate?.didFinishedUpdate(self, viewModel: viewModel)
                navigationController?.popViewController(animated: true)
            
            } catch {
                print("error: update failed:", error)
            }
        }
    }
    
}
