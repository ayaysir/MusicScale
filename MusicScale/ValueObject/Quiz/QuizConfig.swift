//
//  QuizConfig.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/04.
//

import Foundation

struct QuizConfig: Codable {
    
    var availableKeys: Set<Music.Key>
    var ascSelected, descSelected: Bool
    var selectedScaleInfoId: Set<UUID>
    var numberOfQuestions: Int
    var typeOfQuestions: QuizType
    var enharmonicMode: EnharmonicMode
}
