//
//  AdsManager.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/20.
//

import Foundation
import GoogleMobileAds

/*
 하단 광고 넣는 방법
 == Delegate 사용하지 않는 경우 ==
 _ = setupBannerAds(self)
 
 == Delegate 사용하는 경우 ==
 1. **import GoogleMobileAds**
 
 2. VC의 멤버 변수 **private var bannerView: GADBannerView!**
    **viewDidLoad()**에 **
            bannerView = setupBannerAds(self)
            bannerView.delegate = self
    ** 추가
 
 3.  **GADBannerViewDelegate** 를 상속받은 후 **func bannerViewDidReceiveAd(...)**에서 로딩 후 작업(뷰 높이 변경 등) 진행
 
 예) buttonBottomConstraint.constant += bannerView.adSize.size.height
 
 ====================
 
 광고 목록

 TableView (static)
 - Setting TVC
 - Enharmonic TVC
 - ArchiveDetail TVC
 - QuizIntro TVC
 - ScaleInfoUpdate TVC
 - ScaleSubInfo TVC
 
 TableView (dynamic)
 - Instrument TVC
 - ArchiveMain TVC
 - ScaleList TVC
 
 View (전부 custom banner view에 삽입)
 - MatchKeys VC
 - Flashcards VC
 - QuizInProgress VC
 - QuizFinished VC
 
 */

@discardableResult
func setupBannerAds( _ viewController: UIViewController, container: UIView? = nil) -> GADBannerView {

    container?.layoutIfNeeded()
    let bannerWidth = container != nil ? container!.frame.width : viewController.view.frame.width
    let bannerHeight = container != nil ? container!.frame.height : 50
    let adSize = GADAdSizeFromCGSize(CGSize(width: bannerWidth, height: bannerHeight))
    let bannerView = GADBannerView(adSize: adSize)

    bannerView.translatesAutoresizingMaskIntoConstraints = false
    
    if let container = container {
        print(viewController.className, container.frame, bannerView.frame)
        container.backgroundColor = .clear
        container.addSubview(bannerView)
    } else {
        viewController.view.addSubview(bannerView)
        viewController.view.addConstraints( [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: viewController.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: viewController.view, attribute: .centerX, multiplier: 1, constant: 0) ])
    }
    
    // bannerView.adUnitID = adUnitID
    bannerView.adUnitID = adUnitIDDistributor(viewController)
    bannerView.rootViewController = viewController

    let request = GADRequest()
    bannerView.load(request)

    return bannerView
}