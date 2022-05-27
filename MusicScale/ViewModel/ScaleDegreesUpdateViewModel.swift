//
//  ScaleDegreesUpdateViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/26.
//

import Foundation

class ScaleDegreesUpdateViewModel {
    
    var onEditDegreesAsc: [String] = ["1"]
    var onEditDegreesDesc: [String] = ["1"]
    var scaleName = "C Aeioulian"
    
    private let helper = MusicSheetHelper()
    
    init() {
        
    }
    
    init(ascDegrees: String, descDegrees: String) {
        onEditDegreesAsc = ascDegrees.components(separatedBy: " ")
        onEditDegreesDesc = ascDegrees.components(separatedBy: " ")
    }
    
    var degreesAsc: String {
        onEditDegreesAsc.joined(separator: " ")
    }
    
    var degreesDesc: String {
        onEditDegreesDesc.joined(separator: " ")
    }
    
    func setScaleName(_ name: String, key: Music.Key = .C) {
        scaleName = "\(key.textValue) \(name)"
    }
    
    var abcjsTextOnEditDegreesAsc: String {
        let joinedDegrees = onEditDegreesAsc.joined(separator: " ")
        let abcjsPart = helper.degreesToAbcjsPart(degrees: joinedDegrees, order: .ascending, completeFinalNote: false)
        return helper.composeAbcjsText(scaleNameText: scaleName, tempo: 100, partText: abcjsPart, lyricText: joinedDegrees)
    }
    
    func getNumPair(degree: String) -> NoteNumberPair {
        return helper.degreeToNoteNumeberPair(singleDegree: degree, prevDegree: nil)
    }
    
    func getInteger(degree: String) -> Int {
        let pair = getNumPair(degree: degree)
        return helper.numPairToInteger(pair)
    }
    
    
}
