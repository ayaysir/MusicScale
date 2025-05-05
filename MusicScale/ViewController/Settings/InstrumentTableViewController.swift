//
//  InstrumentTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import UIKit

class InstrumentTableViewController: UITableViewController {
  
  enum Place { case playback, piano }
  var place: Place = .playback {
    didSet {
      switch place {
      case .playback:
        self.title = "Select a Playback Instrument".localized()
      case .piano:
        self.title = "Select a Keyboard Instrument".localized()
      }
    }
  }
  
  // 문제있는 악기 번호 목록 (one-base)
  private let brokenInstNumber = [1, 2, 4, 37, 38, 39]
  
  var configStore = AppConfigStore.shared
  
  override func viewWillAppear(_ animated: Bool) {
    let savedNumber = place == .playback ? configStore.playbackInstrument : configStore.pianoInstrument
    let indexPath = InstrumentList.indexPath(of: savedNumber + 1)
    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    GlobalConductor.shared.restart()
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    TrackingTransparencyPermissionRequest()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return InstrumentList.sectionCount
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return InstrumentList.sectionTitle(section)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return InstrumentList.rowCount(section: section)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InstrumentCell", for: indexPath)
    
    let instInfo = InstrumentList.instrument(at: indexPath)
    if let label = cell.contentView.subviews[safe: 0] as? UILabel {
      
      // warn broken instrument
      if brokenInstNumber.contains(instInfo.number) {
        cell.accessoryType = .detailButton
        cell.tintColor = .lightGray
        
        label.textColor = .lightGray
        label.text = instInfo.tableRowTitle + " ⚠️"
      } else {
        cell.accessoryType = .none
        cell.tintColor = nil
        
        label.textColor = nil
        label.text = instInfo.tableRowTitle
      }
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    simpleAlert(self, message: "There is a possibility of sound delay or silence when setting this patch number due to an error in the soundfont file. Please use a different instrument patch number.".localized(), title: "Soundfont Error".localized(), handler: nil)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch place {
    case .playback:
      configStore.playbackInstrument = InstrumentList.instrument(at: indexPath).number - 1
    case .piano:
      configStore.pianoInstrument = InstrumentList.instrument(at: indexPath).number - 1
      
      // stop and reset sound generator engine
      GlobalGenerator.shared.stopEngine()
      GlobalGenerator.shared.initEngine()
    }
    
    // navigationController?.popViewController(animated: true)
  }
  
  private func isBannerContainerSection(_ section: Int) -> Bool {
    let half = tableView.numberOfSections / 2
    return section == 0 || section == half || section == tableView.numberOfSections - 1
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if AdsManager.SHOW_AD && isBannerContainerSection(section) {
      let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
      setupBannerAds(self, container: footerView)
      return footerView
    }
    
    return nil
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if AdsManager.SHOW_AD && isBannerContainerSection(section) {
      return 50
    }
    
    return 20
  }
}
