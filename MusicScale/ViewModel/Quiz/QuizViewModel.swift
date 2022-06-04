//
//  QuizViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/03.
//

import Foundation

enum QuizType: Int, Codable {
    case matchKeys = 0, guessName = 1
    
    var descriptionValue: String {
        switch self {
        case .matchKeys:
            return "Match the notes with the given scale name"
        case .guessName:
            return "Look at/Listen to the scale and guess the name"
        }
    }
    
    var titleValue: String {
        switch self {
        case .matchKeys:
            return "Match the Keys"
        case .guessName:
            return "Guess the Name"
        }
    }
}

class QuizViewModel {
    
    private var store = QuizConfigStore.shared
    private var helper = QuizHelper()
    
    private(set) var totalEntityData: [ScaleInfoEntity]!
    private(set) var scaleIdList: Set<UUID> = []
    var idListCount: Int {
        return scaleIdList.count
    }
    
    private(set) var numberOfQuestions: [Int] = [
        5,
        10,
        20,
        30,
        50,
        100,
        -999, // Infinity
    ]
    
    var numOfQuestTexts: [String] {
        numberOfQuestions.map{ $0 != -999 ? "\($0)" : "Infinity" }
    }
    
    func numberOfQuestions(of index: Int) -> Int {
        return numberOfQuestions[index]
    }
    
    func numOfQuestText(from number: Int) -> String {
        if number != -999 {
            return "\(number)"
        }
        
        return "Infinity"
    }
    
    private(set) var typeOfQuestions: [QuizType] = [.matchKeys, .guessName]
    
    init() {
        loadScaleListFromConfigStore()
        
        do {
            totalEntityData = try ScaleInfoCDService.shared.readCoreData()
        } catch {
            print("QuizViewModel: Failed fetching data:", error)
        }
    }
    
    func appendIdToScaleList(_ uuid: UUID) {
        scaleIdList.insert(uuid)
    }
    
    func setScaleList(_ idList: [UUID]) {
        scaleIdList = Set(idList)
    }
    
    func containsId(_ uuid: UUID) -> Bool {
        return scaleIdList.contains(uuid)
    }
    
    func removeId(_ uuid: UUID) {
        scaleIdList.remove(uuid)
    }
    
    func saveScaleListToConfigStore() {
        store.selectedScaleInfoId = scaleIdList
    }
    
    func loadScaleListFromConfigStore() {
        scaleIdList = store.selectedScaleInfoId
    }
    
    var questionList: [QuizQuestion] {
        let config = store.quizConfigChunk
        return helper.makeQuestionList(chunk: config, infoList: totalEntityData.compactMap { ScaleInfoCDService.shared.toScaleInfoStruct(from: $0) })
    }
}
