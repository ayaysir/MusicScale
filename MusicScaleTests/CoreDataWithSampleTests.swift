//
//  CoreDataWithSampleTests.swift
//  MusicScaleTests
//
//  Created by yoonbumtae on 2022/05/15.
//

import XCTest
@testable import MusicScale
import CoreData

class CoreDataWithSampleTests: XCTestCase {
    
    let service = ScaleInfoCDService.shared
    var entityList: [ScaleInfoEntity] = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try service.deleteAllCoreData()
        putSampleData()
    }
    
    func putSampleData() {
        
        getSampleScaleDataFromLocal { infoList in
            for info in infoList {
                try self.service.saveCoreData(scaleInfo: info)
            }
        }
    }
    
    func reloadData() throws {
        entityList = try service.readCoreData()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_read() throws {
        entityList = try service.readCoreData()
        service.printScaleInfoEntity(array: entityList)
        let aeolian = entityList.first { entity in
            if let name = entity.name {
                return name.contains("Aeolian")
            }
            return false
        }
        XCTAssertNotNil(aeolian)
        XCTAssertNotNil(aeolian!.name)
        XCTAssert(aeolian!.name!.contains("Aeolian"))
    }
    
    func test_update() throws {
        
//        try test_read()
        
        try reloadData()
        
        let aeolianBefore = entityList.first { entity in
            if let name = entity.name {
                return name.contains("Aeolian")
            }
            return false
        }
        
        XCTAssertNotNil(aeolianBefore)
        
        var aeolianStruct = service.toScaleInfoStruct(from: aeolianBefore!)
        aeolianStruct?.comment = "updated from tests."
        try service.updateCoreData(entityObject: aeolianBefore!, scaleInfo: aeolianStruct!)

        try reloadData()
        let aeolianAfter = entityList.first { entity in
            if let name = entity.name {
                return name.contains("Aeolian")
            }
            return false
        }
        XCTAssertNotNil(aeolianAfter)
        XCTAssertNotNil(aeolianAfter!.comment)
        XCTAssertEqual(aeolianAfter!.comment, "updated from tests.")
    }
    
    func test_delete() throws {
        
        let infoToDelete = ScaleInfo(id: UUID(), name: "delete", nameAlias: "delete", degreesAscending: "delete", degreesDescending: "delete", defaultPriority: 1, comment: "delete", links: "delete", isDivBy12Tet: false, displayOrder: 0, myPriority: 0, createdDate: Date(), modifiedDate: Date() , groupName: "gg")
        try service.saveCoreData(scaleInfo: infoToDelete)
        
        try reloadData()
        
        let entityToDelete = entityList.first { entity in
            if let name = entity.name {
                return name.contains("delete")
            }
            return false
        }
        
        XCTAssertNotNil(entityToDelete)
        XCTAssertEqual(entityToDelete!.name, "delete")
        
        try service.deleteCoreData(entityObject: entityToDelete!)
        
        let deletedEntity = entityList.first { entity in
            if let name = entity.name {
                return name.contains("delete")
            }
            return false
        }
        XCTAssertNil(deletedEntity)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
