//
//  GlobalVariables.swift
//  MusicScale
//
//  Created by 윤범태 on 5/5/25.
//

import Foundation

extension Notification.Name {
  static let downloadedFromArchive = Notification.Name("DownloadedFromArchive")
  static let networkIsOffline = Notification.Name("NetworkIsOffline")
  static let awakeFromBackground = Notification.Name("AwakeFromBackground")
}

extension String {
  static let kSortState = "SORTFILTER_SortState"
  static let kSortOrder = "SORTFILTER_SortOrder"
}

extension String {
  static let kOctaveShift = "ScaleInfo_CONFIG_OctaveShift"
  static let kTempo = "ScaleInfo_CONFIG_Tempo"
  static let kDegreesOrder = "ScaleInfo_CONFIG_DegreesOrder"
  static let kTranspose = "ScaleInfo_CONFIG_Transpose"
  static let kEnharmonicMode = "ScaleInfo_CONFIG_EnharmonicMode"
  static let kCustomEnharmonics = "ScaleInfo_CONFIG_CustomEnharmonics"
}
