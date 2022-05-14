//
//  MusicScaleTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2021/12/15.
//

import XCTest
@testable import MusicScale

class MusicScaleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
    }
    
    func test_structToJson() throws {
        
        let scaleInfo1 = ScaleInfo(id: UUID(), name: "asdf", nameAlias: "Das", degreesAscending: "Asd", degreesDescending: "ADs", defaultPriority: 3, comment: "ADs", links: "da", isDivBy12Tet: false)
        let scaleInfo2 = ScaleInfo(id: UUID(), name: "dafdxzc", nameAlias: "zc", degreesAscending: "zz", degreesDescending: "zz", defaultPriority: 3, comment: "z", links: "dfefea", isDivBy12Tet: false)
        
        do {
            let jsonData = try JSONEncoder().encode([scaleInfo1, scaleInfo2])
            let jsonString = String(data: jsonData, encoding: .utf8)!
//            print(jsonString)
            
            XCTAssert(jsonString.contains(scaleInfo1.id.uuidString), "uuid1 not contained.")
            XCTAssert(jsonString.contains(scaleInfo2.id.uuidString), "uuid2 not contained.")
            
            // and decode it back
//            let decodedSentences = try JSONDecoder().decode([Sentence].self, from: jsonData)
//            print(decodedSentences)
        } catch {
            print(error)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
