//
//  QuizStatsCDService.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/20.
//

import UIKit
import CoreData

struct QuizStatsCDService {

    private let ENTITY_NAME = "QuizStatEntity"
    static let shared = QuizStatsCDService()

    private var managedContext: NSManagedObjectContext? {
        // App Delegate 호출
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }

        // App Delegate 내부에 있는 viewContext 호출
        return appDelegate.persistentContainer.viewContext
    }

    private func createQuizStatEntity() throws -> QuizStatEntity {

        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }

        // managedContext 내부에 있는 entity 호출
        let entity = NSEntityDescription.entity(forEntityName: ENTITY_NAME, in: managedContext)!
        
        // entity 객체 생성
        return QuizStatEntity(entity: entity, insertInto: managedContext)
    }
    
    func createQuizStatEntity(scaleName: String,
                              key: String,
                              order: String,
                              typeOfQuestion: String,
                              isAnsweredCorrectly: Bool,
                              solveDate: Date,
                              elapsedSeconds: Int16,
                              studyStatus: String) throws -> QuizStatEntity {
        
        let entity = try createQuizStatEntity()
        
        entity.scaleName = scaleName
        entity.key = key
        entity.order = order
        entity.typeOfQuestion = typeOfQuestion
        entity.isAnsweredCorrectly = isAnsweredCorrectly
        entity.solveDate = solveDate
        entity.elapsedSeconds = elapsedSeconds
        entity.studyStatus = studyStatus
        
        try saveManagedContext()
        return entity
    }
    
    func readEntityList(sortDescriptors: [NSSortDescriptor] = []) throws -> [QuizStatEntity] {
        
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        // Entity의 fetchRequest 생성
        let fetchRequest = NSFetchRequest<QuizStatEntity>(entityName: ENTITY_NAME)
        
        // 정렬 또는 조건 설정
        fetchRequest.sortDescriptors = sortDescriptors
        // fetchRequest.predicate = NSPredicate(format: "isFinished = %@", NSNumber(value: isFinished))
        
        // fetchRequest를 통해 managedContext로부터 결과 배열을 가져오기
        return try managedContext.fetch(fetchRequest)
    }
    
    func deleteQuizStatEntity(entityObject object: QuizStatEntity) throws {
        
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        // 객체를 넘기고 바로 삭제
        managedContext.delete(object)
        
        try saveManagedContext()
    }
    
    func saveManagedContext() throws {
        guard let managedContext = managedContext else {
            throw CDError.appDelegateNotExist
        }
        
        try managedContext.save()
    }
    
    func toQuizStat(from entity: QuizStatEntity) -> QuizStat? {
        guard let scaleName = entity.scaleName,
              let key = entity.key,
              let order = entity.order,
              let typeOfQuestion = entity.typeOfQuestion,
              let solveDate = entity.solveDate,
              let studyStatus = entity.studyStatus else {
            return nil
        }
        
        return QuizStat(scaleName: scaleName,
                        key: key,
                        order: order,
                        typeOfQuestion: typeOfQuestion,
                        isAnsweredCorrectly: entity.isAnsweredCorrectly,
                        solveDate: solveDate,
                        elapsedSeconds: entity.elapsedSeconds,
                        studyStatus: studyStatus)
    }
    
    func getQuizStats() throws -> [QuizStat] {
        return try readEntityList().compactMap { toQuizStat(from: $0) }
    }
}

extension QuizStatEntity {
    public override var description: String {
        let resultArray: [Any] = [
            self.scaleName ?? "",
            self.key ?? "",
            self.order ?? "",
            self.typeOfQuestion ?? "",
            self.isAnsweredCorrectly,
            self.solveDate ?? "",
            self.elapsedSeconds,
            self.studyStatus ?? "",
        ]
        
        return "\(resultArray)"
    }
}
