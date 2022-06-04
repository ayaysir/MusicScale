//
//  QuizTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2022/06/04.
//

import XCTest
@testable import MusicScale

class QuizTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_makeList() throws {
        let helper = QuizHelper()
        // let config = QuizConfigStore.shared.quizConfigChunk
        
        let uuidStrings: [String] = [
            "A9B4059B-9CE3-4045-B1DF-D2264ACEBB82", "92E522C3-A86C-4F91-935F-16FC2515436D", "467343D0-3E7A-4314-BAF3-926119A9ED6F", "A68D93D8-8C48-4524-A599-F7DF405D76EA", "3D910538-4AB8-44A8-801D-DED907850EED", "23AD067B-DCBC-4AF2-ACA7-3F9A04090DBB", "D3D8A614-57A0-41E7-A746-8A70674AE5F2", "BBAFD722-9BA5-4257-8985-7B34C38D3864", "47AD903B-2521-4756-B85B-3EAB9AE5B01D", "F0DCC6A7-C485-4C25-8FDF-707E4387EC45", "702C6E36-8388-4748-BDDD-8A417C7A43B2", "403E8B7E-450F-4414-A9D1-E554AEEB18E1",
        ]
        let uuidSet = Set(uuidStrings.compactMap { UUID(uuidString: $0) })
        let config = QuizConfig(
            availableKeys: Set([MusicScale.Music.Key.D_sharp,
                                MusicScale.Music.Key.E,
                                MusicScale.Music.Key.G,
                                // MusicScale.Music.Key.A_flat,
                                // MusicScale.Music.Key.F,
                                // MusicScale.Music.Key.C_sharp,
                                MusicScale.Music.Key.D,
                                MusicScale.Music.Key.C]),
            ascSelected: true,
            descSelected: true,
            selectedScaleInfoId: uuidSet,
            numberOfQuestions: 50,
            typeOfQuestions: MusicScale.QuizType.guessName,
            enharmonicMode: MusicScale.EnharmonicMode.userCustom
        )
        
        getSampleScaleDataFromLocal { infos in
            let result = helper.makeQuestionList(chunk: config, infoList: infos)
            
            // 5 * 12 * 2 = 120
            XCTAssertEqual(result.count, 120)
            
            result.forEach { question in
                print(question.scaleInfo.name, question.isAscending ? "asc" : "desc", question.key)
            }
        }
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
