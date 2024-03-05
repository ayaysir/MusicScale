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
    @IBOutlet weak var lblCurrentAppearance: UILabel!
    @IBOutlet weak var lblIsShowHWKeyMapping: UILabel!
    
    // ========== 구조 변경할 경우 반드시 업데이트 ==========
    private let playbackInstCell = IndexPath(row: 0, section: 0)
    private let pianoInstCell = IndexPath(row: 1, section: 0)
    
    private let setAppearanceCellIndexPath = IndexPath(row: 0, section: 1)
    private let setHWKeyMappingCellIndexPath = IndexPath(row: 1, section: 1)
    private let setEnhamonicCell = IndexPath(row: 2, section: 1)
    private let exportToCsvCell = IndexPath(row: 3, section: 1)
    
    private let githubLinkCell = IndexPath(row: 3, section: 2)
    private let sendMailCell = IndexPath(row: 2, section: 2)
    
    private let SECTION_BANNER = 4
    // ==============================================
    
    private let config = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentAppearance = UIUserInterfaceStyle(rawValue: AppConfigStore.shared.appAppearance) ?? .unspecified
        changeAppearanceText(currentAppearance)
        
        changeShowHWKeyMappingText(isOn: AppConfigStore.shared.isShowHWKeyboardMapping)
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
            exportToCSV()
        case setAppearanceCellIndexPath:
            showAppearanceActionSheet()
        case setHWKeyMappingCellIndexPath:
            showHWKeyMappingActionSheet()
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
        case setHWKeyMappingCellIndexPath:
            simpleAlert(self, message: "When you connect an USB/Bluetooth keyboard to an iOS/iPadOS device, or run the app through an Apple Silicon series Mac, you can play the piano keys using the hardware keyboard. In this case, you can decide whether or not to display the corresponding hardware keys above the piano keys displayed in the app.".localized(), title: "Display Hardware Key on Piano".localized(), handler: nil)
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
    
    func changeAppearanceText(_ appearance: UIUserInterfaceStyle) {
        lblCurrentAppearance.text = appearance.menuText
    }
    
    func showAppearanceActionSheet() {
        let alert = UIAlertController(title: "Select Appearance Theme".localized(), message: nil, preferredStyle: .actionSheet)
        let themes: [UIUserInterfaceStyle] = [.unspecified, .light, .dark]
        
        themes.forEach { theme in
            let action = UIAlertAction(title: theme.menuText, style: .default) { _ in
                theme.overrideAllWindow()
                AppConfigStore.shared.appAppearance = theme.rawValue
                self.changeAppearanceText(theme)
            }
            
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = tableView.cellForRow(at: setAppearanceCellIndexPath)!.frame
        
        self.present(alert, animated: true)
    }
    
    private func changeShowHWKeyMappingText(isOn: Bool) {
        lblIsShowHWKeyMapping.text = isOn ? "On".localized() : "Off".localized()
    }
    
    func showHWKeyMappingActionSheet() {
        let alert = UIAlertController(
            title: "Select whether hardware keyboard mappings are displayed or not on the piano".localized(),
            message: nil,
            preferredStyle: .actionSheet)
        let selectors: [Bool] = [true, false]
        
        selectors.forEach { selector in
            let action = UIAlertAction(title: selector ? "On".localized() : "Off".localized(), style: .default) { [unowned self] _ in
                AppConfigStore.shared.isShowHWKeyboardMapping = selector
                changeShowHWKeyMappingText(isOn: selector)
            }
            
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = tableView.cellForRow(at: setHWKeyMappingCellIndexPath)!.frame
        
        self.present(alert, animated: true)
    }
    
    func exportToCSV() {
        do {
            SwiftSpinner.show("CSV 파일을 생성중입니다.")
            let list = try ScaleInfoCDService.shared.getScaleInfoStructs()
            let fileName = "UltimateScale - \(Date().ymdText) - ScaleInfo"
            let headers = ScaleInfo.CodingKeys.allCases.map { $0.rawValue }
            
            let url = try FileUtil.createTempCSVFile(fileName: fileName, codableList: list, headers: headers)
            let cell = tableView.cellForRow(at: exportToCsvCell)
            SwiftSpinner.hide()
            showActivityVC(self, activityItems: [url], sourceRect: cell!.frame)
        } catch {
            SwiftSpinner.hide()
            simpleAlert(self, message: "CSV Export: Error occurred: \(error.localizedDescription)")
            print("CSV Export: Error occurred:", error)
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
