//
//  SortViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/31.
//

import UIKit
import PanModal

protocol SortVCDelegate: AnyObject {
  func didSortDone(_ controller: SortViewController, sortInfo: SortInfo)
}

class SortViewController: UIViewController {
  
  @IBOutlet weak var segAscDesc: UISegmentedControl!
  @IBOutlet weak var tableViewButtons: UITableView!
  @IBOutlet weak var btnDone: UIButton!
  
  weak var delegate: SortVCDelegate?
  let sortStore = SortFilterConfigStore.shared
  
  let menus: [SortInfo] = [
    SortInfo(title: "Custom Display Order".localized(), order: .none, state: .displayOrder),
    SortInfo(title: "Scale Name".localized(), order: .none, state: .name),
    SortInfo(title: "Priority".localized(), order: .none, state: .priority),
  ]
  
  override func viewWillAppear(_ animated: Bool) {
    switch sortStore.currentOrder {
    case .none:
      break
    case .ascending:
      segAscDesc.selectedSegmentIndex = 0
    case .descending:
      segAscDesc.selectedSegmentIndex = 1
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    btnDone.setTitle("Done".localized(), for: .normal)
    
    tableViewButtons.delegate = self
    tableViewButtons.dataSource = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    tableViewButtons.reloadData()
  }
  
  @IBAction func btnActDone(_ sender: Any) {
    
    var info: SortInfo!
    if let selectedIndexPath = tableViewButtons.indexPathForSelectedRow {
      info = menus[selectedIndexPath.row]
    } else {
      let state = sortStore.currentState
      info = menus.first { info in
        info.state == state
      }
    }
    
    guard info != nil else {
      self.dismiss(animated: true)
      return
    }
    
    if segAscDesc.isEnabled {
      info.order = segAscDesc.selectedSegmentIndex == 0 ? .ascending : .descending
    }
    delegate?.didSortDone(self, sortInfo: info)
    
    self.dismiss(animated: true)
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

extension SortViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SortButton", for: indexPath) as? SortButtonCell else {
      return UITableViewCell()
    }
    
    cell.configure(info: menus[indexPath.row])
    if sortStore.currentState == menus[indexPath.row].state {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      segAscDesc.isEnabled = false
    } else {
      segAscDesc.isEnabled = true
    }
    
    switch indexPath.row {
    case 0:
      break
    case 1:
      break
    case 2:
      break
    default:
      break
    }
  }
}

extension SortViewController: PanModalPresentable {
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  var panScrollable: UIScrollView? {
    return nil
  }
  
  // var longFormHeight: PanModalHeight {
  //     return .maxHeightWithTopInset(200)
  // }
  
  var shortFormHeight: PanModalHeight {
    return .contentHeight(300)
  }
  
  var anchorModalToLongForm: Bool {
    return false
  }
}


class SortButtonCell: UITableViewCell {
  
  @IBOutlet weak var lblTitle: UILabel!
  
  func configure(info: SortInfo) {
    lblTitle.text = info.title
  }
}

// #if canImport(SwiftUI) && DEBUG
// import SwiftUI
//
// let deviceNames: [String] = [
//     "iPhone SE",
//     "iPad 11 Pro Max",
//     "iPad Pro (11-inch)"
// ]
//
// @available(iOS 13.0, *)
// struct SortViewController_Preview: PreviewProvider {
//
//   static var previews: some View {
//     ForEach(deviceNames, id: \.self) { deviceName in
//       UIViewControllerPreview {
//         SortViewController()
//       }.previewDevice(PreviewDevice(rawValue: deviceName))
//         .previewDisplayName(deviceName)
//     }
//   }
// }
// #endif
