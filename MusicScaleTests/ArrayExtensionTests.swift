//
//  ArrayExtensionTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2022/06/05.
//

import XCTest
@testable import MusicScale

class ArrayExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_makeShuffledArray() throws {
        
        let array1 = Array(repeating: Int.random(in: 0...9999), count: 4)
        let array2 = Array(repeating: Int.random(in: 0...9999), count: 164)
        
        let result1 = try array1.makeShuffledArray(totalCount: 3000)
        let result2 = try array1.makeShuffledArray(totalCount: 274)
        let result3 = try array2.makeShuffledArray(totalCount: 177)
        
        XCTAssertEqual(result1.count, 3000)
        XCTAssertEqual(result2.count, 274)
        XCTAssertEqual(result3.count, 177)
        
        XCTAssertThrowsError(try array1.makeShuffledArray(totalCount: 4)) { error in
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
