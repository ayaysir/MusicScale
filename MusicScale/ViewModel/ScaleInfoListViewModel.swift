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
            totalEntityData = try service.readCoreData()
            handleDataReloaded()
        } catch {
            print(error)
        }
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
    
    /// entity로 delete
    func deleteScaleInfo(entity: ScaleInfoEntity) {
        do {
            try service.deleteCoreData(entityObject: entity)
            
            if let index = totalEntityData.firstIndex(of: entity) {
                totalEntityData.remove(at: index)
                print("endItemOnlyt", #function)
                return
            }
            
        } catch {
            print(error)
        }
    }
}
