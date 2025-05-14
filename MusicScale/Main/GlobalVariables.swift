//
//  GlobalVariables.swift
//  MusicScale
//
//  Created by 윤범태 on 5/5/25.
//

import Foundation

// MARK: - Typealiases

typealias InfoWithSimilarity = (infoVM: ScaleInfoViewModel, similarity: Double)

extension Notification.Name {
  // MARK: - Notification Names
  
  static let downloadedFromArchive = Notification.Name("DownloadedFromArchive")
  static let networkIsOffline = Notification.Name("NetworkIsOffline")
  static let awakeFromBackground = Notification.Name("AwakeFromBackground")
}

extension String {
  // MARK: - App
  
  static let cfgAppCustomScale = "APP_cfgAppCustomScale"
  static let cfgAppPlaybackInstrument = "APP_cfgAppPlaybackInstrument"
  static let cfgAppPianoInstrument = "APP_cfgAppPianoInstrument"
  static let cfgAppAppearance = "APP_cfgAppAppearance"
  static let cfgAppIsShowHWKeyboardMapping = "APP_cfgAppIsShowHWKeyboardMapping"
  
  // MARK: - Sort
  
  static let kSortState = "SORTFILTER_SortState"
  static let kSortOrder = "SORTFILTER_SortOrder"
  
  // MARK: - ScaleInfo
  
  static let kOctaveShift = "ScaleInfo_CONFIG_OctaveShift"
  static let kTempo = "ScaleInfo_CONFIG_Tempo"
  static let kDegreesOrder = "ScaleInfo_CONFIG_DegreesOrder"
  static let kTranspose = "ScaleInfo_CONFIG_Transpose"
  static let kEnharmonicMode = "ScaleInfo_CONFIG_EnharmonicMode"
  static let kCustomEnharmonics = "ScaleInfo_CONFIG_CustomEnharmonics"
  
  // MARK: Quiz
  
  static var cfgQuizKeyList = "QUIZ_cfgQuizKeyList"
  static var cfgQuizAscSelected = "QUIZ_cfgQuizAscSelected"
  static var cfgQuizDescSelected = "QUIZ_cfgQuizDescSelected"
  static var cfgQuizScaleIdList = "QUIZ_cfgQuizScaleIdList"
  static var cfgQuizNumOfQuest = "QUIZ_cfgQuizNumOfQuest"
  static var cfgQuizTypeOfQuest = "QUIZ_cfgQuizTypeOfQuest"
  static var cfgQuizEnharmonicMode = "QUIZ_cfgQuizEnharmonicMode"
  static var cfgQuizLeitnerSystem = "QUIZ_cfgQuizLeitnerSystem"
  
  // MARK: - 키보드 모드
  
  static let kKeyPressMode = "Keyboard_CONFIG_KeyPressMode"
}

extension String {
  // MARK: - Whats New
  static var kIsWhatsNew160Appeared = "WN_1.6.0"
}
