//
//  MainTabBarController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/29.
//

import UIKit
import AVFAudio

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(didActivated), name: UIScene.didActivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didInterrupted), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        
    }
    
    @objc func didActivated() {
        
        GlobalConductor.shared.startEngineOnly()
        GlobalGenerator.shared.startEngine()
    }
    
    @objc func willResignActive() {
        GlobalConductor.shared.pause()
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
            // GlobalConductor.shared.startEngineOnly()
            didActivated()
        }
    }
}
