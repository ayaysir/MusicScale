//
//  QuizMatchKeyViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/08.
//

import Foundation

class QuizEditKeyViewModel {
    
    private var key: Music.Key!
    private var startNote: Note!
    private var scaleName: String!
    private var order: DegreesOrder!
    var onEditNotes: [Note] = []
    var scaleInfo: ScaleInfo!
    
    private let helper = MusicSheetHelper()
    
    init(scaleInfo info: ScaleInfo, key: Music.Key, order: DegreesOrder) {
        scaleInfo = info
        self.key = key
        startNote = key.startNote
        scaleName = "\(key.textValue) \(info.name)"
        self.order = order
    }
    
    func setScaleName(_ name: String, key: Music.Key = .C) {
        scaleName = "\(key.textValue) \(name)"
    }
    
    func addKey(intNotation: Int) {
        let note = Note(intNotation: intNotation, key: key, startOctave: 4, enharmonicMode: .flatAndNatural)
        onEditNotes.append(note)
        print(note)
    }
    
    func removeLastKey() {
        if onEditNotes.count > 0 {
            onEditNotes.removeLast()
        }
    }
    
    func removeAllKeys() {
        onEditNotes.removeAll()
    }
    
    var mergedEditNotes: [Note] {
        return [startNote] + onEditNotes
    }
    
    var abcjsTextOnEdit: String {
        let part = helper.notesToAbcjsPart(notes: mergedEditNotes)
        return helper.composeAbcjsText(scaleNameText: scaleName, tempo: 100, partText: part, lyricText: "")
    }
    
    // var abcjsTextOnEditDegreesAsc: String {
    //     let joinedDegrees = onEditDegreesAsc.joined(separator: " ")
    //     let abcjsPart = helper.degreesToAbcjsPart(degrees: joinedDegrees, order: .ascending, completeFinalNote: false)
    //     return helper.composeAbcjsText(scaleNameText: scaleName, tempo: 100, partText: abcjsPart, lyricText: joinedDegrees)
    // }
    //
    // var abcjsTextOnEditDegreesDesc: String {
    //     let joinedDegrees = onEditDegreesDesc.joined(separator: " ")
    //     let abcjsPart = helper.degreesToAbcjsPart(degrees: joinedDegrees, order: .descending, completeFinalNote: false)
    //     return helper.composeAbcjsText(scaleNameText: scaleName, tempo: 100, partText: abcjsPart, lyricText: joinedDegrees)
    // }
    
    func getNumPair(degree: String) -> NoteNumberPair {
        return helper.degreeToNoteNumeberPair(singleDegree: degree, prevDegree: nil)
    }
    
    func getInteger(degree: String) -> Int {
        let pair = getNumPair(degree: degree)
        return helper.numPairToInteger(pair)
    }
}
