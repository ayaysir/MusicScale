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
        
        // // 4) shuffle 한 뒤 count만큼 내보냄
        // if config.numberOfQuestions <= totalQuestions.count {
        //     // 4-1) 만들어진 질문 수가 원래 요구한 수보다 크거나 같다면 그 범위만큼 리턴
        //     return Array(totalQuestions.shuffled()[0..<config.numberOfQuestions])
        // } else if config.numberOfQuestions <= 0 && totalQuestions.count > 100 {
        //     // 4-2) 만들어진 질문 수가 100개 초과인데 요구 질문 수가 0 이하(=infinity)일 때, 100개까지 리턴
        //     return try! totalQuestions.makeShuffledArray(totalCount: 100)
        // } else {
        //     // 4-3) 그 외의 경우 (만든 질문 수가 요구 수보다 작다면)
        //     return try! totalQuestions.makeShuffledArray(totalCount: config.numberOfQuestions)
        // }
    }
    
    
    
}
