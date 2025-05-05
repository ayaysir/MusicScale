//
//  MIDICommon.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import Foundation

let gsMuseScoreFileURL = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2")

struct GlobalConductor {
  static let shared = NoteSequencerConductor()
}

struct GlobalGenerator {
  static let shared = MIDISoundGenerator()
}

struct GlobalMIDIListener {
  static let shared = MIDIListener()
}
