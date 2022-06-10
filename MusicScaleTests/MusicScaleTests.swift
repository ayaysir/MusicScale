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
        
        // let key = ["C", "D", "E", "F", "G", "A", "B"]
        // let aeolianDegrees = "1 2 ♭3 4 5 ♭6 ♭7 1 2 ♭3 4 5 ♭6 (♮)7 1 ♯1 2 ♯2 3 4 ♯4 5 ♯5 6 ♯6 7"
        // let array = aeolianDegrees.components(separatedBy: " ")
        //
        // for str in array {
        //     let onlyNumber = str.range(of: "^[1234567]$", options: .regularExpression)
        //     let hasPrefix = str.range(of: "^[♭b#♯♮=][1234567]$", options: .regularExpression)
        //     let hasBracketedPrefix = str.range(of: "^\\([♭b#♯♮=]\\)[1234567]$", options: .regularExpression)
        //
        //     if onlyNumber != nil {
        //         let noteStr = key[Int(str)! - 1]
        //         print(str, "onlyNumber", noteStr)
        //     } else if hasPrefix != nil {
        //         var noteStr = ""
        //         switch str[0] {
        //         case "♭", "b":
        //             noteStr = "_"
        //         case "♯", "#":
        //             noteStr = "^"
        //         case "♮", "=":
        //             noteStr = "="
        //         default:
        //             break
        //         }
        //         noteStr += key[Int(str[1])! - 1]
        //         print(str, "hasPrefix", noteStr)
        //     } else if hasBracketedPrefix != nil {
        //         let removedBracketStr = str.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        //         var noteStr = ""
        //         switch removedBracketStr[0] {
        //         case "♭", "b":
        //             noteStr = "_"
        //         case "♯", "#":
        //             noteStr = "^"
        //         case "♮", "=":
        //             noteStr = "="
        //         default:
        //             break
        //         }
        //         noteStr += key[Int(removedBracketStr[1])! - 1]
        //         print(str, "hasBracketedPrefix", noteStr, removedBracketStr)
        //     }
        // }
        
        QuizConfigStore.shared.savedLeitnerSystem = nil
    }
    
    func test_structToJson() throws {
        
        let scaleInfo1 = ScaleInfo(id: UUID(), name: "asdf", nameAlias: "Das", degreesAscending: "Asd", degreesDescending: "ADs", defaultPriority: 3, comment: "ADs", links: "da", isDivBy12Tet: false, displayOrder: 3, myPriority: 3, createdDate: Date(), modifiedDate: Date() , groupName: "gg")
        let scaleInfo2 = ScaleInfo(id: UUID(), name: "dafdxzc", nameAlias: "zc", degreesAscending: "zz", degreesDescending: "zz", defaultPriority: 3, comment: "z", links: "dfefea", isDivBy12Tet: false, displayOrder: 3, myPriority: 3, createdDate: Date(), modifiedDate: Date() , groupName: "gg")
        
        do {
            let jsonData = try JSONEncoder().encode([scaleInfo1, scaleInfo2])
            let jsonString = String(data: jsonData, encoding: .utf8)!
            // print(jsonString)
            
            XCTAssert(jsonString.contains(scaleInfo1.id.uuidString), "uuid1 not contained.")
            XCTAssert(jsonString.contains(scaleInfo2.id.uuidString), "uuid2 not contained.")
            
            // and decode it back
            // let decodedSentences = try JSONDecoder().decode([Sentence].self, from: jsonData)
            // print(decodedSentences)
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
