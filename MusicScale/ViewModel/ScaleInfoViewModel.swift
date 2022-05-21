//
//  ScaleInfoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/16.
//

import Foundation


class ScaleInfoViewModel {
    
    private let scaleInfo: ScaleInfo
    private let helper = MusicSheetHelper()
    
    var currentKey: Music.Key
    var currentTempo: Double
    var currentOctaveShift: Int
    var currentEnharmonicMode: EnharmonicMode
    
    init(scaleInfo: ScaleInfo, currentKey: Music.Key, currentTempo: Double, currentOctaveShift: Int = 0, currentEnharmonicMode: EnharmonicMode = .standard) {
        self.scaleInfo = scaleInfo
        self.currentKey = currentKey
        self.currentTempo = currentTempo
        self.currentOctaveShift = currentOctaveShift
        self.currentEnharmonicMode = currentEnharmonicMode
    }
    
    // MARK: - current 변수의 변화와 무관
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
    
    // MARK: - current 변수에 따라 변화되는 것
//    var abcjsPart: String {
//        helper.degreesToAbcjsPart(degrees: scaleInfo.degreesAscending)
//    }
//
//    var abcjsLyric: String {
//        helper.degreesToAbcjsLyric(degrees: scaleInfo.degreesAscending)
//    }
    
    var abcjsTextAscending: String {
        return helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, order: .ascending, key: currentKey, tempo: currentTempo, octaveShift: currentOctaveShift, enharmonicMode: currentEnharmonicMode)
    }
    
    var abcjsTextDescending: String {
        return helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, order: .descending, key: currentKey, tempo: currentTempo, octaveShift: currentOctaveShift, enharmonicMode: currentEnharmonicMode)
    }
    
    var playbackSemitoneAscending: [Int]? {
        return helper.getSemitoneToPlaybackNotes(scaleInfo: scaleInfo, order: .ascending, key: currentKey, octaveShift: currentOctaveShift)
    }
    
    var playbackSemitoneDescending: [Int]? {
        return helper.getSemitoneToPlaybackNotes(scaleInfo: scaleInfo, order: .descending, key: currentKey, octaveShift: currentOctaveShift)
    }
    
    var expectedPlayTime: Double {
        // t = 1 / b. Therefore: 1 min / 96 = 60,000 ms / 96 = 625 ms.
        return (60 / currentTempo) * Double(playbackSemitoneAscending!.count)
    }
    
}
