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
    
    // Leitner System
    var leitnerSystem: LeitnerSystem<QuizQuestion>!
    
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
            
            // leitnerSystem = LeitnerSystem<QuizQuestion>(itemList: questionList)
            if let savedLeitnerSystem = store.savedLeitnerSystem {
                leitnerSystem = savedLeitnerSystem
            } else {
                leitnerSystem = LeitnerSystem<QuizQuestion>(itemList: questionList)
            }
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
    
    func refreshQuestionList() {
        leitnerSystem = LeitnerSystem<QuizQuestion>(itemList: questionList)
        store.savedLeitnerSystem = leitnerSystem
    }
    
    func replaceLeitnerSystemFromConfigStore() {
        leitnerSystem = store.savedLeitnerSystem
    }
    
    func removeSavedLeitnerSystem() {
        store.savedLeitnerSystem = nil
    }
    
    var currentQuestion: QuizQuestion? {
        return leitnerSystem.getCurrentQuestionStatus()?.item
    }
    
    func submitResultAndGetNextQuestion(currentSuccess: Bool) -> QuizQuestion? {
        let quizQuestion = leitnerSystem.getNextQuestionStatus(currentItemSuccess: currentSuccess)?.item
        store.savedLeitnerSystem = leitnerSystem
        return quizQuestion
    }
    
    var isAllQuestionFinished: Bool {
        return leitnerSystem.isAllQuestionFinished
    }
    
    var quizStatus: String {
        return leitnerSystem.progressInfo.description
    }
}
