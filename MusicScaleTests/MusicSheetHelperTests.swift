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
            [("", 5), ("", 4)],
            [("^", 1), ("", 1)],
            [("", 3), ("_", 3)],
            [("_", 3), ("", -1)],
            [("_", 7), ("_", 4)],
//            [("_", 7), ("_", 7)],
        ]
        
        for lhPair in leftRightPairsArrayForError {
            XCTAssertThrowsError(try helper.getIntervalOfAscendingTwoNumPair(leftPair: lhPair[0], rightPair: lhPair[1]))
        }
        
        // MARK: - Check correct result?
        let leftRightPairsArray: [[NoteNumberPair]] = [
            [("", 4), ("", 4)],
            [("", 1), ("", 2)],
            [("", 2), ("_", 3)],
            [("_", 3), ("", 4)],
            [("_", 6), ("_", 7)],
            [("", 3), ("^", 4)],
            [("", 1), ("", 3)],
            [("", 5), ("", 7)],
            [("", 3), ("", 5)],
            [("_", 3), ("=", 3)],
            [("_", 6), ("=", 7)],
            [("^", 4), ("^", 4)],
        ]
        
        var intervals: [Int] = []
        for lrPairs in leftRightPairsArray {
            let interval = try helper.getIntervalOfAscendingTwoNumPair(leftPair: lrPairs[0], rightPair: lrPairs[1])
            intervals.append(interval)
        }
        
        let expectedResults = [0, 2, 1, 2, 2, 2, 4, 4, 3, 1, 3, 0]
        for i in (0...expectedResults.count - 1) {
            XCTAssertEqual(intervals[i], expectedResults[i])
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
            [3, 2, 1, 1, 3],
            [2, 1, 2, 1, 2, 1, 2],
            [1, 2, 1, 2, 1, 2, 1],
        ]
        
        XCTAssertEqual(patterns, expectedResults)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
