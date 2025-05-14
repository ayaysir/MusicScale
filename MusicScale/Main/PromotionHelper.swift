//
//  PromotionHelper.swift
//  MusicScale
//
//  Created by 윤범태 on 5/14/25.
//

import SwiftUI

// MARK: - WhatsNew, PR Data

let IAP_PromotionTitle = "loc.promo_title".localized()
let IAP_ForWhatsNewTitle = "loc.promo_whatsnew_title".localized()

let IAP_PromotionSubtitle = "loc.promo_subtitle".localized()

let IAP_PromotionPrimaryButtonTitle = "loc.promo_primary_button".localized()
let IAP_ForWhatsPrimaryButtonNewTitle = "loc.promo_primary_button_whatsnew".localized()

let IAP_PromotionSecondaryButtonTitle = "loc.promo_secondary_button".localized()

let IAP_PromotionFeatures: [PRFeature] = [
  .init(
    title: "loc.promo_feature_ad_title".localized(),
    subtitle: "loc.promo_feature_ad_subtitle".localized(),
    imageSystemName: "pip.remove"
  ),
  .init(
    title: "loc.promo_feature_keyboardsearch_title".localized(),
    subtitle: "loc.promo_feature_keyboardsearch_subtitle".localized(),
    imageSystemName: "pianokeys"
  ),
  .init(
    title: "loc.promo_feature_slide_title".localized(),
    subtitle: "loc.promo_feature_slide_subtitle".localized(),
    imageSystemName: "hand.draw"
  ),
  .init(
    title: "loc.promo_feature_multitouch_title".localized(),
    subtitle: "loc.promo_feature_multitouch_subtitle".localized(),
    imageSystemName: "hand.raised"
  ),
]

func showIAPPromtionPage(_ viewController: UIViewController, primaryAction: (() -> Void)? = nil) {
  let prIAPController = UIHostingController(
    rootView: PRView(
      title: IAP_PromotionTitle,
      subtitle: IAP_PromotionSubtitle,
      primaryButtonText: IAP_PromotionPrimaryButtonTitle,
      secondaryButtonText: IAP_PromotionSecondaryButtonTitle,
      features: IAP_PromotionFeatures,
      primaryAction: primaryAction,
      secondaryAction: nil
    )
  )
  
  viewController.present(prIAPController, animated: true)
}

func showIAPWhatsNewPage(
  _ viewController: UIViewController,
  primaryAction: (() -> Void)? = nil,
  secondaryAction: (() -> Void)? = nil,
) {
  let prIAPController = UIHostingController(
    rootView: PRView(
      title: IAP_ForWhatsNewTitle,
      subtitle: IAP_PromotionSubtitle,
      primaryButtonText: IAP_ForWhatsPrimaryButtonNewTitle,
      secondaryButtonText: IAP_PromotionSecondaryButtonTitle,
      features: IAP_PromotionFeatures,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction
    )
  )
  
  viewController.present(prIAPController, animated: true)
}
