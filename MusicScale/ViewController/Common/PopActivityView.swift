//
//  PopActivityView.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/12/03.
//

import UIKit

func popActivityView(_ controller: UIViewController, shareList: [AnyObject]) {
    let activityVC = UIActivityViewController(activityItems: shareList, applicationActivities: nil)
    activityVC.excludedActivityTypes = [.postToTwitter, .postToWeibo, .postToVimeo, .postToFlickr, .postToFacebook, .postToTencentWeibo]
    activityVC.popoverPresentationController?.sourceView = controller.view
    controller.present(activityVC, animated: true, completion: nil)
}
