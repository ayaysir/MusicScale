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
    private let helper = MusicSheetHelper()
    
    init(scaleInfo: ScaleInfo, currentKey: Music.Key) {
        self.scaleInfo = scaleInfo
        self.currentKey = currentKey
    }
    
    func setCurrentKey(_ key: Music.Key) {
        currentKey = key
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
        do {
            let integersText = try helper.getIntegerNotationOfAscending(degrees: scaleInfo.degreesAscending).map(String.init).joined(separator: ", ")
            return "(\(integersText))"
        } catch {
            print(error)
            return nil
        }
    }
    
    var ascendingPattern: String? {
        do {
            return try helper.getPattern(degrees: scaleInfo.degreesAscending).map(String.init).joined(separator: "")
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - 키, asc, desc에 따라 변화되는 것
    var abcjsPart: String {
        helper.degreesToAbcjsPart(degrees: scaleInfo.degreesAscending)
    }
    
    var abcjsLyric: String {
        helper.degreesToAbcjsLyric(degrees: scaleInfo.degreesAscending)
    }
    
    var abcjsText: String {
        helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, isDesceding: false, key: currentKey, tempo: 120)
    }
    
    
    
}
