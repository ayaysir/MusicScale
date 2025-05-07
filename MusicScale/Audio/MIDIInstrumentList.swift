//
//  MIDIInstrumentList.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import Foundation

struct InstrumentInfo: Codable, Hashable {
  /// zero-base
  let number: Int
  
  let name: String
  let group: String
  
  var tableRowTitle: String {
    return "\(number). \(name)"
  }
}

let INST_LIST = [
  InstrumentInfo(number: 0, name: "Acoustic Grand Piano", group: "Piano"),
  InstrumentInfo(number: 1, name: "Bright Acoustic Piano", group: "Piano"),
  InstrumentInfo(number: 2, name: "Electric Grand Piano", group: "Piano"),
  InstrumentInfo(number: 3, name: "Honky-tonk Piano", group: "Piano"),
  InstrumentInfo(number: 4, name: "Electric Piano 1", group: "Piano"),
  InstrumentInfo(number: 5, name: "Electric Piano 2", group: "Piano"),
  InstrumentInfo(number: 6, name: "Harpsichord", group: "Piano"),
  InstrumentInfo(number: 7, name: "Clavinet", group: "Piano"),
  InstrumentInfo(number: 8, name: "Celesta", group: "Chromatic Percussion"),
  InstrumentInfo(number: 9, name: "Glockenspiel", group: "Chromatic Percussion"),
  InstrumentInfo(number: 10, name: "Music Box", group: "Chromatic Percussion"),
  InstrumentInfo(number: 11, name: "Vibraphone", group: "Chromatic Percussion"),
  InstrumentInfo(number: 12, name: "Marimba", group: "Chromatic Percussion"),
  InstrumentInfo(number: 13, name: "Xylophone", group: "Chromatic Percussion"),
  InstrumentInfo(number: 14, name: "Tubular Bells", group: "Chromatic Percussion"),
  InstrumentInfo(number: 15, name: "Dulcimer", group: "Chromatic Percussion"),
  InstrumentInfo(number: 16, name: "Drawbar Organ", group: "Organ"),
  InstrumentInfo(number: 17, name: "Percussive Organ", group: "Organ"),
  InstrumentInfo(number: 18, name: "Rock Organ", group: "Organ"),
  InstrumentInfo(number: 19, name: "Church Organ", group: "Organ"),
  InstrumentInfo(number: 20, name: "Reed Organ", group: "Organ"),
  InstrumentInfo(number: 21, name: "Accordion", group: "Organ"),
  InstrumentInfo(number: 22, name: "Harmonica", group: "Organ"),
  InstrumentInfo(number: 23, name: "Tango Accordion", group: "Organ"),
  InstrumentInfo(number: 24, name: "Acoustic Guitar (nylon)", group: "Guitar"),
  InstrumentInfo(number: 25, name: "Acoustic Guitar (steel)", group: "Guitar"),
  InstrumentInfo(number: 26, name: "Electric Guitar (jazz)", group: "Guitar"),
  InstrumentInfo(number: 27, name: "Electric Guitar (clean)", group: "Guitar"),
  InstrumentInfo(number: 28, name: "Electric Guitar (muted)", group: "Guitar"),
  InstrumentInfo(number: 29, name: "Overdriven Guitar", group: "Guitar"),
  InstrumentInfo(number: 30, name: "Distortion Guitar", group: "Guitar"),
  InstrumentInfo(number: 31, name: "Guitar harmonics", group: "Guitar"),
  InstrumentInfo(number: 32, name: "Acoustic Bass", group: "Bass"),
  InstrumentInfo(number: 33, name: "Electric Bass (finger)", group: "Bass"),
  InstrumentInfo(number: 34, name: "Electric Bass (pick)", group: "Bass"),
  InstrumentInfo(number: 35, name: "Fretless Bass", group: "Bass"),
  InstrumentInfo(number: 36, name: "Slap Bass 1", group: "Bass"),
  InstrumentInfo(number: 37, name: "Slap Bass 2", group: "Bass"),
  InstrumentInfo(number: 38, name: "Synth Bass 1", group: "Bass"),
  InstrumentInfo(number: 39, name: "Synth Bass 2", group: "Bass"),
  InstrumentInfo(number: 40, name: "Violin", group: "Strings"),
  InstrumentInfo(number: 41, name: "Viola", group: "Strings"),
  InstrumentInfo(number: 42, name: "Cello", group: "Strings"),
  InstrumentInfo(number: 43, name: "Contrabass", group: "Strings"),
  InstrumentInfo(number: 44, name: "Tremolo Strings", group: "Strings"),
  InstrumentInfo(number: 45, name: "Pizzicato Strings", group: "Strings"),
  InstrumentInfo(number: 46, name: "Orchestral Harp", group: "Strings"),
  InstrumentInfo(number: 47, name: "Timpani", group: "Strings"),
  InstrumentInfo(number: 48, name: "String Ensemble 1", group: "Strings"),
  InstrumentInfo(number: 49, name: "String Ensemble 2", group: "Strings"),
  InstrumentInfo(number: 50, name: "Synth Strings 1", group: "Strings"),
  InstrumentInfo(number: 51, name: "Synth Strings 2", group: "Strings"),
  InstrumentInfo(number: 52, name: "Choir Aahs", group: "Strings"),
  InstrumentInfo(number: 53, name: "Voice Oohs", group: "Strings"),
  InstrumentInfo(number: 54, name: "Synth Voice", group: "Strings"),
  InstrumentInfo(number: 55, name: "Orchestra Hit", group: "Strings"),
  InstrumentInfo(number: 56, name: "Trumpet", group: "Brass"),
  InstrumentInfo(number: 57, name: "Trombone", group: "Brass"),
  InstrumentInfo(number: 58, name: "Tuba", group: "Brass"),
  InstrumentInfo(number: 59, name: "Muted Trumpet", group: "Brass"),
  InstrumentInfo(number: 60, name: "French Horn", group: "Brass"),
  InstrumentInfo(number: 61, name: "Brass Section", group: "Brass"),
  InstrumentInfo(number: 62, name: "Synth Brass 1", group: "Brass"),
  InstrumentInfo(number: 63, name: "Synth Brass 2", group: "Brass"),
  InstrumentInfo(number: 64, name: "Soprano Sax", group: "Reed"),
  InstrumentInfo(number: 65, name: "Alto Sax", group: "Reed"),
  InstrumentInfo(number: 66, name: "Tenor Sax", group: "Reed"),
  InstrumentInfo(number: 67, name: "Baritone Sax", group: "Reed"),
  InstrumentInfo(number: 68, name: "Oboe", group: "Reed"),
  InstrumentInfo(number: 69, name: "English Horn", group: "Reed"),
  InstrumentInfo(number: 70, name: "Bassoon", group: "Reed"),
  InstrumentInfo(number: 71, name: "Clarinet", group: "Reed"),
  InstrumentInfo(number: 72, name: "Piccolo", group: "Pipe"),
  InstrumentInfo(number: 73, name: "Flute", group: "Pipe"),
  InstrumentInfo(number: 74, name: "Recorder", group: "Pipe"),
  InstrumentInfo(number: 75, name: "Pan Flute", group: "Pipe"),
  InstrumentInfo(number: 76, name: "Blown Bottle", group: "Pipe"),
  InstrumentInfo(number: 77, name: "Shakuhachi", group: "Pipe"),
  InstrumentInfo(number: 78, name: "Whistle", group: "Pipe"),
  InstrumentInfo(number: 79, name: "Ocarina", group: "Pipe"),
  InstrumentInfo(number: 80, name: "Lead 1 (square)", group: "Synth Lead"),
  InstrumentInfo(number: 81, name: "Lead 2 (sawtooth)", group: "Synth Lead"),
  InstrumentInfo(number: 82, name: "Lead 3 (calliope)", group: "Synth Lead"),
  InstrumentInfo(number: 83, name: "Lead 4 (chiff)", group: "Synth Lead"),
  InstrumentInfo(number: 84, name: "Lead 5 (charang)", group: "Synth Lead"),
  InstrumentInfo(number: 85, name: "Lead 6 (voice)", group: "Synth Lead"),
  InstrumentInfo(number: 86, name: "Lead 7 (fifths)", group: "Synth Lead"),
  InstrumentInfo(number: 87, name: "Lead 8 (bass + lead)", group: "Synth Lead"),
  InstrumentInfo(number: 88, name: "Pad 1 (new age)", group: "Synth Pad"),
  InstrumentInfo(number: 89, name: "Pad 2 (warm)", group: "Synth Pad"),
  InstrumentInfo(number: 90, name: "Pad 3 (polysynth)", group: "Synth Pad"),
  InstrumentInfo(number: 91, name: "Pad 4 (choir)", group: "Synth Pad"),
  InstrumentInfo(number: 92, name: "Pad 5 (bowed)", group: "Synth Pad"),
  InstrumentInfo(number: 93, name: "Pad 6 (metallic)", group: "Synth Pad"),
  InstrumentInfo(number: 94, name: "Pad 7 (halo)", group: "Synth Pad"),
  InstrumentInfo(number: 95, name: "Pad 8 (sweep)", group: "Synth Pad"),
  InstrumentInfo(number: 96, name: "FX 1 (rain)", group: "Synth Effects"),
  InstrumentInfo(number: 97, name: "FX 2 (soundtrack)", group: "Synth Effects"),
  InstrumentInfo(number: 98, name: "FX 3 (crystal)", group: "Synth Effects"),
  InstrumentInfo(number: 99, name: "FX 4 (atmosphere)", group: "Synth Effects"),
  InstrumentInfo(number: 100, name: "FX 5 (brightness)", group: "Synth Effects"),
  InstrumentInfo(number: 101, name: "FX 6 (goblins)", group: "Synth Effects"),
  InstrumentInfo(number: 102, name: "FX 7 (echoes)", group: "Synth Effects"),
  InstrumentInfo(number: 103, name: "FX 8 (sci-fi)", group: "Synth Effects"),
  InstrumentInfo(number: 104, name: "Sitar", group: "Ethnic"),
  InstrumentInfo(number: 105, name: "Banjo", group: "Ethnic"),
  InstrumentInfo(number: 106, name: "Shamisen", group: "Ethnic"),
  InstrumentInfo(number: 107, name: "Koto", group: "Ethnic"),
  InstrumentInfo(number: 108, name: "Kalimba", group: "Ethnic"),
  InstrumentInfo(number: 109, name: "Bag pipe", group: "Ethnic"),
  InstrumentInfo(number: 110, name: "Fiddle", group: "Ethnic"),
  InstrumentInfo(number: 111, name: "Shanai", group: "Ethnic"),
  InstrumentInfo(number: 112, name: "Tinkle Bell", group: "Percussive"),
  InstrumentInfo(number: 113, name: "Agogo", group: "Percussive"),
  InstrumentInfo(number: 114, name: "Steel Drums", group: "Percussive"),
  InstrumentInfo(number: 115, name: "Woodblock", group: "Percussive"),
  InstrumentInfo(number: 116, name: "Taiko Drum", group: "Percussive"),
  InstrumentInfo(number: 117, name: "Melodic Tom", group: "Percussive"),
  InstrumentInfo(number: 118, name: "Synth Drum", group: "Percussive"),
  InstrumentInfo(number: 119, name: "Reverse Cymbal", group: "Sound effects"),
  InstrumentInfo(number: 120, name: "Guitar Fret Noise", group: "Sound effects"),
  InstrumentInfo(number: 121, name: "Breath Noise", group: "Sound effects"),
  InstrumentInfo(number: 122, name: "Seashore", group: "Sound effects"),
  InstrumentInfo(number: 123, name: "Bird Tweet", group: "Sound effects"),
  InstrumentInfo(number: 124, name: "Telephone Ring", group: "Sound effects"),
  InstrumentInfo(number: 125, name: "Helicopter", group: "Sound effects"),
  InstrumentInfo(number: 126, name: "Applause", group: "Sound effects"),
  InstrumentInfo(number: 127, name: "Gunshot", group: "Sound effects"),
]
struct InstrumentList {
  
  private static var sectionList: [String] {
    INST_LIST.reduce(into: [String]()) { partialResult, currentValue in
      
      // partialResult 배열의 길이가 0이거나, partialResult 배열의 마지막 원소가 현재 원소랑 같지 않다면
      if(partialResult.count == 0 || partialResult[partialResult.count - 1] != currentValue.group) {
        partialResult.append(currentValue.group)
      }
    }
  }
  
  private static var instListByGroup: Dictionary<String, [InstrumentInfo]> {
    Dictionary(grouping: INST_LIST) { $0.group }
  }
  
  static var sectionCount: Int { sectionList.count }
  
  static func sectionTitle(_ section: Int) -> String {
    return sectionList[section]
  }
  
  static func rowCount(section: Int) -> Int {
    let sectionStr = sectionList[section]
    return instListByGroup[sectionStr]!.count
  }
  
  static func instrument(at indexPath: IndexPath) -> InstrumentInfo {
    guard let sectionStr = sectionList[safe: indexPath.section],
          let group = instListByGroup[sectionStr],
          let info = group[safe: indexPath.row] else {
      return INST_LIST[0]
    }
    
    return info
  }
  
  static func indexPath(of number: Int) -> IndexPath? {
    guard let first = INST_LIST.first(where: { $0.number == number }),
          let sectionIndex = sectionList.firstIndex(of: first.group),
          let rowIndex = instListByGroup[first.group]?.firstIndex(where: { $0.number == number })
    else {
      return nil
    }
    
    return IndexPath(row: rowIndex, section: sectionIndex)
  }
}
