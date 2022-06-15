//
//  Sequencer.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/19.
//

import Foundation
import AudioKit

class NoteSequencerConductor: ObservableObject {
    let engine = AudioEngine()
    let instrument = MIDISampler(name: "Piano")
    let sequencer = AppleSequencer()
    
    @Published var tempo: Float = 120 {
        didSet {
            sequencer.setTempo(BPM(tempo))
        }
    }
    
    @Published var isPlaying = false {
        didSet {
            isPlaying ? sequencer.play() : sequencer.stop()
        }
    }
    
    init() {
        engine.output = instrument
    }
    
    func start() {
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start! \(error)")
        }
        
        do {
            let preset = AppConfigStore.shared.playbackInstrument
            if let fileURL = gsMuseScoreFileURL {
                try instrument.loadMelodicSoundFont(url: fileURL, preset: preset)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Files Didn't Load")
        }
        
        let _ = sequencer.newTrack()!
        let _ = sequencer.newTrack()!
    }
    
    func stop() {
        engine.stop()
    }
    
    func addScaleToSequencer(semitones: [Int], startSemitone start: Int = 60) {
        
        guard sequencer.tracks.first != nil else {
            print("NoteSequencerConductor: Tracks are not initialized. Place the conductor.start() in the appropriate place.")
            return
        }
        
        sequencer.tracks[0].clear()
        sequencer.tracks[1].clear()
        
        for (index, semitone) in semitones.enumerated() {
            sequencer.tracks[0].add(noteNumber: MIDINoteNumber(start + semitone), velocity: 90,
                      position: Duration(beats: Double(index)), duration: Duration(beats: 1), channel: MIDIChannel(1))
        }
        
        sequencer.debug()
        sequencer.setGlobalMIDIOutput(instrument.midiIn)
        sequencer.setTempo(Double(tempo))
    }
    
    func addScaleToSequencerTwoTrack(semitones1: [Int], semitones2: [Int], startFrom_1: Int, startFrom_2: Int) {
        guard sequencer.tracks.first != nil else {
            print("NoteSequencerConductor: Tracks are not initialized. Place the conductor.start() in the appropriate place.")
            return
        }
        
        sequencer.tracks[0].clear()
        sequencer.tracks[1].clear()
        
        for (index, semitone) in semitones1.enumerated() {
            sequencer.tracks[0].add(noteNumber: MIDINoteNumber(startFrom_1 + semitone), velocity: 90,
                      position: Duration(beats: Double(index)), duration: Duration(beats: 1), channel: MIDIChannel(1))
        }
        for (index, semitone) in semitones2.enumerated() {
            sequencer.tracks[1].add(noteNumber: MIDINoteNumber(startFrom_2 + semitone), velocity: 90,
                      position: Duration(beats: Double(index)), duration: Duration(beats: 1), channel: MIDIChannel(1))
        }
        
        sequencer.debug()
        sequencer.setGlobalMIDIOutput(instrument.midiIn)
        sequencer.setTempo(Double(tempo))
    }
}
