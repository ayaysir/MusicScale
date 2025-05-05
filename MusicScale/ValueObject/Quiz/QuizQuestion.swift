//
//  QuizQuestion.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/04.
//

import Foundation

struct QuizQuestion: Codable, CustomStringConvertible {
  
  var description: String {
    return "(\(scaleInfo.name), order: \(isAscending ? "ASC" : "DESC"), key: \(key))"
  }
  
  var labelTitle: String {
    return "\(key.textValue) \(scaleInfo.name)"
  }
  
  var scaleInfo: ScaleInfo
  var isAscending: Bool
  var key: Music.Key
}
