//
//  LeitnerSystem.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/05.
//

import Foundation

struct LeitnerItem<T: Codable>: Codable {
    var item: T
    fileprivate var boxNumber: Int
    fileprivate var seq: Int
    fileprivate(set) var isSuccess: Bool = false
    
    mutating func setSuccess(_ isSuccess: Bool) {
        self.isSuccess = isSuccess
    }
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

    private(set) var day: Int = 0
    private var originalItemList: [T] = []
    private var leitnerItemStartingList: [LeitnerItem<T>] = []
    private var leitnerLearningLists: [[LeitnerItem<T>]] = [[], [], []]
    private var leitnerFinishedList: [LeitnerItem<T>] = []
    private(set) var dailyQuestionList: [LeitnerItem<T>] = []
    private var dailyNonQuestList: [LeitnerItem<T>] = []
    
    enum CodingKeys: String, CodingKey {
        case day, leitnerItemStartingList, leitnerLearningLists, leitnerFinishedList
    }
    
    init(itemList: [T]) {
        originalItemList = itemList
        leitnerItemStartingList = itemList.enumerated().map { LeitnerItem(item: $1, boxNumber: 0, seq: $0) }
        generateDailyQuestionList()
    }
    
    var dailyQuestionCount: Int {
        return dailyQuestionList.count
    }
    
    func getQuestionStatus(index: Int) -> LeitnerItem<T> {
        return dailyQuestionList[index]
    }
    
    mutating func updateQuestionStatus(index: Int, isSuccess: Bool) {
        dailyQuestionList[index].setSuccess(isSuccess)
    }
    
    var isAllQuestionFinished: Bool {
        return originalItemList.count == leitnerFinishedList.count
    }
    
    /// 문제 풀이 중간 또는 완료 단계 저장
    // mutating func saveQuestionStatus(questionList: [LeitnerItem<T>]) {
    //     dailyQuestionList = questionList
    // }
    
    mutating func moveNextDay() {
        if isAllQuestionFinished {
            return
        }
        
        promoteQuestionList()
        day += 1
        generateDailyQuestionList()
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
        
        // BOX_TWO는 3일 간격으로 출제
        if day % 3 == 0 {
            questionList += leitnerLearningLists[BOX_TWO]
        } else {
            nonQuestList += leitnerLearningLists[BOX_TWO]
        }
        
        // BOX_THREE는 5일 간격으로 출제
        if day % 5 == 0 {
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
        
        // let movedList = updatedDailyQuestionList.reduce(into: Array(repeating: [LeitnerItem<T>](), count: 4)) { partialResult, item in
        //     switch item.boxNumber {
        //     case 1:
        //         partialResult[BOX_ONE].append(item)
        //     case 2:
        //         partialResult[BOX_TWO].append(item)
        //     case 3:
        //         partialResult[BOX_THREE].append(item)
        //     case 4:
        //         partialResult[BOX_FINISHED].append(item)
        //     default:
        //         break
        //     }
        // }
        //
        // leitnerLearningLists[BOX_ONE] = movedList[BOX_ONE]
        // leitnerLearningLists[BOX_TWO] = movedList[BOX_TWO]
        // leitnerLearningLists[BOX_THREE] = movedList[BOX_THREE]
        // leitnerFinishedList = movedList[BOX_FINISHED]
            
    }
    
    func printDailyQuestionList() {
        print("============= Day \(day) =============")
        let displayQuestion: (LeitnerItem<T>) -> () = { item in
            let question = item.item as? QuizQuestion
            let name = question?.scaleInfo.name ?? "unknown"
            let order = question?.isAscending ?? false
            let key = question?.key.textValue ?? ""
            print("BoxNumber: \(item.boxNumber), Seq: \(item.seq), success: \(item.isSuccess), itemName: \(name) \(key) \(order)")
        }
        
        let totalBoxCount = leitnerItemStartingList.count + leitnerLearningLists[BOX_ONE].count + leitnerLearningLists[BOX_TWO].count + leitnerLearningLists[BOX_THREE].count + leitnerFinishedList.count
        
        print("----------------Picked Daily Questions (count: \(dailyQuestionCount))-------------------")
        dailyQuestionList.forEach(displayQuestion)
        print("----------------Start box (count: \(leitnerItemStartingList.count))-------------------")
        // leitnerItemStartingList.forEach(displayQuestion)
        print("----------------box 1 (count: \(leitnerLearningLists[BOX_ONE].count))-------------------")
        // leitnerLearningLists[BOX_ONE].forEach(displayQuestion)
        print("----------------box 2 (count: \(leitnerLearningLists[BOX_TWO].count))-------------------")
        // leitnerLearningLists[BOX_TWO].forEach(displayQuestion)
        print("----------------box 3 (count: \(leitnerLearningLists[BOX_THREE].count))-------------------")
        // leitnerLearningLists[BOX_THREE].forEach(displayQuestion)
        print("----------------Finished box (count: \(leitnerFinishedList.count))--------------")
        // leitnerFinishedList.forEach(displayQuestion)
        print("----------------Total Box Count: \(totalBoxCount)")
        print("----------------Original Items Count: \(originalItemList.count), isSameWithBoxCount? \(originalItemList.count == totalBoxCount)")
        print("=================================================")
        
    }
    
}
