//
//  MainTabBarController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/29.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(didActivated), name: UIScene.didActivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    @objc func didActivated() {
        GlobalConductor.shared.startEngineOnly()
    }
    
    @objc func willResignActive() {
        GlobalConductor.shared.pause()
    }
}
