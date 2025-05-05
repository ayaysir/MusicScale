//
//  QuizHelper.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/04.
//

import Foundation

struct QuizHelper {
  /*
   var availableKeys: Set<Music.Key>
   var ascSelected, descSelected: Bool
   var selectedScaleInfoId: Set<UUID>
   var numberOfQuestions: Int
   var typeOfQuestions: QuizType
   var enharmonicMode: EnharmonicMode
   */
  
  func makeQuestionList(chunk config: QuizConfig, infoList: [ScaleInfo]) -> [QuizQuestion] {
    
    // 1) 사용자가 선택한 스케일만 추출
    let scaleList = infoList.filter { info in
      return config.selectedScaleInfoId.contains(info.id)
    }
    
    // 3) 가능한 경우의 수 전부 (asc, desc, key)
    let totalQuestions = scaleList.reduce(into: [QuizQuestion]()) { partialResult, info in
      for key in config.availableKeys {
        if config.ascSelected {
          partialResult.append(QuizQuestion(scaleInfo: info, isAscending: true, key: key))
        }
        
        if config.descSelected {
          partialResult.append(QuizQuestion(scaleInfo: info, isAscending: false, key: key))
        }
      }
    }
    return totalQuestions.shuffled()
  }
}
