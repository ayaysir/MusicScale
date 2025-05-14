//
//  MainTabBarController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/29.
//

import UIKit
import AVFAudio
import SwiftUI

class MainTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Appearance
    let currentTheme = UIUserInterfaceStyle(rawValue: AppConfigStore.shared.appAppearance) ?? .unspecified
    currentTheme.overrideAllWindow()
    
    NotificationCenter.default.addObserver(self, selector: #selector(didActivated), name: UIScene.didActivateNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didActivated), name: UIScene.willEnterForegroundNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didInterrupted), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !UserDefaults.standard.bool(forKey: .kIsWhatsNew160Appeared) {
      UserDefaults.standard.set(true, forKey: .kIsWhatsNew160Appeared)
      
      showIAPWhatsNewPage(self, primaryAction: {
        self.tabBarController?.selectedIndex = 3
      })
    } else if Double.random(in: 0...1) <= 0.2 && AdsManager.SHOW_AD {
      showIAPPromtionPage(self) {
        self.tabBarController?.selectedIndex = 3
      }
    }
  }
  
  @objc func didActivated(_ notification: Notification? = nil) {
    // print(#function)
    // AwakeFromBackground: 테스트 완료되면 주석처리
    // simpleAlert(self, message: "didActivated: \(String(describing: notification?.name))")
    
    GlobalConductor.shared.startEngine()
    GlobalGenerator.shared.startEngine()
  }
  
  @objc func willResignActive() {
    // print(#function)
    GlobalConductor.shared.pauseEngine()
    GlobalGenerator.shared.pauseEngine()
  }
  
  @objc func didInterrupted(notification: Notification) {
    guard let userInfo = notification.userInfo,
          let typeKeyRaw = userInfo[AVAudioSessionInterruptionTypeKey],
          let typeKey = AVAudioSession.InterruptionType(rawValue: typeKeyRaw as! UInt) else {
      simpleAlert(self, message: "typeKey is nil")
      return
    }
    
    if typeKey == .ended {
      didActivated()
    }
  }
}
