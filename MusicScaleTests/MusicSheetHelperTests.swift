//
//  MusicSheetHelperTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2022/05/15.
//

import XCTest
@testable import MusicScale

class MusicSheetHelperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_degreesToAbcjsPart() throws {
        
        let result = MusicSheetHelper.degreesToAbcjsPart(degrees: "1 2 ♭3 4 5 ♭6 ♭7 1 2 ♭3 4 5 ♭6 (♮)7 1 ♯1 2 ♯2 3 4 ♯4 5 ♯5 6 ♯6 7")
        XCTAssertEqual(result, "C D _E F G _A _B C D _E F G _A =B C ^C D ^D E F ^F G ^G A ^A B")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
