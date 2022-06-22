//
//  UserDefaultsConfigurator.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/22.
//

import Foundation

protocol UserDefaultsConfigurator {
    mutating func initalizeConfigValueOnFirstrun()
}

var userDefaultsConfiguratorList: [UserDefaultsConfigurator] = [
    ScaleInfoVCConfigStore.shared,
    SortFilterConfigStore.shared,
    QuizConfigStore.shared,
    AppConfigStore.shared,
]
