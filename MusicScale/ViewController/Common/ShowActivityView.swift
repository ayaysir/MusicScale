//
//  ShowActivityView.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/12/03.
//

import UIKit

func showActivityVC(
  _ controller: UIViewController,
  activityItems: [Any],
  sourceRect: CGRect,
  completion: (() -> ())? = nil
) {
  let activityVC = UIActivityViewController(
    activityItems: activityItems,
    applicationActivities: nil
  )
  
  activityVC.excludedActivityTypes = [
    .postToTwitter,
    .postToWeibo,
    .postToVimeo,
    .postToFlickr,
    .postToFacebook,
    .postToTencentWeibo,
  ]
  
  // 아이패드 - activity view를 popover 할 기준 view 지정
  activityVC.popoverPresentationController?.sourceView = controller.view
  // 아이패드 - activity view를 어디에서 표시할 것인지 해당 구역(CGRect) 지정
  activityVC.popoverPresentationController?.sourceRect = sourceRect
  
  controller.present(activityVC, animated: true, completion: completion)
}
