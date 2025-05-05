//
//  Localization.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/22.
//

import Foundation

extension String {
  
  func localized(comment: String = "") -> String {
    return NSLocalizedString(self, comment: comment)
  }
  
  /// myLabel.text = "My Age %d".localized(with: 26, comment: "age")
  func localized(with argument: CVarArg, comment: String = "") -> String {
    return String(format: self.localized(comment: comment), argument)
  }
}

enum TextViewLocalization: String {
  case CreateComment = "TextView_CreateComment"
  case SettingEnharmonicHelp = "TextView_SettingEnharmonicHelp"
  
  func localized() -> String {
    self.rawValue.localized()
  }
}
