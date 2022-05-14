//
//  ScaleInfoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import Foundation

class ScaleInfoViewModel {
    
    private let service = ScaleInfoCDService.shared
    
    // 모든 관리는 배열의 index로
    private var totalEntityData: [ScaleInfoEntity]!
    
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
            try service.saveCoreData(scaleInfo: info)
            fetchCoreData()
        } catch {
            print(error)
        }
    }
    
    func getScaleInfoBy(index: Int) -> ScaleInfo? {
        return service.toScaleInfoStruct(from: totalEntityData[index])
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
