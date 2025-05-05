//
//  SceneDelegate.swift
//  MusicScale
//
//  Created by yoonbumtae on 2021/12/15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // UIWindow를 UIWindowScene에 연결할 때 초기 설정을 수행합니다.
    guard let _ = (scene as? UIWindowScene) else { return }
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // 장면이 시스템에 의해 해제될 때 호출됩니다.
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // 장면이 활성 상태로 전환되었을 때 호출됩니다.
    print(#function)
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // 장면이 일시적으로 비활성 상태가 되기 직전에 호출됩니다.
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // 장면이 백그라운드에서 포그라운드로 전환될 때 호출됩니다.
    print(#function)
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // 장면이 백그라운드로 전환될 때 호출되며, 데이터 저장 등을 수행합니다.
    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
  }
}
