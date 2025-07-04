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
      return "Match the Keys".localized()
    case .guessName:
      return "Guess the Name".localized()
    }
  }
  
  var identifier: String {
    switch self {
    case .matchKeys:
      return "matchKeys"
    case .guessName:
      return "guessName"
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
  var currentType: QuizType! {
    store.typeOfQuestions
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
  
  func saveLeitnerSystemToStore() {
    store.savedLeitnerSystem = leitnerSystem
  }
  
  func removeSavedLeitnerSystem() {
    store.savedLeitnerSystem = nil
  }
  
  var currentQuestion: QuizQuestion? {
    return leitnerSystem.getCurrentQuestionStatus()?.item
  }
  
  func submitResultAndGetNextQuestion(currentSuccess: Bool) -> QuizQuestion? {
    let quizQuestion = leitnerSystem.getNextQuestionStatus(currentItemSuccess: currentSuccess)?.item
    leitnerSystem.incrementQuestionStatusCount(isSuccess: currentSuccess)
    store.savedLeitnerSystem = leitnerSystem
    return quizQuestion
  }
  
  var isFirstQuestion: Bool {
    return leitnerSystem.isFirstQuestion
  }
  
  var isAllQuestionFinished: Bool {
    return leitnerSystem.isAllQuestionFinished
  }
  
  var quizStatus: String {
    return leitnerSystem.progressInfo.labelText
  }
  
  var finishedCount: Int {
    return leitnerSystem.progressInfo.finishedBoxCount
  }
  
  var inStudyingCount: Int {
    let progressInfo = leitnerSystem.progressInfo
    return progressInfo.learningBoxOneCount + progressInfo.learningBoxTwoCount + progressInfo.learningBoxThreeCount
  }
  
  var notStudyingYetCount: Int {
    return leitnerSystem.progressInfo.startBoxCount
  }
  
  var statsInfoForTable: [(name: String, value: Int)] {
    var result: [(name: String, value: Int)] = []
    let statsInfo = leitnerSystem.statsInfo
    
    result.append(("Total Questions".localized(), statsInfo.originalItemListCount))
    result.append(("Total Cycle".localized(), statsInfo.day))
    result.append(("Try Count".localized(), statsInfo.tryCount))
    result.append(("Success Count".localized(), statsInfo.successCount))
    result.append(("Failed Count".localized(), statsInfo.failedCount))
    
    return result
  }
  
  func incrementTryCount() {
    leitnerSystem.incrementTryCount()
  }
  
  func incrementSuccessCount() {
    leitnerSystem.incrementSuccessCount()
  }
  
  func incrementFailedCount() {
    leitnerSystem.incrementFailedCount()
  }
  
  func studyingProgress(isBeforeSubmit: Bool) -> (isPhaseOne: Bool, percent: Float) {
    let info = leitnerSystem.forecastProgressInfo(isBeforeSubmit: isBeforeSubmit)
    let isPhaseOne = info.phase == .phaseOne
    
    return (isPhaseOne, info.percent)
  }
  
  func dayQuestionProgress(isBeforeSubmit: Bool) -> Float {
    let currentNumber = leitnerSystem.progressInfo.currentDQIndex + (isBeforeSubmit ? 0 : 1)
    return Float(currentNumber) / Float(leitnerSystem.progressInfo.dailyQuestionCount)
  }
}
