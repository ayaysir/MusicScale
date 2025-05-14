//
//  AdsManager.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/20.
//

import Foundation
import GoogleMobileAds

enum AdsError: Error {
  case showAdNotAllowed
}

class AdsManager: NSObject {
  private override init() {}
  static var shared = AdsManager()
  
  /// 배포 시 반드시 true로
  static var PRODUCT_MODE: Bool {
#if DEBUG
    true
#else
    true
#endif
  }
  
  /// 광고 제거 구입했나요?
  static var isPurchasedRemoveAd: Bool {
    UserDefaults.standard.bool(forKey: InAppProducts.productIDs.first!)
  }
  
  /// 최종 광고 표시 여부
  static var SHOW_AD: Bool {
    return PRODUCT_MODE && !isPurchasedRemoveAd
  }
}

extension AdsManager: BannerViewDelegate {
  private var showAd: Bool {
    AdsManager.SHOW_AD
  }
  
  func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    // print(#function, bannerView.rootViewController)
  }
  
  func bannerViewWillPresentScreen(_ bannerView: BannerView) {
    
  }
  
  func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    // print(#function, error.localizedDescription)
    
    NotificationCenter.default.post(name: .networkIsOffline, object: nil)
    
    switch bannerView.rootViewController {
    case is ScaleListTableViewController:
      break
    default:
      break
    }
  }
}

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
 
 배너 광고 목록
 
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
 
 전면 광고 목록
 - ScaleInfoVC (뒤로가기)
 - QuizInProgressViewController (시작)
 - QuizFinishedViewController (시작)
 - ArchiveDetailTableViewController (뒤로가기)
 ==== 안해도됨 QuizInProgressViewController에서 이미 동작 ====
 - FlashcardsViewController (뒤로가기)
 - MatchKeysViewController (뒤로가기)
 
 */
@discardableResult
func setupBannerAds(_ viewController: UIViewController, container: UIView? = nil) -> BannerView? {
  
  container?.backgroundColor = .clear
  
  guard AdsManager.SHOW_AD else {
    return nil
  }
  
  container?.layoutIfNeeded()
  let bannerWidth = container != nil ? container!.frame.width : viewController.view.frame.width
  let bannerHeight = container != nil ? container!.frame.height : 50
  let adSize = adSizeFor(cgSize: CGSize(width: bannerWidth, height: bannerHeight))
  let bannerView = BannerView(adSize: adSize)
  
  bannerView.translatesAutoresizingMaskIntoConstraints = false
  
  if let container = container {
    container.addSubview(bannerView)
  } else {
    viewController.view.addSubview(bannerView)
    viewController.view.addConstraints( [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: viewController.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: viewController.view, attribute: .centerX, multiplier: 1, constant: 0) ])
  }
  
  // bannerView.adUnitID = adUnitID
  bannerView.adUnitID = adUnitIDDistributor(viewController)
  bannerView.rootViewController = viewController
  bannerView.delegate = AdsManager.shared
  
  let request = Request()
  bannerView.load(request)
  
  return bannerView
}

/**
 전체 화면 광고: 사용 방법
 1. 사용할 뷰컨트롤러의 멤버 변수로 `private var interstitial: GADInterstitialAd?` 추가
 2. `interstitial`을 `setupFullAds`로 불러오고, `fullScreenContentDelegate`로 `self` 추가
 3. `ad(...didFailToPresentFullScreenContentWithError...)`, `adDidDismissFullScreenContent` 메서드 구현
 */
func setupFullAds(_ viewController: UIViewController) async throws -> InterstitialAd? {
  guard AdsManager.SHOW_AD else {
    throw AdsError.showAdNotAllowed
  }
  
  let request = Request()
  return try await InterstitialAd.load(with: "ca-app-pub-6364767349592629/6979389977", request: request)
}
