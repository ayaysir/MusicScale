//
//  ScaleInfoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/16.
//

import Foundation

class ScaleInfoViewModel {
    
    private let scaleInfo: ScaleInfo
    private var currentKey: Any
    private let helper = MusicSheetHelper()
    
    init(scaleInfo: ScaleInfo) {
        self.scaleInfo = scaleInfo
        self.currentKey = "!"
    }
    
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
    
    var abcjsPart: String {
        helper.degreesToAbcjsLyric(degrees: scaleInfo.degreesAscending)
    }
    
    var abcjsLyric: String {
        helper.degreesToAbcjsLyric(degrees: scaleInfo.degreesAscending)
    }
    
    var abcjsText: String {
        helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo)
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
    
}
