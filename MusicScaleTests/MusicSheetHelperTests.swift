//
//  MusicSheetHelperTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2022/05/15.
//

import XCTest
@testable import MusicScale

class MusicSheetHelperTests: XCTestCase {

    var helper = MusicSheetHelper()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_degreesToAbcjsPart() throws {
        
        // given
        let bluesScale = "1 ♭3 4 ♭5 5 ♭7"
        let octatonicScale1 = "1 2 ♭3 4 ♭5 ♭6 6 7"
        let octatonicScale2 = "1 ♭2 ♭3 3 ♯4 5 6 ♭7"
        
        // when
        let result_bluesScale = helper.degreesToAbcjsPart(degrees: bluesScale)
        let result_octatonicScale1 = helper.degreesToAbcjsPart(degrees: octatonicScale1)
        let result_octatonicScale2 = helper.degreesToAbcjsPart(degrees: octatonicScale2)
        
        // then
        XCTAssertEqual(result_bluesScale, "C _E F _G =G _B c")
        XCTAssertEqual(result_octatonicScale1, "C D _E F _G _A =A B c")
        XCTAssertEqual(result_octatonicScale2, "C _D _E =E ^F G A _B c")
        
        let result = helper.degreesToAbcjsPart(degrees: "1 2 ♭3 4 5 ♭6 ♭7 1 2 ♭3 4 5 ♭6 (♮)7 1 ♯1 2 ♯2 3 4 ♯4 5 ♯5 6 ♯6 7", completeFinalNote: false)
        XCTAssertEqual(result, "C D _E F G _A _B C D _E F G _A =B C ^C D ^D E F ^F G ^G A ^A B")
    }
    
    func test_degreesToAbcjsLyric() throws {
        
        // given
        let bluesScale = "1 ♭3 4 ♭5 5 ♭7"
        let octatonicScale1 = "1 2 ♭3 4 ♭5 ♭6 6 7"
        let octatonicScale2 = "1 ♭2 ♭3 3 ♯4 5 6 ♭7"
        
        // when
        let result_bluesScale = helper.degreesToAbcjsLyric(degrees: bluesScale)
        let result_octatonicScale1 = helper.degreesToAbcjsLyric(degrees: octatonicScale1)
        let result_octatonicScale2 = helper.degreesToAbcjsLyric(degrees: octatonicScale2)
        
        // then
        XCTAssertEqual(result_bluesScale, "C E♭ F G♭ G♮ B♭ C")
        XCTAssertEqual(result_octatonicScale1, "C D E♭ F G♭ A♭ A♮ B C")
        XCTAssertEqual(result_octatonicScale2, "C D♭ E♭ E♮ F♯ G A B♭ C")
    }
    
    func test_getIntervalOfAscendingTwoNumPair() throws {
        /*
          1  2  ♭3  4  5  ♭6  ♭7
           +2 +1  +2 +2 +1  +2
         (0,2,3,5,7,8,10)
         
         1   3   ♯4  5   7
           +4  +2  -1  +4
         (0,4,6,7,11)
         
         1  2  3   5   6
          +2 +2  +3  +2
         (0,2,4,7,9)
         
         3~4 는 반음
         
         기타 특이 케이스
         ♭3 3 -> 1
         ♭6 (♮)7 -> 3
         
         */
        
        // MARK: - check throw error
        let leftRightPairsArrayForError: [[NoteNumberPair]] = [
            [NoteNumberPair("", 5), NoteNumberPair("", 4)],
            [NoteNumberPair("^", 1), NoteNumberPair("", 1)],
            [NoteNumberPair("", 3), NoteNumberPair("_", 3)],
            [NoteNumberPair("_", 3), NoteNumberPair("", -1)],
            [NoteNumberPair("_", 7), NoteNumberPair("_", 4)],
//            [("_", 7), ("_", 7)],
        ]
        
        for lhPair in leftRightPairsArrayForError {
            XCTAssertThrowsError(try helper.getIntervalOfAscendingTwoNumPair(leftPair: lhPair[0], rightPair: lhPair[1]))
        }
        
        // MARK: - Check correct result?
        let leftRightPairsArray: [[NoteNumberPair]] = [
            [NoteNumberPair("", 4), NoteNumberPair("", 4)],
            [NoteNumberPair("", 1), NoteNumberPair("", 2)],
            [NoteNumberPair("", 2), NoteNumberPair("_", 3)],
            [NoteNumberPair("_", 3), NoteNumberPair("", 4)],
            [NoteNumberPair("_", 6), NoteNumberPair("_", 7)],
            [NoteNumberPair("", 3), NoteNumberPair("^", 4)],
            [NoteNumberPair("", 1), NoteNumberPair("", 3)],
            [NoteNumberPair("", 5), NoteNumberPair("", 7)],
            [NoteNumberPair("", 3), NoteNumberPair("", 5)],
            [NoteNumberPair("_", 3), NoteNumberPair("=", 3)],
            [NoteNumberPair("_", 6), NoteNumberPair("=", 7)],
            [NoteNumberPair("^", 4), NoteNumberPair("^", 4)],
        ]
        
        var intervals: [Int] = []
        for lrPairs in leftRightPairsArray {
            let interval = try helper.getIntervalOfAscendingTwoNumPair(leftPair: lrPairs[0], rightPair: lrPairs[1])
            intervals.append(interval)
        }
        
        let expectedResults = [0, 2, 1, 2, 2, 2, 4, 4, 3, 1, 3, 0]
        for i in (0...expectedResults.count - 1) {
            XCTAssertEqual(intervals[i], expectedResults[i], "\(i)")
        }
        
    }
    
    func test_getIntegerNotationOfAscending() throws {
        
        let bluesScale = "1 ♭3 4 ♭5 5 ♭7"
        let octatonicScale1 = "1 2 ♭3 4 ♭5 ♭6 6 7"
        let octatonicScale2 = "1 ♭2 ♭3 3 ♯4 5 6 ♭7"
        
        let notations: [[Int]] = [
            try helper.getIntegerNotationOfAscending(degrees: bluesScale),
            try helper.getIntegerNotationOfAscending(degrees: octatonicScale1),
            try helper.getIntegerNotationOfAscending(degrees: octatonicScale2),
        ]
        
        let expectedResults: [[Int]] = [
            [0,3,5,6,7,10],
            [0,2,3,5,6,8,9,11],
            [0,1,3,4,6,7,9,10],
        ]
        
        XCTAssertEqual(try helper.getIntegerNotationOfAscending(degrees: bluesScale, completeFinalNote: true), [0,3,5,6,7,10,12])
        XCTAssertEqual(try helper.getIntegerNotationOfAscending(degrees: octatonicScale1, completeFinalNote: true), [0,2,3,5,6,8,9,11,12])
        
        XCTAssertEqual(notations, expectedResults)
        
        XCTAssertThrowsError(try helper.getIntegerNotationOfAscending(degrees: "1 ♭3 ♭5 4 5 ♭7"), "") { error in
            print(error)
        }
    }
    
    func test_getPattern() throws {
        
        let bluesScale = "1 ♭3 4 ♭5 5 ♭7"
        let octatonicScale1 = "1 2 ♭3 4 ♭5 ♭6 6 7"
        let octatonicScale2 = "1 ♭2 ♭3 3 ♯4 5 6 ♭7"
        
        let patterns: [[Int]] = [
            try helper.getPattern(degrees: bluesScale),
            try helper.getPattern(degrees: octatonicScale1),
            try helper.getPattern(degrees: octatonicScale2),
        ]
        
        let expectedResults = [
            [3, 2, 1, 1, 3, 2],
            [2, 1, 2, 1, 2, 1, 2, 1],
            [1, 2, 1, 2, 1, 2, 1, 2],
        ]
        
        XCTAssertEqual(patterns, expectedResults)
    }
    
    func test_getCountOfHalfStep() throws {
        
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 1, intervalNum: 4), 1)
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 1, intervalNum: 3), 0)
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 1, intervalNum: 3), 0)
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 7, intervalNum: 5), 2)
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 3, intervalNum: 3), 1)
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 3, intervalNum: 11), 3)
        
        // 4...10 -> (7,8)
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 4, intervalNum: 7), 1)
        
        // 7...10
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 7, intervalNum: 4), 1)
        
        // 3...8 -> (3,4)(7,8)
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 3, intervalNum: 6), 2)
        
        // 10...12
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 10, intervalNum: 3), 1)
        
        
        // 7...18 -> (7,8),(10,11)(14,15)(17,18)
        XCTAssertEqual(helper.getCountOfHalfStep(pairNum: 7, intervalNum: 12), 4)
        
    }
    
    func test_getAboveIntervalNoteFrom() throws {

        let major_3 = Music.Interval(quality: .major, number: 3)
        let major_6 = Music.Interval(quality: .major, number: 6)
        let major_7 = Music.Interval(quality: .major, number: 7)

        let minor_3 = Music.Interval(quality: .minor, number: 3)
        let minor_6 = Music.Interval(quality: .minor, number: 6)
        let minor_7 = Music.Interval(quality: .minor, number: 7)

        let perfect_4 = Music.Interval(quality: .perfect, number: 4)
        let perfect_5 = Music.Interval(quality: .perfect, number: 5)

        let aug_1 = Music.Interval(quality: .augmented, number: 1)
        let aug_2 = Music.Interval(quality: .augmented, number: 2)

        let dim_5 = Music.Interval(quality: .diminished, number: 5)

        let calc = helper.getAboveIntervalNoteFrom
        
        // 2) 장음정
        // 2-1) 장 3도 이하이고, 두 음 사이에 반음이 없다면, prefix는 그대로 따라간다.
        // 예) C# -> E#, Gb -> Bb, G -> B
        try XCTAssertEqual(calc(NoteNumberPair("^", 1), major_3), NoteNumberPair("^", 3))
        try XCTAssertEqual(calc(NoteNumberPair("_", 5), major_3), NoteNumberPair("_", 7))
        try XCTAssertEqual(calc(NoteNumberPair("", 5), major_3), NoteNumberPair("=", 7))

        // 2-2) 장 3도 이하이고, 두 음 사이에 반음이 한 개 있다면 (3-4 또는 7-8), 원래 음에서 반음이 높아진다(=prefix가 1단계 높아진다).
        // 예) E -> G는 E -> G#, Eb -> Gb는 Eb -> G(=)
        try XCTAssertEqual(calc(NoteNumberPair("=", 3), major_3), NoteNumberPair("^", 5))
        try XCTAssertEqual(calc(NoteNumberPair("_", 3), major_3), NoteNumberPair("=", 5))

        // 2-3) 장 6 ~ 7도이고, 두 음 사이에 반음이 한 개 있다면 prefix는 그대로 따라간다.
        // 예) C -> A, Db -> Bb, G# -> E#
        try XCTAssertEqual(calc(NoteNumberPair("", 1), major_6), NoteNumberPair("=", 6))
        try XCTAssertEqual(calc(NoteNumberPair("_", 2), major_6), NoteNumberPair("_", 7))
        try XCTAssertEqual(calc(NoteNumberPair("^", 5), major_6), NoteNumberPair("^", 10))

        // 2-4) 장 6 ~ 7도이고, 두 음 사이에 반음이 두 개 있다면, 원래 음에서 반음이 높아진다(=prefix가 1단계 높아진다).
        // 예) E -> C# (EF, BC), A -> F# (BC, EF), Bb -> G (BC, EF)
        try XCTAssertEqual(calc(NoteNumberPair("", 3), major_7), NoteNumberPair("^", 9))
        try XCTAssertEqual(calc(NoteNumberPair("", 6), major_6), NoteNumberPair("^", 11))
        try XCTAssertEqual(calc(NoteNumberPair("_", 7), major_6), NoteNumberPair("=", 12))
        
        // 3) 단음정
        // 장음정을 기준으로 먼저 계산한 뒤, 반음 내린다(=prefix는 1단계 낮아진다).
        // 예1) C -> Eb (단 3도, from E), Eb -> Gb (단 3도, from G), Gb -> Bbb (from Bb), F# -> A (단 3도, from A#)
        // 예2) E -> C (from C#), Db -> Bbb (from Bb), Bb -> Ab (from A)
        try XCTAssertEqual(calc(NoteNumberPair("", 1), minor_3), NoteNumberPair("_", 3))
        try XCTAssertEqual(calc(NoteNumberPair("_", 3), minor_3), NoteNumberPair("_", 5))
        try XCTAssertEqual(calc(NoteNumberPair("_", 5), minor_3), NoteNumberPair("__", 7))
        try XCTAssertEqual(calc(NoteNumberPair("^", 4), minor_3), NoteNumberPair("=", 6))

        try XCTAssertEqual(calc(NoteNumberPair("", 3), minor_6), NoteNumberPair("=", 8))
        try XCTAssertEqual(calc(NoteNumberPair("_", 2), minor_6), NoteNumberPair("__", 7))
        try XCTAssertEqual(calc(NoteNumberPair("_", 7), minor_7), NoteNumberPair("_", 13))
        
        // 4) 완전음정
        // 4-1) 완전음정 사이에 반음이 한 개 있다면, prefix는 그대로 따라간다.
        // 예) C -> F (EF), Eb -> Ab (EF), Bb -> Eb (BC), E -> B
        try XCTAssertEqual(calc(NoteNumberPair("", 1), perfect_4), NoteNumberPair("=", 4))
        try XCTAssertEqual(calc(NoteNumberPair("_", 3), perfect_4), NoteNumberPair("_", 6))
        try XCTAssertEqual(calc(NoteNumberPair("_", 7), perfect_4), NoteNumberPair("_", 10))
        try XCTAssertEqual(calc(NoteNumberPair("=", 3), perfect_5), NoteNumberPair("=", 7))


        // 4-2) 완전음정 사이에 반음이 하나도 없다면, 원래 음에서 반음이 낮아진다(=prefix는 1단계 낮아진다).
        // 참고) 이 케이스는 F밖에 존재할 수밖에 없다.
        // 예) F -> Bb, F# -> B, Fb -> Fbb
        try XCTAssertEqual(calc(NoteNumberPair("", 4), perfect_4), NoteNumberPair("_", 7))
        try XCTAssertEqual(calc(NoteNumberPair("^", 4), perfect_4), NoteNumberPair("=", 7))
        try XCTAssertEqual(calc(NoteNumberPair("_", 4), perfect_4), NoteNumberPair("__", 7))

        // 5) 증음정
        // 장음정 또는 완전음정을 기준으로 먼저 계산한 뒤, 반음씩 올리면 된다(=prefix가 1단계 높아진다).
        // 예) C -> C# (증 1도, from C), E -> F## (증 2도, from F#)
        try XCTAssertEqual(calc(NoteNumberPair("", 1), aug_1), NoteNumberPair("^", 1))
        try XCTAssertEqual(calc(NoteNumberPair("", 3), aug_2), NoteNumberPair("^^", 4))

        // 6) 감음정
        // 감 5도만 있음 (겹증, 겹감, 감 4도(=장 3도) 제외)
        // 완전 5도에서 반음 내린다(=prefix는 1단계 낮아진다).
        // 예) Eb -> Bbb (from Bb), F# -> C (from C#)
        try XCTAssertEqual(calc(NoteNumberPair("_", 3), dim_5), NoteNumberPair("__", 7))
        try XCTAssertEqual(calc(NoteNumberPair("^", 4), dim_5), NoteNumberPair("=", 8))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
