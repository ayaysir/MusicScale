//
//  SettingTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import UIKit
import MessageUI
import StoreKit
import CodableCSV

class SettingTableViewController: UITableViewController {
  
  @IBOutlet weak var viewBannerContainer: UIView!
  @IBOutlet weak var lblCurrentAppearance: UILabel!
  @IBOutlet weak var lblIsShowHWKeyMapping: UILabel!
  
  private var iapProducts: [SKProduct]?
  
  // ========== 테이블 순서, 구조 변경할 경우 반드시 업데이트 ==========
  // IAP Setting: Section 0
  private let SECTION_IAP = 0
  private let restorePurchasesCellIndexPath = IndexPath(row: 1, section: 0)
  private let firstIAPProductCellIndexPath = IndexPath(row: 0, section: 0)
  
  // App Setting: Section 1
  private let playbackInstCell = IndexPath(row: 0, section: 1)
  private let setAppearanceCellIndexPath = IndexPath(row: 1, section: 1)
  private let setHWKeyMappingCellIndexPath = IndexPath(row: 2, section: 1)
  private let setEnhamonicCell = IndexPath(row: 3, section: 1)
  private let exportToCsvCell = IndexPath(row: 4, section: 1)
  
  // Info: Section 2
  private let sendMailCell = IndexPath(row: 3, section: 2)
  private let githubLinkCell = IndexPath(row: 4, section: 2)
  
  private let SECTION_BANNER = 3
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
    
    initIAP()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "HelpSegue", "LicenseSegue", "NewFeatureSegue":
      let webVC = segue.destination as! PDFViewController
      webVC.category = segue.identifier == "HelpSegue" ? .help : segue.identifier == "LicenseSegue" ? .licenses : .newFeatureAndShortcuts
    default:
      break
    }
  }
}

// MARK: - TableView delegates

extension SettingTableViewController {
  override func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    // IAP Section
    if let iapProducts,
       indexPath.section == SECTION_IAP,
       indexPath.row != restorePurchasesCellIndexPath.row,
       let product = iapProducts[safe: indexPath.row] {
      purchaseIAP(productID: product.productIdentifier)
    } else if indexPath.section == SECTION_IAP,
              indexPath.row != restorePurchasesCellIndexPath.row {
      simpleAlert(
        self,
        message: "loc.iap_not_ready".localized(),
        title: "loc.iap_not_ready_title".localized(),
        handler: nil
      )
    }
    
    // Links or segues
    switch indexPath {
    case playbackInstCell:
      performSegue(withIdentifier: "InstrumentSegue", sender: nil)
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
    case restorePurchasesCellIndexPath:
      restoreIAP()
    default:
      break
    }
  }
  
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    switch indexPath {
    case setEnhamonicCell:
      simpleAlert(self, message: "loc.enharmonic_mode_custom_info".localized(), title: "loc.enharmonic_notations".localized(), handler: nil)
    case exportToCsvCell:
      simpleAlert(self, message: "loc.export_csv_info".localized(), title: "loc.export_csv_title".localized(), handler: nil)
    case setHWKeyMappingCellIndexPath:
      simpleAlert(self, message: "loc.hwkey_mapping_info".localized(), title: "loc.hwkey_mapping_title".localized(), handler: nil)
    case restorePurchasesCellIndexPath:
      simpleAlert(self, message: "loc.restore_purchase_info".localized(), title: "loc.restore_purchase_title".localized(), handler: nil)
    case firstIAPProductCellIndexPath:
      simpleAlert(self, message: "loc.iap_intro_info".localized(), title: "loc.iap_intro_title".localized(), handler: nil)
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
    } else if section == SECTION_IAP {
      return 1 + InAppProducts.productIDs.count
    }
    
    return super.tableView(tableView, numberOfRowsInSection: section)
  }
  
  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let cell = super.tableView(tableView, cellForRowAt: indexPath) as? IAPTableViewCell else {
      return super.tableView(tableView, cellForRowAt: indexPath)
    }

    if let iapProducts,
       indexPath.section == SECTION_IAP,
       indexPath.row != restorePurchasesCellIndexPath.row,
       let product = iapProducts[safe: indexPath.row] {
      
      let isPurchased = InAppProducts.helper.isProductPurchased(product.productIdentifier)
      
      cell.tintColor = isPurchased ? .systemGray3 : .highlightAccessoryTint
      cell.lblIapProductName.text = product.localizedTitle + " (\(product.localizedPrice ?? ""))"
      cell.lblIapProductName.textColor = isPurchased ? .lightGray : nil
      
      cell.configure(isPurchased: isPurchased, discountRate: nil)
      
      if isPurchased {
        return cell
      }
      
      Task {
        do {
          let isDiscountNow = try await DiscountManager.shared.isDiscountNow()
          guard isDiscountNow else {
            return
          }
          
          let rate = try await DiscountManager.shared.globalDiscountRate()
          await MainActor.run {
            cell.configure(isPurchased: false, discountRate: rate)
          }
        } catch {
          print("할인 정보 로딩 실패: \(error.localizedDescription)")
        }
      }
    }

    return cell
  }
}

extension SettingTableViewController {
  /// 현재 테마 상태에 따라 Appearance 상태 텍스트 변경
  func changeAppearanceText(_ appearance: UIUserInterfaceStyle) {
    lblCurrentAppearance.text = appearance.menuText
  }
  
  /// 테마 변경 액션 시트를 표시
  func showAppearanceActionSheet() {
    let alert = UIAlertController(title: "loc.select_appearance".localized(), message: nil, preferredStyle: .actionSheet)
    let themes: [UIUserInterfaceStyle] = [.unspecified, .light, .dark]
    
    themes.forEach { theme in
      let action = UIAlertAction(title: theme.menuText, style: .default) { _ in
        theme.overrideAllWindow()
        AppConfigStore.shared.appAppearance = theme.rawValue
        self.changeAppearanceText(theme)
      }
      
      alert.addAction(action)
    }
    
    let cancel = UIAlertAction(title: "loc.cancel".localized(), style: .cancel)
    alert.addAction(cancel)
    
    alert.popoverPresentationController?.sourceView = self.view
    alert.popoverPresentationController?.sourceRect = tableView.cellForRow(at: setAppearanceCellIndexPath)!.frame
    
    self.present(alert, animated: true)
  }
  
  /// 하드웨어 키보드 매핑 on/off 여부 표시
  private func changeShowHWKeyMappingText(isOn: Bool) {
    lblIsShowHWKeyMapping.text = (isOn ? "loc.on" : "loc.off").localized()
  }
  
  /// 하드웨어 키보드 매핑 표시 설정 액션 시트 표시
  func showHWKeyMappingActionSheet() {
    let alert = UIAlertController(
      title: "loc.select_hwkey_mapping_display".localized(),
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
  
  /// CSV 출력 메뉴
  func exportToCSV() {
    do {
      SwiftSpinner.show("loc.creating_csv")
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
      simpleAlert(self, message: "loc.mail_not_configured".localized())
      return
    }
    
    let emailTitle = "loc.feedback_email_title".localized() // 메일 제목
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    
    let messageBody =
        """
        App Version: \(appVersion ?? "unknown")
        OS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice().type.rawValue)
        
        \("loc.feedback_email_body".localized())
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

/*
 ===> 인앱 결제로 광고 제거
 */
extension SettingTableViewController {
  /// IAP 초기화
  private func initIAP() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleIAPPurchase(_:)), name: .IAPHelperPurchaseNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(hadnleIAPError(_:)), name: .IAPHelperErrorNotification, object: nil)
    
    // IAP 불러오기
    InAppProducts.helper.inquireProductsRequest { [weak self] (success, products) in
      guard let self, success else {
        print(#function, "IAP products inquiry failed")
        return
      }
      self.iapProducts = products
      
      DispatchQueue.main.async { [weak self] in
        guard let self,
              let products else {
          return
        }
        
        // 불러오기 후 할 UI 작업
        tableView.reloadSections([SECTION_IAP], with: .none)
        
        products.forEach {
          if !InAppProducts.helper.isProductPurchased($0.productIdentifier) {
            print("\($0.localizedTitle) (\($0.price))")
          }
        }
      }
    }
    
    if InAppProducts.helper.isProductPurchased(InAppProducts.productIDs[0]) || UserDefaults.standard.bool(forKey: InAppProducts.productIDs[0]) {
      // 이미 구입한 경우 UI 업데이트 작업
    }
  }
  
  /// 구매: 인앱 결제 버튼 눌렀을 때
  private func purchaseIAP(productID: String) {
    if let product = iapProducts?.first(where: {productID == $0.productIdentifier}),
       !InAppProducts.helper.isProductPurchased(productID) {
      InAppProducts.helper.buyProduct(product)
      SwiftSpinner.show("loc.processing_iap".localized())
    } else {
      simpleAlert(self, message: "loc.purchase_completed_info".localized(), title: "loc.purchase_completed_title".localized(), handler: nil)
    }
  }
  
  /// 복원: 인앱 복원 버튼 눌렀을 때
  private func restoreIAP() {
    InAppProducts.helper.restorePurchases()
  }
  
  /// 결제 후 Notification을 받아 처리
  @objc func handleIAPPurchase(_ notification: Notification) {
    guard notification.object is String else {
      simpleAlert(self, message: "loc.purchase_failed".localized())
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      simpleAlert(self, message: "loc.purchase_completed_info".localized(), title: "loc.purchase_completed_title".localized()) { [weak self] action in
        guard let self else { return }
        // 결제 성공하면 해야할 작업...
        // 1. 로딩 인디케이터 숨기기
        SwiftSpinner.hide()
        
        // 2. 세팅VC 광고 제거 (나머지 뷰는 다시 들어가면 제거되어 있음)
        tableView.reloadSections([SECTION_BANNER], with: .none)
        
        // 3. 버튼 UI 업데이트
        tableView.reloadData()
      }
    }
  }
  
  // 에러 발생시(결제 취소 포함) 작업
  @objc func hadnleIAPError(_ notification: Notification) {
    SwiftSpinner.hide()
    simpleAlert(
      self,
      message: "\(notification.object as? String ?? "")".localized(),
      title: "loc.purchase_failed".localized(),
      handler: nil
    )
  }
}
