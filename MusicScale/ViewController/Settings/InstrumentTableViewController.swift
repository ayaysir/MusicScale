//
//  InstrumentTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import UIKit

class InstrumentTableViewController: UITableViewController {
  private var configStore = AppConfigStore.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "loc.instrument_title".localized()
    TrackingTransparencyPermissionRequest()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let savedNumber =  configStore.playbackInstrument
    let indexPath = InstrumentList.indexPath(of: savedNumber)
    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    GlobalConductor.shared.restart()
    
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
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "InstrumentCell", for: indexPath) as? InstrumentCell else {
      return UITableViewCell()
    }
    
    let instInfo = InstrumentList.instrument(at: indexPath)
    // let isBroken = brokenInstNumber.contains(instInfo.number)
    let isSelectedForPlayback = instInfo.number == configStore.playbackInstrument
    let isSelectedForPiano = instInfo.number == configStore.pianoInstrument
    
    cell.configure(
      info: instInfo,
      isBroken: false,
      isSelectedForPlayback: isSelectedForPlayback,
      isSelectedForPiano: isSelectedForPiano,
      onPlaybackSelect: {
        self.configStore.playbackInstrument = instInfo.number
        tableView.reloadData()
        self.restartEngine()
      },
      onPianoSelect: {
        self.configStore.pianoInstrument = instInfo.number
        tableView.reloadData()
        self.restartEngine()
      }
    )
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    simpleAlert(self, message: "loc.soundfont_warning".localized(), title: "loc.soundfont_error_title".localized(), handler: nil)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
  
  // MARK: - Utilities
  func restartEngine() {
    // stop and reset sound generator engine
    GlobalGenerator.shared.stopEngine()
    GlobalGenerator.shared.initEngine()
  }
  
  // MARK: - Ad area
  
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

class InstrumentCell: UITableViewCell {
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var btnPlaybackSelect: UIButton!
  @IBOutlet weak var btnPianoSelect: UIButton!
  
  var onPlaybackSelect: (() -> Void)?
  var onPianoSelect: (() -> Void)?
  
  @IBAction func didTapPlaybackSelect(_ sender: UIButton) {
    onPlaybackSelect?()
  }

  @IBAction func didTapPianoSelect(_ sender: UIButton) {
    onPianoSelect?()
  }
  
  func configure(
    info: InstrumentInfo,
    isBroken: Bool = false,
    isSelectedForPlayback: Bool = false,
    isSelectedForPiano: Bool = false,
    onPlaybackSelect: @escaping () -> Void,
    onPianoSelect: @escaping () -> Void
  ) {
    // warn broken instrument
    if isBroken {
      accessoryType = .detailButton
      tintColor = .lightGray
      
      lblTitle.textColor = .lightGray
      lblTitle.text = info.tableRowTitle + " ⚠️"
    } else {
      accessoryType = .none
      tintColor = nil
      
      lblTitle.textColor = nil
      lblTitle.text = info.tableRowTitle
    }
    
    let selectedColor = UIColor.systemTeal.withAlphaComponent(0.3)
    
    if isSelectedForPlayback {
      btnPlaybackSelect.backgroundColor = selectedColor
      btnPlaybackSelect.tintColor = .label
    } else {
      btnPlaybackSelect.backgroundColor = UIColor.clear
      btnPlaybackSelect.tintColor = .lightGray
    }
    
    if isSelectedForPiano {
      btnPianoSelect.backgroundColor = selectedColor
      btnPianoSelect.tintColor = .label
    } else {
      btnPianoSelect.backgroundColor = UIColor.clear
      btnPianoSelect.tintColor = .lightGray
    }
    
    btnPlaybackSelect.layer.cornerRadius = 5
    btnPianoSelect.layer.cornerRadius = 5
    
    self.onPlaybackSelect = onPlaybackSelect
    self.onPianoSelect = onPianoSelect
  }
}
