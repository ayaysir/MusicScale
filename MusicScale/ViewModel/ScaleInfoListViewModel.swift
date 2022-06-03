//
//  ScaleInfoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import Foundation

class ScaleInfoListViewModel {
    
    private let service = ScaleInfoCDService.shared
    private let sortStore = SortFilterConfigStore.shared
    
    // 모든 관리는 배열의 index로
    private var totalEntityData: [ScaleInfoEntity]!
    var infoCount: Int {
        return totalEntityData.count
    }
    
    // 검색용
    private var searchEntityData: [ScaleInfoEntity]!
    var searchInfoCount: Int {
        return searchEntityData.count
    }
    
    func getInfoCount(isFiltering: Bool) -> Int {
        return isFiltering ? searchInfoCount : infoCount
    }
    
    var handleDataReloaded: () -> () = {}
    
    init() {
        fetchCoreData()
    }
    
    private func fetchCoreData() {
        // 이 작업이 실행될떄마다 뷰도 새로고침한다.
        do {
            let isAscending = sortStore.curentOrder == .ascending || sortStore.curentOrder == .none
            let key: String = {
                switch sortStore.currentState {
                case .none, .displayOrder:
                    return "displayOrder"
                case .name:
                    return "name"
                case .priority:
                    return "defaultPriority"
                }
            }()
            
            let sort = NSSortDescriptor(key: key, ascending: isAscending)
            totalEntityData = try service.readCoreData(sortDescriptors: [sort])
            
            if sortStore.currentState == .priority {
                orderByDisplayedPriority(order: sortStore.curentOrder)
            }
            
            handleDataReloaded()
        } catch {
            print(error)
        }
    }
    
    // 검색
    func search(searchText: String, searchCategory: SearchCategory) {
        let searchText = searchText.lowercased()
        
        searchEntityData = totalEntityData.filter { entity in
            var results: [Bool] = []
            let alwaysAll = searchCategory == .all
            
            if alwaysAll || searchCategory == .name {
                results.append(entity.name?.lowercased().contains(searchText) ?? false)
            }
            
            if alwaysAll || searchCategory == .comment {
                results.append(entity.comment?.lowercased().contains(searchText) ?? false)
            }
            
            if alwaysAll || searchCategory == .degrees {
                results.append(entity.degreesAscending?.lowercased().contains(searchText) ?? false)
                results.append(entity.degreesDescending?.lowercased().contains(searchText) ?? false)
            }
            
            return results.reduce(false) { $0 || $1 }
        }
        
        handleDataReloaded()
    }
    
    func resetSearch() {
        searchEntityData = []
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
    
    func orderByDisplayedPriority(order: SortOrder) {
        totalEntityData.sort { leftEntity, rightEntity in
            let leftTargetPriority = leftEntity.myPriority > 0 ? leftEntity.myPriority : leftEntity.defaultPriority
            let rightTargetPriority = rightEntity.myPriority > 0 ? rightEntity.myPriority : rightEntity.defaultPriority
            return compareTwo(by: order, left: leftTargetPriority, right: rightTargetPriority)
        }
        SortFilterConfigStore.shared.currentState = .priority
        SortFilterConfigStore.shared.curentOrder = order
        handleDataReloaded()
    }
    
    // func addScaleInfo(info: ScaleInfo) {
    //     do {
    //         _ = try service.saveCoreData(scaleInfo: info)
    //         fetchCoreData()
    //     } catch {
    //         print(error)
    //     }
    // }
    
    /// 받아온 entity를 totalEntityDatadp 추가하고 테이블뷰 reload (코어 데이타 전체를 다시 불러오지는 않는다.)
    func addCreatedInfoToList(entity: ScaleInfoEntity) {
        totalEntityData.insert(entity, at: 0)
        handleDataReloaded()
    }
    
    /// 뷰모델 만들기
    private var infoViewModels: [ScaleInfoViewModel?] {
        return totalEntityData.map { (entity: ScaleInfoEntity) -> ScaleInfoViewModel? in
            guard let scaleInfo = service.toScaleInfoStruct(from: entity) else {
                return nil
            }
            return ScaleInfoViewModel(scaleInfo: scaleInfo, currentKey: .C, currentTempo: 100, entity: entity)
        }
    }
    
    /// 뷰모델 만들기 (검색용)
    private var searchedInfoViewModel: [ScaleInfoViewModel?] {
        return searchEntityData.map { (entity: ScaleInfoEntity) -> ScaleInfoViewModel? in
            guard let scaleInfo = service.toScaleInfoStruct(from: entity) else {
                return nil
            }
            return ScaleInfoViewModel(scaleInfo: scaleInfo, currentKey: .C, currentTempo: 100, entity: entity)
        }
    }
    
    func getScaleInfoViewModelOf(index: Int) -> ScaleInfoViewModel? {
        return infoViewModels[index]
    }
    
    func getSearchedInfoViewModelOf(index: Int) -> ScaleInfoViewModel? {
        return searchedInfoViewModel[index]
    }
    
    func getScaleInfoVM(isFiltering: Bool, index: Int) -> ScaleInfoViewModel? {
        return isFiltering ? getSearchedInfoViewModelOf(index: index) : getScaleInfoViewModelOf(index: index)
    }
    
    func updateScaleInfo(index: Int, info: ScaleInfo) {
        do {
            try service.updateCoreData(entityObject: totalEntityData[index], scaleInfo: info)
        } catch {
            print(error)
        }
    }
    
    // func deleteScaleInfo(index: Int) {
    //     do {
    //         try service.deleteCoreData(entityObject: totalEntityData[index])
    //         fetchCoreData()
    //     } catch {
    //         print(error)
    //     }
    // }
    
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
    
    func changeOrder(from fromEntity: ScaleInfoEntity, toIndex: IndexPath) {
        guard let fromEntityIndex = totalEntityData.firstIndex(of: fromEntity) else {
            return
        }
        
        if totalEntityData[fromEntityIndex] == fromEntity {
            totalEntityData.remove(at: fromEntityIndex)
            totalEntityData.insert(fromEntity, at: toIndex.row)
            
            // totalEntityData.enumerated().forEach { (index, entity) in
            //     entity.displayOrder = Int16(index)
            // }
            
            // 절반 기준으로 오른쪽에 있으면 오른쪽 이후 순서를 바꾸고, 반대의 경우 왼쪽 이전의 순서를 바꾼다.
            
            let mid = (totalEntityData.count - 1) / 2
            if mid < toIndex.row {
                let beforeEntityDispOrder = totalEntityData[toIndex.row - 1].displayOrder
                let targetDisplayOrder = beforeEntityDispOrder + 1
                let halfRight = totalEntityData[(toIndex.row)..<totalEntityData.count]
                halfRight.enumerated().forEach { (index, entity) in
                    entity.displayOrder = (targetDisplayOrder + Int16(index))
                }
            } else {
                /*
                 5 [0, 8] Optional("Lydian mode")
                 ["1:bcxvbvc", "2:vzcx", "3:Dorian mode", "4:Ioniand", "5:Phrygian mode", "6:Mixolydian mode", "7:Aeolian mode", "8:Locrian mode", "132:Lydian mode(삽입됨)",  "9:?????",
                 - 9번의 DisplayOrder 가져오고
                 - 132번의 DisplayOrder 를 9번 displayOrder - 1 해서 8로 변경해야 됨
                 - 최종 결과는 아래와 같이 되야함
                 
                 "0:bcxvbvc", "1:vzcx", "2:Dorian mode", "3:Ioniand", "4:Phrygian mode", "5:Mixolydian mode", "6:Aeolian mode", "7:Locrian mode", "8:Lydian mode",
                 
                 "-3:bcxvbvc", "2:vzcx", "1:Dorian mode", "0:Ioniand", "1:Phrygian mode", "2:Mixolydian mode", "3:Aeolian mode", "4:Locrian mode", "5:Lydian mode",
                 
                 "113:bcxvbvc", "114:vzcx", "115:Dorian mode", "116:Ioniand", "117:Phrygian mode", "118:Mixolydian mode", "119:Aeolian mode", "120:Locrian mode", "121:Lydian mode",
                 
                 - (targetDisplayOrder - (lydian까지의 count - 1)) 에서부터  index(0~를 더해야 최종 결과가 목표한 숫자에 도달
                 
                 */
                let afterEntityDispOrder = totalEntityData[toIndex.row + 1].displayOrder
                let targetDisplayOrder: Int16 = afterEntityDispOrder - 1
                let halfLeft = totalEntityData[0...toIndex.row]
                // print(halfLeft.map{ "\($0.displayOrder):\($0.name!)" })
                let startDisplayOrder: Int16 = targetDisplayOrder - Int16((halfLeft.count - 1))
                halfLeft.enumerated().forEach { (index, entity) in
                    entity.displayOrder = startDisplayOrder + Int16(index)
                }
            }
        }
        
        print("=========================")
        print(totalEntityData!.map({ "\($0.displayOrder):\($0.name!)" }))
        
    }
    
}
