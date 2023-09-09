//
//  CoreDataTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2022/05/14.
//

import XCTest
@testable import MusicScale
import CoreData

class CoreDataTests: XCTestCase {
    
    let service = ScaleInfoCDService.shared
    var array: [ScaleInfo]!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try service.deleteAllCoreData()
        
        array = (1...100).map { index in
            ScaleInfo(id: UUID(), name: "Scale \(index)", nameAlias: "스케일 \(index)", degreesAscending: "cde \(index)", degreesDescending: "", defaultPriority: 3, comment: "comment \(index): \(Date())", links: "", isDivBy12Tet: true, displayOrder: 3, myPriority: 3, createdDate: Date(), modifiedDate: Date() , groupName: "gg")
        }

        for info in array {
            try service.saveCoreData(scaleInfo: info)
        }
        
    }
    


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_initializeScaleInfoEntity() throws {
        let _ = ScaleInfoEntity()
    }
    
    func test_read() throws {
        
        let entityArray = try service.readCoreData()
        
        XCTAssert(entityArray[25].name == "Scale 26")
        XCTAssert(entityArray[67].nameAlias == "스케일 68")
    }
    
    func test_update() throws {
      
        let entityArray = try service.readCoreData()
        guard var scaleInfoOfFirst = service.toScaleInfoStruct(from: entityArray[0]) else {
            return
        }

        scaleInfoOfFirst.comment = "업데이트됨"
        try service.updateCoreData(entityObject: entityArray[0], scaleInfo: scaleInfoOfFirst)
        
        XCTAssert(try service.readCoreData()[0].comment == "업데이트됨")
        
    }
    
    func test_delete() throws {
        
        var entityArrayBefore = try service.readCoreData()
        
        try service.deleteCoreData(entityObject: entityArrayBefore[0])
        
        var entityArrayAfter = try service.readCoreData()
        
        XCTAssert(entityArrayBefore.count == 100)
        XCTAssert(entityArrayAfter.count == 99)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
