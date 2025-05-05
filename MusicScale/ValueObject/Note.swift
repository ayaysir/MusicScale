//
//  Note.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import Foundation

struct Note: Codable, Equatable, Comparable {
  
  var scale7: Music.Scale7 = .C
  var accidental: Music.Accidental = .natural
  
  /// 절대 옥타브: 예) C4 = 60
  var octave: Int = 4
  
  init(scale7: Music.Scale7 = .C, accidental: Music.Accidental = .natural, octave: Int = 4) {
    self.scale7 = scale7
    self.accidental = accidental
    self.octave = octave
  }
  
  // init(midiNoteNumber: Int, enharmonicMode: EnharmonicMode) {
  //     let strPairs = enharmonicMode.noteStrOfFirstOctave ?? EnharmonicMode.userCustom.noteStrOfFirstOctave!
  //     let intNotation = midiNoteNumber % 12
  //
  //     if let pair = strPairs[safe: intNotation],
  //        let accidental = Music.Accidental.findAccidental(from: pair.prefix),
  //        let scale7 = Music.Scale7.getScaleByNoteName(pair.noteStr) {
  //
  //         octave = Int(floor(Double(midiNoteNumber) / 12.0)) - 1
  //         self.accidental = accidental
  //         self.scale7 = scale7
  //     }
  // }
  
  init(intNotation: Int, key: Music.Key, startOctave: Int, strPairs: [NoteStrPair]) {
    let adjustedNotation = intNotation + key.distanceFromC
    let notationInFirstOctave = adjustedNotation >= 0 ? adjustedNotation % 12 : 12 + (adjustedNotation % 12)
    let relativeOctave = Int(floor(Double(adjustedNotation) / 12.0))
    
    if let pair = strPairs[safe: notationInFirstOctave],
       let accidental = Music.Accidental.findAccidental(from: pair.prefix),
       let scale7 = Music.Scale7.getScaleByNoteName(pair.noteStr) {
      
      octave = startOctave + relativeOctave
      self.accidental = accidental
      self.scale7 = scale7
    }
  }
  
  var midiNoteNumber: Int {
    return (octave + 1) * 12 + scale7.rawValue + accidental.rawValue
  }
  
  var hasAccidentalExceptNatural: Bool {
    return accidental != .natural
  }
  
  static func == (lhs: Note, rhs: Note) -> Bool {
    return lhs.scale7 == rhs.scale7 && lhs.accidental == rhs.accidental
  }
  
  static func < (lhs: Note, rhs: Note) -> Bool {
    
    if lhs.scale7 == rhs.scale7 {
      return lhs.accidental.rawValue < rhs.accidental.rawValue
    }
    return lhs.scale7.rawValue < rhs.scale7.rawValue
  }
}


