//
//  UIViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/17.
//

import UIKit

extension UIViewController {
  
  /// 상단 바(내비게이션 바) 높이 구하기
  var topBarHeight: CGFloat {
    var top = self.navigationController?.navigationBar.frame.height ?? 0.0
    if #available(iOS 13.0, *) {
      top += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    } else {
      top += UIApplication.shared.statusBarFrame.height
    }
    return top
  }
}
