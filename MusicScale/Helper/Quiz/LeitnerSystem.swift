//
//  LeitnerSystem.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/05.
//

import Foundation

protocol LeitnerSystemDelegate: AnyObject {
    func didDayPassed<T: Codable>(_ controller: LeitnerSystem<T>, newDay: Int)
}

struct LeitnerItem<T: Codable>: Codable {
    var item: T
    fileprivate var boxNumber: Int
    fileprivate var seq: Int
    fileprivate(set) var isSuccess: Bool = false
    
    mutating func setSuccess(_ isSuccess: Bool) {
        self.isSuccess = isSuccess
    }
}

struct LeitnerProgressInfo: Codable, CustomStringConvertible {
    var description: String {
        return "CDI:\(currentDQIndex), day:\(day), dailyQuest: \(dailyQuestionCount), start: \(startBoxCount), box_one: \(learningBoxOneCount), box_two: \(learningBoxTwoCount), box_three: \(learningBoxThreeCount), finished: \(finishedBoxCount)"
    }
    var labelText: String {
        return "Cycle: \(day) | Quest of Cycle: \(currentDQIndex + 1) / \(dailyQuestionCount) | Not Studying Yet: \(startBoxCount) | In Studying: \(learningBoxOneCount + learningBoxTwoCount + learningBoxThreeCount) | Finished: \(finishedBoxCount)"
    }
    
    let currentDQIndex, day, totalBoxCount, dailyQuestionCount, startBoxCount: Int
    let learningBoxOneCount, learningBoxTwoCount, learningBoxThreeCount: Int
    let finishedBoxCount, originalItemListCount: Int
    let isSameCountOriginalAndLeitnerBoxes: Bool
}

struct LeitnerStatsInfo: Codable {
    let day, originalItemListCount, tryCount, successCount, failedCount: Int
}

struct LeitnerForecastProgressInfo: Codable {
    
    // day 0: (진행 문제수 / 전체 문제수)
    // day 1 ~ : (완료 문제수 / 전체 문제수)
    enum Phase: Codable {
        case phaseOne, phaseTwo
    }
    
    var phase: Phase
    var percent: Float
    
}
 
struct LeitnerSystem<T: Codable>: Codable {
    /*
     Three Boxes
     
     Suppose there are 3 boxes of cards called "Box 1", "Box 2" and "Box 3".
     The cards in Box 1 are the ones that the learner often makes mistakes with, and Box 3 contains the cards that they know very well.
     They might choose to study the Box 1 cards once a day, Box 2 every 3 days, and Box 3 cards every 5 days.
     If they look at a card in Box 1 and get the correct answer, they "promote" it to Box 2.
     A correct answer with a card in Box 2 "promotes" that card to Box 3.
     If they make a mistake with a card in Box 2 or Box 3, it gets "demoted" to the first box, which forces the learner to study that card more often.

     The advantage of this method is that the learner can focus on the most difficult flashcards, which remain in the first few groups. The result is, ideally, a reduction in the amount of study time needed.
     
     시작 박스 0, [1 2 3], 끝 박스 4
     Day 0: start list 순회 -> 맞춘건 box 2, 틀린건 box 1
     day 1: box 1
     day 2: box 1
     day 3: box 1 + 2
     day 4: box 1
     day 5: box 1 + 3
     day 6: box 1 + 2
     day 7: box 1 ...
     ...
     전부 finished 되었으면 일정 종료
     */
    private let BOX_ONE = 0
    private let BOX_TWO = 1
    private let BOX_THREE = 2
    private let BOX_FINISHED = 3
    
    weak var delegate: LeitnerSystemDelegate?

    private(set) var day: Int = 0 {
        didSet {
            if let delegate = delegate {
                delegate.didDayPassed(self, newDay: day)
            }
        }
    }
    private var originalItemList: [T] = []
    private var leitnerItemStartingList: [LeitnerItem<T>] = []
    private var leitnerLearningLists: [[LeitnerItem<T>]] = [[], [], []]
    private var leitnerFinishedList: [LeitnerItem<T>] = []
    private(set) var dailyQuestionList: [LeitnerItem<T>] = []
    private var dailyNonQuestList: [LeitnerItem<T>] = []
    
    // Stats
    private(set) var tryCount: Int = 0
    private(set) var successCount: Int = 0
    private(set) var failedCount: Int = 0

    mutating func incrementTryCount() {
        tryCount += 1
    }
    
    mutating func incrementSuccessCount() {
        successCount += 1
    }
    
    mutating func incrementFailedCount() {
        failedCount += 1
    }
    
    mutating func incrementQuestionStatusCount(isSuccess: Bool) {
        isSuccess ? incrementSuccessCount() : incrementFailedCount()
    }
    
    /// 내부 인덱스 변수
    private var currentDQIndex = 0
    
    enum CodingKeys: String, CodingKey {
        case day
        case originalItemList
        case leitnerItemStartingList
        case leitnerLearningLists
        case leitnerFinishedList
        case dailyQuestionList
        case dailyNonQuestList
        case currentDQIndex
        
        case tryCount
        case successCount
        case failedCount
        
        // // computed properties (안됨)
        // case dailyQuestionCount
        // case isAllQuestionFinished
        // case progressInfo
        
    }
    
    init(itemList: [T]) {
        originalItemList = itemList
        leitnerItemStartingList = itemList.enumerated().map { LeitnerItem(item: $1, boxNumber: 0, seq: $0) }
        generateDailyQuestionList()
    }
    
    var dailyQuestionCount: Int {
        return dailyQuestionList.count
    }
    
    func getQuestionStatus(index: Int) -> LeitnerItem<T>? {
        return dailyQuestionList[safe: index]
    }
    
    /// 현재 내부 인덱스의 값 반환
    func getCurrentQuestionStatus() -> LeitnerItem<T>? {
        return getQuestionStatus(index: currentDQIndex)
    }
    
    /// 다음날이 있는 경우, 다음날의 값 반환
    mutating func getNextQuestionStatus() -> LeitnerItem<T>? {
        // 인덱스가 마지막이라면 -> 다음 day로 이동
        if currentDQIndex == (dailyQuestionCount - 1) {
            if !moveNextDay() {
                return nil
            }
            return getQuestionStatus(index: currentDQIndex)
        }
        
        currentDQIndex += 1
        return getQuestionStatus(index: currentDQIndex)
    }
    
    /// 현재 아이템의 정답 여부를 제출하고, 다음날 값 반환
    mutating func getNextQuestionStatus(currentItemSuccess: Bool) -> LeitnerItem<T>? {
        guard updateQuestionStatus(index: currentDQIndex, isSuccess: currentItemSuccess) else {
            return nil
        }
        return getNextQuestionStatus()
    }
    
    mutating func updateQuestionStatus(index: Int, isSuccess: Bool) -> Bool {
        guard (dailyQuestionList[safe: index] != nil) else {
            return false
        }
        dailyQuestionList[index].setSuccess(isSuccess)
        return true
    }
    
    var isFirstQuestion: Bool {
        return day == 0 && currentDQIndex == 0
    }
    
    var isAllQuestionFinished: Bool {
        return originalItemList.count == leitnerFinishedList.count
    }
    
    mutating func moveNextDay() -> Bool {
        if isAllQuestionFinished {
            return false
        }
        
        promoteQuestionList()
        day += 1
        currentDQIndex = 0
        generateDailyQuestionList()
        return true
    }
    
    // mutating func movePrevDay() {
    //     if day <= 1 {
    //         return
    //     }
    //     day -= 1
    // }
    
    /// 문제 출제 리스트
    private mutating func generateDailyQuestionList() {
        if day == 0 {
            dailyQuestionList = leitnerItemStartingList
            return
        }
        
        // BOX_ONE은 매일 출제
        var questionList = leitnerLearningLists[BOX_ONE]
        var nonQuestList: [LeitnerItem<T>] = []
        
        // questionList.isEmpty 이면 다음 순위 출제
        // BOX_TWO는 3일 간격으로 출제
        if questionList.isEmpty || day % 3 == 0 {
            questionList += leitnerLearningLists[BOX_TWO]
        } else {
            nonQuestList += leitnerLearningLists[BOX_TWO]
        }
        
        // questionList.isEmpty 이면 다음 순위 출제
        // BOX_THREE는 5일 간격으로 출제
        if questionList.isEmpty || day % 5 == 0 {
            questionList += leitnerLearningLists[BOX_THREE]
        } else {
            nonQuestList += leitnerLearningLists[BOX_THREE]
        }
        
        dailyQuestionList = questionList
        dailyNonQuestList = nonQuestList + leitnerFinishedList
    }
    
    /// 정답(isSuccess)여부로 박스 이동 및 재배열
    /// day1 이후부터만 실행
    private mutating func promoteQuestionList() {
        // 박스 번호 변경
        let updatedDailyQuestionList: [LeitnerItem<T>] = dailyQuestionList.map { item in
            var newItem = item
            if day == 0 {
                newItem.boxNumber = item.isSuccess ? 2 : 1
                return newItem
            }
            
            if item.isSuccess {
                if item.boxNumber < 4 {
                    newItem.boxNumber = item.boxNumber + 1
                }
            } else {
                if item.boxNumber > 1 {
                    newItem.boxNumber = item.boxNumber - 1
                }
            }
            
            return newItem
        }
        
        // 박스 이동
        leitnerItemStartingList = []
        leitnerLearningLists[BOX_ONE] = []
        leitnerLearningLists[BOX_TWO] = []
        leitnerLearningLists[BOX_THREE] = []
        leitnerFinishedList = []
        
        let totalQuestionList = updatedDailyQuestionList + dailyNonQuestList
        
        totalQuestionList.forEach { item in
            switch item.boxNumber {
            case 0:
                leitnerItemStartingList.append(item)
            case 1:
                leitnerLearningLists[BOX_ONE].append(item)
            case 2:
                leitnerLearningLists[BOX_TWO].append(item)
            case 3:
                leitnerLearningLists[BOX_THREE].append(item)
            case 4:
                leitnerFinishedList.append(item)
            default:
                break
            }
        }
    }
    
    var totalBoxCount: Int {
        return leitnerItemStartingList.count + leitnerLearningLists[BOX_ONE].count + leitnerLearningLists[BOX_TWO].count + leitnerLearningLists[BOX_THREE].count + leitnerFinishedList.count
    }
    
    var progressInfo: LeitnerProgressInfo {
        return LeitnerProgressInfo(currentDQIndex: currentDQIndex,
                            day: day,
                            totalBoxCount: totalBoxCount,
                            dailyQuestionCount: dailyQuestionCount,
                            startBoxCount: leitnerItemStartingList.count,
                            learningBoxOneCount: leitnerLearningLists[BOX_ONE].count,
                            learningBoxTwoCount: leitnerLearningLists[BOX_TWO].count,
                            learningBoxThreeCount: leitnerLearningLists[BOX_THREE].count,
                            finishedBoxCount: leitnerFinishedList.count,
                            originalItemListCount: originalItemList.count,
                            isSameCountOriginalAndLeitnerBoxes: originalItemList.count == totalBoxCount)
    }
    
    func forecastProgressInfo(isBeforeSubmit: Bool) -> LeitnerForecastProgressInfo {
        let totalBoxCount: Float = Float(totalBoxCount)
        let dayZeroProgress = currentDQIndex
        
        var phase: LeitnerForecastProgressInfo.Phase {
            return day == 0 ? .phaseOne : .phaseTwo
        }
        
        var percent: Float {
            switch phase {
            case .phaseOne:
                return Float(dayZeroProgress + (isBeforeSubmit ? 0 : 1)) / totalBoxCount
            case .phaseTwo:
                
                let finishCount = leitnerFinishedList.count
                return Float(finishCount) / totalBoxCount
            }
        }
        
        return LeitnerForecastProgressInfo(phase: phase, percent: percent)
    }
    
    var statsInfo: LeitnerStatsInfo {
        return LeitnerStatsInfo(day: day, originalItemListCount: originalItemList.count, tryCount: tryCount, successCount: successCount, failedCount: failedCount)
    }
    
    func printDailyQuestionList(printDailyQuestion: Bool = true, printBoxDetail: Bool = false) {
        print("============= Day \(day) =============")
        let displayQuestion: (LeitnerItem<T>) -> () = { item in
            let question = item.item as? QuizQuestion
            let name = question?.scaleInfo.name ?? "unknown"
            let order = question?.isAscending ?? false
            let key = question?.key.textValue ?? ""
            print("BoxNumber: \(item.boxNumber), Seq: \(item.seq), success: \(item.isSuccess), itemName: \(name) \(key) \(order)")
        }
        
        let totalBoxCount = leitnerItemStartingList.count + leitnerLearningLists[BOX_ONE].count + leitnerLearningLists[BOX_TWO].count + leitnerLearningLists[BOX_THREE].count + leitnerFinishedList.count
        
        print(" - Picked Daily Questions (count: \(dailyQuestionCount))")
        printDailyQuestion ? dailyQuestionList.forEach(displayQuestion) : nil
        print(" - Start box (count: \(leitnerItemStartingList.count))")
        printBoxDetail ? leitnerItemStartingList.forEach(displayQuestion) : nil
        print(" - box 1 (count: \(leitnerLearningLists[BOX_ONE].count))")
        printBoxDetail ? leitnerLearningLists[BOX_ONE].forEach(displayQuestion) : nil
        print(" - box 2 (count: \(leitnerLearningLists[BOX_TWO].count))")
        printBoxDetail ? leitnerLearningLists[BOX_TWO].forEach(displayQuestion) : nil
        print(" - box 3 (count: \(leitnerLearningLists[BOX_THREE].count))")
        printBoxDetail ? leitnerLearningLists[BOX_THREE].forEach(displayQuestion) : nil
        print(" - Finished box (count: \(leitnerFinishedList.count))")
        printBoxDetail ? leitnerFinishedList.forEach(displayQuestion) : nil
        print(" - Total Box Count: \(totalBoxCount)")
        print(" - Original Items Count: \(originalItemList.count), isSameWithBoxCount? \(originalItemList.count == totalBoxCount)")
        
    }
}
