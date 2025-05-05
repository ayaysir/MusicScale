//
//  UIBarButtonItem+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/18.
//

import UIKit

extension UIBarButtonItem {
  
  // https://stackoverflow.com/questions/14318368/uibarbuttonitem-how-can-i-find-its-frame
  var frame: CGRect? {
    guard let view = self.value(forKey: "view") as? UIView else {
      return nil
    }
    return view.frame
  }
  
}
