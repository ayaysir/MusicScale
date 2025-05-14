//
//  PromotionHelper.swift
//  MusicScale
//
//  Created by 윤범태 on 5/14/25.
//

import SwiftUI

// MARK: - WhatsNew, PR Data

let IAP_PromotionTitle = "Pro용 인앱 결제 구입"
let IAP_ForWhatsNewTitle = "인앱 결제의 혜택이 새로워졌습니다."

let IAP_PromotionSubtitle = "Pro용 인앱을 구입하시면 모든 광고 영구 제거, 고급 피아노 키보드 이용, 건반을 이용한 고급 스케일 검색 등을 할 수 있습니다."

let IAP_PromotionPrimaryButtonTitle = "구입하기"
let IAP_ForWhatsPrimaryButtonNewTitle = "상품 살펴보기"

let IAP_PromotionSecondaryButtonTitle = "나중에 다시 알아볼게요"

let IAP_PromotionFeatures: [PRFeature] = [
  .init(
    title: "모든 광고 영구 제거",
    subtitle: "배너 광고, 전체 화면 광고를 모두 영구 제거하여 쾌적한 앱 사용이 가능합니다.",
    imageSystemName: "pip.remove"
  ),
  .init(
    title: "건반을 이용한 고급 스케일 검색",
    subtitle: "피아노 건반으로 아무 스케일을 입력하면 자동으로 일치하거나 유사한 스케일을 찾아줍니다.",
    imageSystemName: "pianokeys"
  ),
  .init(
    title: "슬라이드로 연주하기",
    subtitle: "피아노 키보드를 슬라이드해서 연주할 수 있습니다. 멜로디의 흐름을 파악하고자 할 때 유용합니다.",
    imageSystemName: "hand.draw"
  ),
  .init(
    title: "멀티터치로 연주하기",
    subtitle: "멀티터치로 해당 스케일에서 조합할 수 있는 화음을 연주할 수 있습니다.",
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
