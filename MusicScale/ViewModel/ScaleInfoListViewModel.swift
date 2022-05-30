//
//  ScaleInfoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import Foundation

class ScaleInfoListViewModel {
    
    private let service = ScaleInfoCDService.shared
    
    // 모든 관리는 배열의 index로
    private var totalEntityData: [ScaleInfoEntity]!
    var infoCount: Int {
        return totalEntityData.count
    }
    
    var handleDataReloaded: () -> () = {}
    
    init() {
        fetchCoreData()
    }
    
    private func fetchCoreData() {
        // 이 작업이 실행될떄마다 뷰도 새로고침한다.
        do {
            
            let sort = NSSortDescriptor(key: "displayOrder", ascending: true)
            totalEntityData = try service.readCoreData(sortDescriptors: [sort])
            handleDataReloaded()
        } catch {
            print(error)
        }
    }
    
    // 정렬
    func compareTwo<T: Comparable>(by order: SortOrder, left: T, right: T) -> Bool {
        
        guard order == .ascending || order == .descending else {
            return false
        }
        
        if order == .ascending {
            return left < right
        } else {
            return left > right
        }
    }
    
    func orderByUserSequence() {
        totalEntityData.sort { leftEntity, rightEntity in
            leftEntity.displayOrder < rightEntity.displayOrder
        }
        SortFilterConfigStore.shared.currentState = .displayOrder
        SortFilterConfigStore.shared.curentOrder = .none
        handleDataReloaded()
    }
    
    func orderByNameDisplayOrder(order: SortOrder) {
        totalEntityData.sort { leftEntity, rightEntity in
            compareTwo(by: order, left: leftEntity.name!, right: rightEntity.name!)
        }
        SortFilterConfigStore.shared.currentState = .name
        SortFilterConfigStore.shared.curentOrder = order
        handleDataReloaded()
    }
    
    func orderByMyPriority(order: SortOrder) {
        totalEntityData.sort { leftEntity, rightEntity in
            return compareTwo(by: order, left: leftEntity.myPriority, right: rightEntity.myPriority)
        }
        SortFilterConfigStore.shared.currentState = .priority
        SortFilterConfigStore.shared.curentOrder = order
        handleDataReloaded()
    }
    
    func addScaleInfo(info: ScaleInfo) {
        do {
            _ = try service.saveCoreData(scaleInfo: info)
            fetchCoreData()
        } catch {
            print(error)
        }
    }
    
    /// 받아온 entity를 totalEntityDatadp 추가하고 테이블뷰 reload (코어 데이타 전체를 다시 불러오지는 않는다.)
    func addCreatedInfoToList(entity: ScaleInfoEntity) {
        totalEntityData.insert(entity, at: 0)
        handleDataReloaded()
    }
    
    private var infoViewModels: [ScaleInfoViewModel?] {
        
        return totalEntityData.map { (entity: ScaleInfoEntity) -> ScaleInfoViewModel? in
            guard let scaleInfo = service.toScaleInfoStruct(from: entity) else {
                return nil
            }
            return ScaleInfoViewModel(scaleInfo: scaleInfo, currentKey: .C, currentTempo: 100, entity: entity)
        }
    }
    
    func getScaleInfoViewModelOf(index: Int) -> ScaleInfoViewModel? {
        return infoViewModels[index]
    }
    
    func updateScaleInfo(index: Int, info: ScaleInfo) {
        do {
            try service.updateCoreData(entityObject: totalEntityData[index], scaleInfo: info)
        } catch {
            print(error)
        }
    }
    
    func deleteScaleInfo(index: Int) {
        do {
            try service.deleteCoreData(entityObject: totalEntityData[index])
            fetchCoreData()
        } catch {
            print(error)
        }
    }
    
    /// entity로 delete (readCoreData는 하지 않음)
    func deleteScaleInfo(entity: ScaleInfoEntity) {
        do {
            try service.deleteCoreData(entityObject: entity)
            
            if let index = totalEntityData.firstIndex(of: entity) {
                totalEntityData.remove(at: index)
                
                return
            }
            
        } catch {
            print(error)
        }
    }
}
