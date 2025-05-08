//
//  AdvSearchEditKeyViewModel.swift
//  MusicScale
//
//  Created by 윤범태 on 5/8/25.
//

import Foundation

// TODO: - ⚠️⚠️ QuizEditKeyViewModel과 공통부분 모듈화 ⚠️⚠️
class AdvSearchEditKeyViewModel {
  var key: Music.Key!
  private var scaleName: String!
  private var tempo: Double
  var onEditNotes: [Note] = []
  
  private let helper = MusicSheetHelper()
  
  init(
    key: Music.Key,
    tempo: Double
  ) {
    self.key = key
    
    scaleName = "\(key.textValue) Scale"
    self.tempo = tempo
    
    onEditNotes.append(key.startNote)
  }
  
  func setScaleName(key: Music.Key = .C) {
    scaleName = "\(key.textValue) Scale"
  }
  
  func addKey(intNotation: Int, enharmonicMode: EnharmonicMode, strPairs: [NoteStrPair]? = nil) {
    guard onEditNotes.count <= 32 else {
      return
    }
    
    let note: Note = {
      if let strPairs = enharmonicMode.noteStrOfFirstOctave {
        return Note(intNotation: intNotation, key: key, startOctave: 4, strPairs: strPairs)
      } else if let strPairs = strPairs {
        return Note(intNotation: intNotation, key: key, startOctave: 4, strPairs: strPairs)
      } else {
        return Note(intNotation: intNotation, key: key, startOctave: 4, strPairs: EnharmonicMode.userCustom.noteStrOfFirstOctave!)
      }
    }()
    
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
  
  var abcjsTextOnEdit: String {
    let part = helper.notesToAbcjsPart(notes: onEditNotes)
    return helper.composeAbcjsText(scaleNameText: scaleName, tempo: tempo, partText: part, lyricText: "")
  }
  
  var playbackMidiNumbersOnEdit: [Int] {
    return helper.getMidiNumberForPlaybackNotes(notes: onEditNotes)
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
    return onEditNotes.map { $0.midiNoteNumber - key.startNote.midiNoteNumber  }
  }
}
