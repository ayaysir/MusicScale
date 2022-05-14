//
//  CoreDataService.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/14.
//

import UIKit
import CoreData

enum CDError: Error {
    case appDelegateNotExist
}

struct ScaleInfoCDService {
    
    static let shared = ScaleInfoCDService()
    
    private let ENTITY_NAME = "ScaleInfoEntity"
    
    private var managedContext: NSManagedObjectContext? {
        // App Delegate 호출
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        // App Delegate 내부에 있는 viewContext 호출
        return appDelegate.persistentContainer.viewContext
    }
    
    func saveCoreData(scaleInfo info: ScaleInfo) throws{
        
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        // managedContext 내부에 있는 entity 호출
        let entity = NSEntityDescription.entity(forEntityName: ENTITY_NAME, in: managedContext)!
        
        // entity 객체 생성
        let entityObject = ScaleInfoEntity(entity: entity, insertInto: managedContext)
        
        // 값 설정
        entityObject.comment = info.comment
        entityObject.defaultPriority = Int16(info.defaultPriority)
        entityObject.degreesAscending = info.degreesAscending
        entityObject.degreesDescending = info.degreesDescending
        entityObject.id = info.id
        entityObject.isDivBy12Tet = info.isDivBy12Tet
        entityObject.links = info.links
        entityObject.nameAlias = info.nameAlias
        entityObject.name = info.name
        
        do {
            // managedContext 내부의 변경사항 저장
            try managedContext.save()
        } catch let error as NSError {
            // 에러 발생시
            throw error
        }
    }
    
    func readCoreData() throws -> [ScaleInfoEntity] {
        
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        // Entity의 fetchRequest 생성
        let fetchRequest = NSFetchRequest<ScaleInfoEntity>(entityName: ENTITY_NAME)
        
        // 정렬 또는 조건 설정
//        let sort = NSSortDescriptor(key: "date", ascending: false)
//        fetchRequest.sortDescriptors = [sort]
//        fetchRequest.predicate = NSPredicate(format: "isFinished = %@", NSNumber(value: isFinished))
        
        do {
            // fetchRequest를 통해 managedContext로부터 결과 배열을 가져오기
            return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            throw error
        }
    }
    
    func deleteCoreData(entityObject object: ScaleInfoEntity) throws {
        
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        // 객체를 넘기고 바로 삭제
        managedContext.delete(object)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            throw error
        }
    }
    
    func updateCoreData(entityObject: ScaleInfoEntity, scaleInfo info: ScaleInfo) throws {
        
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        entityObject.comment = info.comment
        entityObject.defaultPriority = Int16(info.defaultPriority)
        entityObject.degreesAscending = info.degreesAscending
        entityObject.degreesDescending = info.degreesDescending
//            entityObject.id = info.id
        entityObject.isDivBy12Tet = info.isDivBy12Tet
        entityObject.links = info.links
        entityObject.nameAlias = info.nameAlias
        entityObject.name = info.name
    
        do {
            try managedContext.save()
        } catch let error as NSError {
            throw error
        }
    }
    
    func saveManagedContext() throws {
        
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            throw error
        }
    }
    
    /// 데이터 전체 삭제: 테스트 목적으로만 사용
    func deleteAllCoreData() throws {
        
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: ENTITY_NAME)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedContext.persistentStoreCoordinator?.execute(deleteRequest, with: managedContext)
        } catch {
            throw error
        }
    }
    
    func toScaleInfoStruct(from entity: ScaleInfoEntity) -> ScaleInfo? {
        
        let defaultPriority = Int(entity.defaultPriority)
        let isDivBy12Tet = entity.isDivBy12Tet
        
        guard let comment = entity.comment,
              let degreesAscending = entity.degreesAscending,
              let degreesDescending = entity.degreesDescending,
              let id = entity.id,
              let links = entity.links,
              let nameAlias = entity.nameAlias,
              let name = entity.name else {
            return nil
        }
        
        return ScaleInfo(id: id, name: name, nameAlias: nameAlias, degreesAscending: degreesAscending, degreesDescending: degreesDescending, defaultPriority: defaultPriority, comment: comment, links: links, isDivBy12Tet: isDivBy12Tet)
    }
    
    func printScaleInfoEntity(array: [ScaleInfoEntity]) {
        
        let result = array.reduce(into: "") { partialResult, entity in
            if let scaleInfo = toScaleInfoStruct(from: entity) {
                partialResult += "\(scaleInfo)\n"
            }
        }
        
        print(result)
    }
}


