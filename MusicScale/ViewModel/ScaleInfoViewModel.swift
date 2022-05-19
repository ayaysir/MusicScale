//
//  ScaleInfoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/16.
//

import Foundation

class ScaleInfoViewModel {
    
    private let scaleInfo: ScaleInfo
    private(set) var currentKey: Music.Key
    private(set) var currentTempo: Double
    private let helper = MusicSheetHelper()
    
    init(scaleInfo: ScaleInfo, currentKey: Music.Key, currentTempo: Double) {
        self.scaleInfo = scaleInfo
        self.currentKey = currentKey
        self.currentTempo = currentTempo
    }
    
    func setCurrentKey(_ key: Music.Key) {
        currentKey = key
    }
    
    func setCurrentTempo(_ tempo: Double) {
        currentTempo = tempo
    }
    
    // MARK: - 키 변화와 무관
    var name: String {
        return scaleInfo.name
    }
    
    var nameAlias: String {
        return scaleInfo.nameAlias
    }
    
    var defaultPriority: Int {
        return scaleInfo.defaultPriority
    }
    
    var comment: String {
        return scaleInfo.comment
    }
    
    var ascendingIntegerNotation: String? {
        let integersText = helper.getIntegerNotation(degrees: scaleInfo.degreesAscending, order: .ascending).map(String.init).joined(separator: ", ")
        return "(\(integersText))"
    }
    
    var ascendingPattern: String? {
        do {
            return try helper.getPattern(degrees: scaleInfo.degreesAscending).map(String.init).joined(separator: " ")
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - 키, asc, desc에 따라 변화되는 것
//    var abcjsPart: String {
//        helper.degreesToAbcjsPart(degrees: scaleInfo.degreesAscending)
//    }
//
//    var abcjsLyric: String {
//        helper.degreesToAbcjsLyric(degrees: scaleInfo.degreesAscending)
//    }
    
    var abcjsTextAscending: String {
        return helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, order: .ascending, key: currentKey, tempo: currentTempo)
    }
    
    var abcjsTextDescending: String {
        return helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, order: .descending, key: currentKey, tempo: currentTempo)
    }
    
    var playbackSemitoneAscending: [Int]? {
        return helper.getSemitoneToPlaybackNotes(scaleInfo: scaleInfo, order: .ascending, key: currentKey)
    }
    
    var playbackSemitoneDescending: [Int]? {
        return helper.getSemitoneToPlaybackNotes(scaleInfo: scaleInfo, order: .descending, key: currentKey)
    }
    
}
