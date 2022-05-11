//
//  NoteTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2022/05/12.
//

import XCTest
@testable import MusicScale

class NoteTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_semitone() throws {
        // given
        let musicNote_F = Note(scale7: .F, pitchShift: .natural)
        let musicNote_C_Sharp = Note(scale7: .C, pitchShift: .sharp)
        let musicNote_B_Flat = Note(scale7: .B, pitchShift: .flat)
        let musicNote_G_DoubleFlat = Note(scale7: .G, pitchShift: .doubleFlat)
        let musicNote_A_DoubleSharp = Note(scale7: .A, pitchShift: .doubleSharp)
        
        // when
        let semitone_F = musicNote_F.semitone
        let semitone_C_Sharp = musicNote_C_Sharp.semitone
        let semitone_B_Flat = musicNote_B_Flat.semitone
        let semitone_G_DoubleFlat = musicNote_G_DoubleFlat.semitone
        let semitone_A_DoubleSharp = musicNote_A_DoubleSharp.semitone
        
        // then
        // C, C#, D, D#, E, F
        XCTAssertEqual(semitone_F, 5)
        XCTAssertEqual(semitone_C_Sharp, 1)
        XCTAssertEqual(semitone_B_Flat, 10)
        XCTAssertEqual(semitone_G_DoubleFlat, semitone_F) // = 5?
        XCTAssertEqual(semitone_A_DoubleSharp, 11)
    }
    
    func test_noteComparable() throws {
        // given
        let musicNote_F = Note(scale7: .F, pitchShift: .natural)
        let musicNote_F_Sharp = Note(scale7: .F, pitchShift: .sharp)
        let musicNote_B_Flat = Note(scale7: .B, pitchShift: .flat)
        let musicNote_B_DoubleFlat = Note(scale7: .B, pitchShift: .doubleFlat)
        let musicNote_A_DoubleSharp = Note(scale7: .A, pitchShift: .doubleSharp)
        let musicNote_B = Note(scale7: .B, pitchShift: .natural)
        
        // when
        let cond1_1 = musicNote_F == musicNote_F_Sharp
        let cond1_2 = musicNote_F > musicNote_F_Sharp
        let cond1_3 = musicNote_F < musicNote_F_Sharp
        
        let cond2_1 = musicNote_B_Flat == musicNote_B_DoubleFlat
        let cond2_2 = musicNote_B_Flat > musicNote_B_DoubleFlat
        let cond2_3 = musicNote_B_Flat < musicNote_B_DoubleFlat
        
        let cond3_1 = musicNote_A_DoubleSharp == musicNote_B
        let cond3_2 = musicNote_A_DoubleSharp > musicNote_B
        let cond3_3 = musicNote_A_DoubleSharp < musicNote_B
        
        // then
        XCTAssert(!cond1_1)
        XCTAssert(!cond1_2)
        XCTAssert(cond1_3)
        
        XCTAssert(!cond2_1)
        XCTAssert(cond2_2)
        XCTAssert(!cond2_3)
        
        XCTAssert(!cond3_1)
        XCTAssert(!cond3_2)
        XCTAssert(cond3_3)
        
        XCTAssert(musicNote_B == Note(scale7: .B))
        
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
