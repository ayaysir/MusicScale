//
//  OrientationUtil.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/19.
//

import UIKit

// https://stackoverflow.com/questions/28938660/how-to-lock-orientation-of-one-view-controller-to-portrait-mode-only-in-swift
struct OrientationUtil {
  
  static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
    
    if let delegate = UIApplication.shared.delegate as? AppDelegate {
      delegate.orientationLock = orientation
    }
  }
  
  /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
  static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
    
    self.lockOrientation(orientation)
    
    UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    UINavigationController.attemptRotationToDeviceOrientation()
  }
}

var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

var isLandcapeWhenStart: Bool {
  if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
    switch orientation {
    case .landscapeLeft, .landscapeRight:
      return true
    default:
      break
    }
  }
  return false
}

var isLandscape: Bool {
  if UIDevice.current.orientation == .unknown {
    return isLandcapeWhenStart
  }
  
  if UIDevice.current.orientation.isLandscape {
    return true
  }
  
  if UIDevice.current.orientation.isFlat {
    return true
  }
  
  return false
}

/// viewDidLoad, viewWillTransition(...with coordinator...)에 사용
func hideTabBarWhenLandscape(_ viewController: UIViewController) {
  viewController.tabBarController?.tabBar.isHidden = isLandscape
}

func showTabBar(_ viewController: UIViewController) {
  viewController.tabBarController?.tabBar.isHidden = false
}

var isIpad129: Bool {
  // iPad Pro 5 12.9
  let name = UIDevice().type.rawValue
  return name.starts(with: "iPad Pro") && name.contains("12.9")
}

var isIpadMini: Bool {
  let name = UIDevice().type.rawValue
  return name.starts(with: "iPad Mini")
}

var isIpadPro1st97: Bool {
  let name = UIDevice().type.rawValue
  return name.starts(with: "iPad Pro 9.7")
}

let DEF_STAFFWIDTH = 460
