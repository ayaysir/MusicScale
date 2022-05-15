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
        
        // given
        let bluesScale = "1 ♭3 4 ♭5 5 ♭7"
        let octatonicScale1 = "1 2 ♭3 4 ♭5 ♭6 6 7"
        let octatonicScale2 = "1 ♭2 ♭3 3 ♯4 5 6 ♭7"
        
        // when
        let result_bluesScale = MusicSheetHelper.degreesToAbcjsPart(degrees: bluesScale)
        let result_octatonicScale1 = MusicSheetHelper.degreesToAbcjsPart(degrees: octatonicScale1)
        let result_octatonicScale2 = MusicSheetHelper.degreesToAbcjsPart(degrees: octatonicScale2)
        
        // then
        XCTAssertEqual(result_bluesScale, "C _E F _G =G _B c")
        XCTAssertEqual(result_octatonicScale1, "C D _E F _G _A =A B c")
        XCTAssertEqual(result_octatonicScale2, "C _D _E =E ^F G A _B c")
        
        let result = MusicSheetHelper.degreesToAbcjsPart(degrees: "1 2 ♭3 4 5 ♭6 ♭7 1 2 ♭3 4 5 ♭6 (♮)7 1 ♯1 2 ♯2 3 4 ♯4 5 ♯5 6 ♯6 7", completeFinalNote: false)
        XCTAssertEqual(result, "C D _E F G _A _B C D _E F G _A =B C ^C D ^D E F ^F G ^G A ^A B")
    }
    
    func test_degreesToAbcjsLyric() throws {
        
        // given
        let bluesScale = "1 ♭3 4 ♭5 5 ♭7"
        let octatonicScale1 = "1 2 ♭3 4 ♭5 ♭6 6 7"
        let octatonicScale2 = "1 ♭2 ♭3 3 ♯4 5 6 ♭7"
        
        // when
        let result_bluesScale = MusicSheetHelper.degreesToAbcjsLyric(degrees: bluesScale)
        let result_octatonicScale1 = MusicSheetHelper.degreesToAbcjsLyric(degrees: octatonicScale1)
        let result_octatonicScale2 = MusicSheetHelper.degreesToAbcjsLyric(degrees: octatonicScale2)
        
        // then
        XCTAssertEqual(result_bluesScale, "C E♭ F G♭ G♮ B♭ C")
        XCTAssertEqual(result_octatonicScale1, "C D E♭ F G♭ A♭ A♮ B C")
        XCTAssertEqual(result_octatonicScale2, "C D♭ E♭ E♮ F♯ G A B♭ C")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
