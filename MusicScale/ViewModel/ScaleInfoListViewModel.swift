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
    
    func addCreatedInfoToList(entity: ScaleInfoEntity) {
        // let viewModel = ScaleInfoViewModel(scaleInfo: info, currentKey: .C, currentTempo: 100, entity: entity)
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
    
}
