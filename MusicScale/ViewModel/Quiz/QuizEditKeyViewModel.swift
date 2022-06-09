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
    private var tempo: Double
    var onEditNotes: [Note] = []
    var scaleInfo: ScaleInfo!
    
    private let helper = MusicSheetHelper()
    
    init(scaleInfo info: ScaleInfo, key: Music.Key, order: DegreesOrder, tempo: Double) {
        scaleInfo = info
        self.key = key
        
        scaleName = "\(key.textValue) \(info.name)"
        self.order = order
        self.tempo = tempo
        
        switch order {
        case .ascending:
            startNote = key.startNote
        case .descending:
            var newStartNote = key.startNote
            newStartNote.octave += 1
            startNote = newStartNote
        }
    }
    
    func setScaleName(_ name: String, key: Music.Key = .C) {
        scaleName = "\(key.textValue) \(name)"
    }
    
    func addKey(intNotation: Int, enharmonicMode: EnharmonicMode, strPairs: [NoteStrPair]? = nil) {
        
        let note: Note = {
            if let strPairs = enharmonicMode.noteStrOfFirstOctave {
                return Note(intNotation: intNotation, key: key, startOctave: 4, strPairs: strPairs)
            } else if let strPairs = strPairs {
                return Note(intNotation: intNotation, key: key, startOctave: 4, strPairs: strPairs)
            } else {
                return Note(intNotation: intNotation, key: key, startOctave: 4, strPairs: EnharmonicMode.userCustom.noteStrOfFirstOctave!)
            }
        }()
        
        if onEditNotes.isEmpty && note.midiNoteNumber == startNote.midiNoteNumber {
            return
        }
        onEditNotes.append(note)
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
        return helper.composeAbcjsText(scaleNameText: scaleName, tempo: tempo, partText: part, lyricText: "")
    }
    
    /// 멀티파트 abcjstext 반환
    func abcjsTextForComparison(_ successQuestion: Bool, originalDegrees: String, order: DegreesOrder, key: Music.Key, octaveShift: Int, enharmonicMode: EnharmonicMode) -> String {
        let onEditPart = helper.notesToAbcjsPart(notes: mergedEditNotes)
        let originalPart = helper.degreesToAbcjsPart(degrees: originalDegrees, order: order, completeFinalNote: true, key: key, octaveShift: octaveShift, enharmonicMode: enharmonicMode)
        
        let onEditLyric = integerNotationsOnEdit.map(String.init).joined(separator: " ")
        
        let originalIntNotation = helper.getIntegerNotation(degrees: originalDegrees, order: order, completeFinalNote: true)
        let originalLyric = originalIntNotation.map({ number in
            if order == .descending {
                let lastNumber = originalIntNotation.last!
                return String(number + -lastNumber)
            }
            
            return String(number)
        }).joined(separator: " ")
        
        let submitPrefixEmoji = successQuestion ? "✅" : "❌"
        let parts = [
            AbcjsPart(partName: "\(submitPrefixEmoji) You", partText: onEditPart, lyricText: onEditLyric),
            AbcjsPart(partName: "✅ Answer", partText: originalPart, lyricText: originalLyric),
        ]
        
        return helper.composeAbcjsTextForMultipart(scaleNameText: scaleName, tempo: tempo, abcjsParts: parts)
    }
    
    var playbackMidiNumbersOnEdit: [Int] {
        return helper.getMidiNumberForPlaybackNotes(notes: mergedEditNotes)
    }
    
    func getNumPair(degree: String) -> NoteNumberPair {
        return helper.degreeToNoteNumeberPair(singleDegree: degree, prevDegree: nil)
    }
    
    func getInteger(degree: String) -> Int {
        let pair = getNumPair(degree: degree)
        return helper.numPairToInteger(pair)
    }
    
    /// 현재 편집중인 노트의 integerNotation 반환
    var integerNotationsOnEdit: [Int] {
        return mergedEditNotes.map { $0.midiNoteNumber - startNote.midiNoteNumber + (order == .descending ? 12 : 0) }
    }
    
    /// 채점
    func checkAnswer(originalAnswer: [Int]) -> Bool {
        
        // 1. 카운트 일치 여부 확인
        guard integerNotationsOnEdit.count == originalAnswer.count else {
            return false
        }
        
        // 2. 원본과 제출본 비교
        // 3. true/false 반환
        print(integerNotationsOnEdit, originalAnswer)
        return integerNotationsOnEdit == originalAnswer
    }
}
