//
//  SortFilterConfigStore.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/31.
//

import Foundation

extension String {
    static let kSortState = "SORTFILTER_SortState"
    static let kSortOrder = "SORTFILTER_SortOrder"
}


struct SortFilterConfigStore: UserDefaultsConfigurator {
    
    mutating func initalizeConfigValueOnFirstrun() {
        currentOrder = .ascending
        currentState = .displayOrder
    }
    
    static var shared = SortFilterConfigStore()
    private let store = UserDefaults.standard
    
    var currentOrder: SortOrder {
        get {
            let storedInt = store.integer(forKey: .kSortOrder)
            return SortOrder(rawValue: storedInt) ?? .none
        } set {
            store.set(newValue.rawValue, forKey: .kSortOrder)
        }
    }
    
    var currentState: SortState {
        get {
            let storedInt = store.integer(forKey: .kSortState)
            return SortState(rawValue: storedInt) ?? .none
        } set {
            store.set(newValue.rawValue, forKey: .kSortState)
        }
    }
}
