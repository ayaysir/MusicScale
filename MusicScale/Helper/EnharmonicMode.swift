//
//  EnharmonicMode.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/21.
//

import Foundation

enum EnharmonicMode: Int, Codable, CaseIterable {
  case standard, sharpAndNatural, flatAndNatural, userCustom
  
  var titleValue: String {
    switch self {
    case .standard:
      return "Scale's default".localized()
    case .sharpAndNatural:
      return "Sharp(♯) only".localized()
    case .flatAndNatural:
      return "Flat(♭) only".localized()
    case .userCustom:
      return "My Custom".localized()
    }
  }
  
  static var titleValues: [String] {
    return self.allCases.map { $0.titleValue }
  }
  
  var noteStrOfFirstOctave: [NoteStrPair]? {
    switch self {
    case .standard:
      return nil
    case .sharpAndNatural:
      return [
        NoteStrPair("", "C"),
        NoteStrPair("^", "C"),
        NoteStrPair("", "D"),
        NoteStrPair("^", "D"),
        NoteStrPair("", "E"),
        NoteStrPair("", "F"),
        NoteStrPair("^", "F"),
        NoteStrPair("", "G"),
        NoteStrPair("^", "G"),
        NoteStrPair("", "A"),
        NoteStrPair("^", "A"),
        NoteStrPair("", "B"),
      ]
    case .flatAndNatural:
      return [
        NoteStrPair("", "C"),
        NoteStrPair("_", "D"),
        NoteStrPair("", "D"),
        NoteStrPair("_", "E"),
        NoteStrPair("", "E"),
        NoteStrPair("", "F"),
        NoteStrPair("_", "G"),
        NoteStrPair("", "G"),
        NoteStrPair("_", "A"),
        NoteStrPair("", "A"),
        NoteStrPair("_", "B"),
        NoteStrPair("", "B"),
      ]
    case .userCustom:
      // 저장된 설정이 있는 경우 그것을 불러옴
      let customScale = AppConfigStore.shared.userCustomScale
      if customScale.count == 12 {
        return customScale
      }
      return [
        NoteStrPair("", "C"),
        NoteStrPair("_", "D"),
        NoteStrPair("", "D"),
        NoteStrPair("^", "D"),
        NoteStrPair("", "E"),
        NoteStrPair("", "F"),
        NoteStrPair("^", "F"),
        NoteStrPair("", "G"),
        NoteStrPair("_", "A"),
        NoteStrPair("", "A"),
        NoteStrPair("_", "B"),
        NoteStrPair("", "B"),
      ]
    }
  }
}
