//
//  PianoKeyHelperTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2022/05/14.
//

import XCTest
@testable import MusicScale

class PianoKeyHelperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_adjustKeySemitone() throws {
        
        /*
         +7 -12 -14 +2
         +6 -11 -12 +1
         +5 -9 -10 +1
         +4 -7 -8 +1
         +3 -6 -6 0
         +2 -4 -4 0
         +1 -2 -2 0
         0 0 0 0
         -1 +1 2 -1
         -2 +3 4 -1
         -3 +5 6 -1
         -4 +6 8 -2
         -5 +8 10 -2
         -6 +10 12 -2
         -7 +12 14 -2
         
         (-2)를 곱한 후, 조정
         조정: abs(7)을 제외하고(=>반대부호 12) adjustPostion에서 (-1)을 더하고 -7까지 반음이 몇개인지를 센 뒤 (-3)을 더한다.
         */
        
        // given
        let adjustedPositions = [7, 6, 5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7]
        
        // when
        let resultArray: [Int] = adjustedPositions.map {  PianoKeyHelper.adjustKeySemitone(adjustPostion: $0) }
        
        // then
        let expectedResults = [-12, -11, -9, -7, -6, -4, -2, 0, 1, 3, 5, 6, 8, 10, 12]
        for i in 0...(expectedResults.count - 1) {
            let msg = "\(adjustedPositions[i]), \(resultArray[i]), \(expectedResults[i])"
            XCTAssert(resultArray[i] == expectedResults[i], msg)
        }
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
