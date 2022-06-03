//
//  QuizViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/03.
//

import Foundation

class QuizViewModel {
    
    private var store = QuizConfigStore.shared
    
    private(set) var scaleIdList: Set<UUID> = []
    var idListCount: Int {
        return scaleIdList.count
    }
    
    init() {
        loadScaleListFromConfigStore()
    }
    
    func appendIdToScaleList(_ uuid: UUID) {
        scaleIdList.insert(uuid)
    }
    
    func setScaleList(_ idList: [UUID]) {
        scaleIdList = Set(idList)
    }
    
    func containsId(_ uuid: UUID) -> Bool {
        return scaleIdList.contains(uuid)
    }
    
    func removeId(_ uuid: UUID) {
        scaleIdList.remove(uuid)
    }
    
    func saveScaleListToConfigStore() {
        store.selectedScaleInfoId = scaleIdList
    }
    
    func loadScaleListFromConfigStore() {
        scaleIdList = store.selectedScaleInfoId
    }
    
    // func getScaleInfoFromCoreData(id: UUID) {
    //     ScaleInfoCDService
    // }
}
