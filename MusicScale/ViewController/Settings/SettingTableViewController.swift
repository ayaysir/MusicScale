//
//  SettingTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import UIKit
import MessageUI

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var viewBannerContainer: UIView!
    
    private let playbackInstCell = IndexPath(row: 0, section: 0)
    private let pianoInstCell = IndexPath(row: 1, section: 0)
    
    private let setEnhamonicCell = IndexPath(row: 0, section: 1)
    
    private let githubLinkCell = IndexPath(row: 3, section: 2)
    private let sendMailCell = IndexPath(row: 2, section: 2)
    
    private let SECTION_BANNER = 4
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // NotificationCenter.default.removeObserver(self, name: .networkIsOffline, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(a), name: .networkIsOffline, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath == setEnhamonicCell {
            simpleAlert(self, message: "When the scale is displayed in the score, the user can select the same name. Select 'Custom' in the Enharmonic Mode.".localized(), title: "Enharmonic Notations".localized(), handler: nil)
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
            let webVC = segue.destination as! WebPageViewController
            webVC.category = segue.identifier == "HelpSegue" ? .help : .licenses
        default:
            break
        }
    }
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    
    func launchEmail() {
  // 1
        guard MFMailComposeViewController.canSendMail() else {
            simpleAlert(self, message: "The mail send form cannot be opened because the mail account is not set up on the device. Send it to yoonbumtae@gmail.com and we will reply.".localized())
            return
        }
        
  // 2
        let emailTitle = "Feedback of MusicScale App".localized() // 메일 제목
        let messageBody =
        """
        OS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice().type.rawValue)
        
        \("Please let us know bug reports, suggestions, and more.".localized())
        """
        
  // 3
        let toRecipents = ["yoonbumtae@gmail.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
    // 4
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
            controller.dismiss(animated: true)
    }
    
}
