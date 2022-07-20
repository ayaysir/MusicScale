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
        
        if let label = cell.contentView.subviews[safe: 0] as? UILabel {
            label.text = InstrumentList.instrument(at: indexPath).tableRowTitle
        }
        
        return cell
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
        
        navigationController?.popViewController(animated: true)
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
