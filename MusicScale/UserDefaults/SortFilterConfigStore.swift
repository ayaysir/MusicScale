//
//  SortFilterConfigStore.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/31.
//

import Foundation

extension String {
    
    // static let kSortDisplayOrder = "SORTFILTER_SortDisplayOrder"
    // static let kSortNameAsc = "SORTFILTER_SortNameAsc"
    // static let kSortNameDesc = "SORTFILTER_SortNameDesc"
    // static let kSortPriorityAsc = "SORTFILTER_SortPriorityAsc"
    // static let kSortPriorityDesc = "SORTFILTER_SortPriorityDesc"
    static let kSortState = "SORTFILTER_SortState"
    static let kSortOrder = "SORTFILTER_SortOrder"
}


struct SortFilterConfigStore {
    static var shared = SortFilterConfigStore()
    private let store = UserDefaults.standard
    
    var curentOrder: SortOrder {
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
