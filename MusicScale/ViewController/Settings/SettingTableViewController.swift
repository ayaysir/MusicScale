//
//  SettingTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import UIKit
import MessageUI
import CodableCSV

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var viewBannerContainer: UIView!
    
    // ========== 구조 변경할 경우 반드시 업데이트 ==========
    private let playbackInstCell = IndexPath(row: 0, section: 0)
    private let pianoInstCell = IndexPath(row: 1, section: 0)
    
    private let setEnhamonicCell = IndexPath(row: 0, section: 1)
    private let exportToCsvCell = IndexPath(row: 1, section: 1)
    
    private let githubLinkCell = IndexPath(row: 3, section: 2)
    private let sendMailCell = IndexPath(row: 2, section: 2)
    
    private let SECTION_BANNER = 4
    // ==============================================
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // NotificationCenter.default.removeObserver(self, name: .networkIsOffline, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(a), name: .networkIsOffline, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TrackingTransparencyPermissionRequest()
        
        DispatchQueue.main.async {
            setupBannerAds(self, container: self.viewBannerContainer)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case playbackInstCell:
            performSegue(withIdentifier: "InstrumentSegue", sender: InstrumentTableViewController.Place.playback)
        case pianoInstCell:
            performSegue(withIdentifier: "InstrumentSegue", sender: InstrumentTableViewController.Place.piano)
        case githubLinkCell:
            if let url = URL(string: "https://github.com/ayaysir/MusicScale") {
                UIApplication.shared.open(url)
            }
        case sendMailCell:
            launchEmail()
        case exportToCsvCell:
            
            self.exportToCSV()
            // simpleYesAndNo(self,
            //                message: "If you click 'Yes', the Export to CSV file window will appear.".localized(),
            //                title: "Export to CSV file".localized()) { _ in
            // }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath {
        case setEnhamonicCell:
            simpleAlert(self, message: "When the scale is displayed in the score, the user can select the same name. Select 'Custom' in the Enharmonic Mode.".localized(), title: "Enharmonic Notations".localized(), handler: nil)
        case exportToCsvCell:
            simpleAlert(self, message: "Export the currently saved scale informations to a CSV file. CSV files can be opened with spreadsheet apps such as Microsoft Excel, Google Spreadsheet or Apple Numbers.".localized(), title: "Export to CSV file".localized(), handler: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SECTION_BANNER && !AdsManager.SHOW_AD {
            return 0.1
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == SECTION_BANNER && !AdsManager.SHOW_AD {
            return 0.1
        }
        
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_BANNER && !AdsManager.SHOW_AD {
            return 0
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "InstrumentSegue":
            let selectVC = segue.destination as! InstrumentTableViewController
            let place = sender as! InstrumentTableViewController.Place
            selectVC.place = place
        case "HelpSegue", "LicenseSegue":
            let webVC = segue.destination as! PDFViewController
            webVC.category = segue.identifier == "HelpSegue" ? .help : .licenses
        default:
            break
        }
    }
}

extension SettingTableViewController {
    
    func exportToCSV() {
        do {
            let list = try ScaleInfoCDService.shared.getScaleInfoStructs()
            
            let fm = FileManager.default
            let cacheURL = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("UltimateScale - \(Date().ymdText) Exported.csv")
            
            let encoder = CSVEncoder() {
                $0.headers = ScaleInfo.CodingKeys.allCases.map { $0.rawValue }
                $0.dateStrategy = .iso8601
            }
            let data = try encoder.encode(list, into: Data.self)
            try data.write(to: cacheURL)

            popActivityView(self, shareList: [cacheURL as NSURL])
        } catch {
            print(#function, "error:", error)
        }
    }
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    
    func launchEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            simpleAlert(self, message: "The mail send form cannot be opened because the mail account is not set up on the device. Send it to yoonbumtae@gmail.com and we will reply.".localized())
            return
        }
        
        let emailTitle = "Feedback of MusicScale App".localized() // 메일 제목
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        let messageBody =
        """
        App Version: \(appVersion ?? "unknown")
        OS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice().type.rawValue)
        
        \("Please let us know bug reports, suggestions, and more.".localized())
        """
        
        let toRecipents = ["yoonbumtae@gmail.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
            controller.dismiss(animated: true)
    }
    
}
