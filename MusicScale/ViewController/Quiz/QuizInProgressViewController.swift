//
//  QuizInProgressViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/07.
//

import UIKit
import HGCircularSlider
import GoogleMobileAds

class QuizInProgressViewController: UIViewController {
    private var interstitial: GADInterstitialAd?
    
    var quizViewModel: QuizViewModel!
    var introVC: QuizIntroTableViewController!
    
    @IBOutlet weak var circlularSlider: CircularSlider!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnGiveUp: UIButton!
    @IBOutlet weak var lblPercent: UILabel!
    @IBOutlet weak var viewBannerContainer: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = ""
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if quizViewModel.isAllQuestionFinished {
            let finishedVC = initVCFromStoryboard(storyboardID: .QuizFinishedViewController) as! QuizFinishedViewController
            finishedVC.quizViewModel = quizViewModel
            navigationController?.setViewControllers([finishedVC], animated: false)
            return
        }
        
        let stats = quizViewModel.leitnerSystem.progressInfo
        let inStudyPercent: CGFloat = CGFloat(stats.learningBoxOneCount + stats.learningBoxTwoCount + stats.learningBoxThreeCount) / CGFloat(stats.originalItemListCount)
        let finishedPercent: CGFloat = CGFloat(stats.finishedBoxCount) / CGFloat(stats.originalItemListCount)
        let forecastPercent = inStudyPercent * 0.3 + finishedPercent * 0.7
        
        circlularSlider.endPointValue = forecastPercent
        let displayValue = Int(round(forecastPercent * 100))
        lblPercent.text = "\(displayValue)%"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TrackingTransparencyPermissionRequest()
        
        btnContinue.layer.cornerRadius = 5
        btnGiveUp.layer.cornerRadius = 5
        
        setupBannerAds(self, container: viewBannerContainer)
        
        prepareAndShowFullScreenAd()
    }
    
    @IBAction func btnActContinue(_ sender: Any) {
        switch QuizConfigStore.shared.typeOfQuestions {
        case .matchKeys:
            let matchVC = initVCFromStoryboard(storyboardID: .MatchKeysViewController) as! MatchKeysViewController
            matchVC.quizViewModel = quizViewModel
            navigationController?.setViewControllers([self, matchVC], animated: true)
        case .guessName:
            let flashcardVC = initVCFromStoryboard(storyboardID: .FlashcardsViewController) as! FlashcardsViewController
            flashcardVC.quizViewModel = quizViewModel
            navigationController?.setViewControllers([self, flashcardVC], animated: true)
        }
    }
    
    @IBAction func btnActGiveUp(_ sender: Any) {
        QuizConfigStore.shared.savedLeitnerSystem = nil
        
        navigationController?.setViewControllers([introVC], animated: true)
    }
}

extension QuizInProgressViewController: GADFullScreenContentDelegate {
    private func prepareAndShowFullScreenAd() {
        Task {
            SwiftSpinner.show("Content is loading. please wait for a moment...")
            interstitial = try await setupFullAds(self)
            
            if let interstitial {
                interstitial.fullScreenContentDelegate = self
                view.isUserInteractionEnabled = false
                interstitial.present(fromRootViewController: self)
            }
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        view.isUserInteractionEnabled = true
        SwiftSpinner.hide()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        view.isUserInteractionEnabled = true
        SwiftSpinner.hide()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        view.isUserInteractionEnabled = true
        SwiftSpinner.hide()
    }
}
