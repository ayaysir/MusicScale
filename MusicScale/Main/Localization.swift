//
//  Localization.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/22.
//

import Foundation

extension String {
  func localized(comment: String = "") -> String {
    NSLocalizedString(self, comment: comment)
  }
  
  /// myLabel.text = "My Age %d".localized(with: 26, comment: "age")
  func localized(with arguments: CVarArg..., comment: String = "") -> String {
    String(format: self.localized(comment: comment), arguments)
  }
  
  func localizedFormat(_ arguments: CVarArg..., comment: String = "") -> String {
    .localizedStringWithFormat(self, arguments)
  }
}

enum TextViewLocalization: String {
  case CreateComment = "TextView_CreateComment"
  case SettingEnharmonicHelp = "TextView_SettingEnharmonicHelp"
  
  func localized() -> String {
    self.rawValue.localized()
  }
}
