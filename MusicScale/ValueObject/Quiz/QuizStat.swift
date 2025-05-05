//
//  QuizStat.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/12/03.
//

import Foundation

struct QuizStat: Codable {
  var scaleName: String
  var key: String
  var order: String
  var typeOfQuestion: String
  var isAnsweredCorrectly: Bool
  var solveDate: Date
  var elapsedSeconds: Int16
  var studyStatus: String
  
  enum CodingKeys: String, CodingKey, CaseIterable {
    case scaleName = "scale_name"
    case key
    case order
    case typeOfQuestion = "type_of_question"
    case isAnsweredCorrectly = "is_answered_correctly"
    case solveDate = "solve_date"
    case elapsedSeconds = "elapsed_seconds"
    case studyStatus = "study_status"
  }
}
