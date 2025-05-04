//
//  IAPTableViewCell.swift
//  MusicScale
//
//  Created by 윤범태 on 5/4/25.
//

import UIKit

class IAPTableViewCell: UITableViewCell {
  private let TOGGLE_SEC: Double = 2.0
  @IBOutlet weak var lblIapProductName: UILabel!
  @IBOutlet weak var lblPurchaseStatus: UILabel!

  private var toggleTimer: Timer?
  private var showingDiscount = false

  func configure(isPurchased: Bool, discountRate: Double?) {
    toggleTimer?.invalidate()

    if isPurchased {
      lblPurchaseStatus.text = "Purchased".localized()
      lblPurchaseStatus.textColor = .systemGreen
    } else if let discountRate, discountRate > 0 {
      startDiscountAnimation(rate: discountRate)
    } else {
      lblPurchaseStatus.text = "Not Purchased".localized()
      lblPurchaseStatus.textColor = .darkGray
    }
  }

  private func startDiscountAnimation(rate: Double) {
    showingDiscount = false
    toggleText(rate: rate)
    toggleTimer = Timer.scheduledTimer(withTimeInterval: TOGGLE_SEC, repeats: true) { [weak self] _ in
      self?.toggleText(rate: rate)
    }
  }

  private func toggleText(rate: Double) {
    showingDiscount.toggle()
    let text: String
    let color: UIColor

    if showingDiscount {
      let percent = Int(rate * 100)
      text = "\(percent)% 할인중!"
      color = .systemPink
    } else {
      text = "Not Purchased".localized()
      color = .darkGray
    }

    UIView.transition(with: lblPurchaseStatus,
                      duration: 0.4,
                      options: .transitionCrossDissolve,
                      animations: {
      self.lblPurchaseStatus.text = text
      self.lblPurchaseStatus.textColor = color
    }, completion: nil)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    toggleTimer?.invalidate()
    lblPurchaseStatus.text = nil
  }

  deinit {
    toggleTimer?.invalidate()
  }
}
