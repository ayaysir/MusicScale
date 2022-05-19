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
            if let fileURL = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2") {
                try instrument.loadMelodicSoundFont(url: fileURL, preset: 67)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Files Didn't Load")
        }
        
        let _ = sequencer.newTrack()!
    }
    
    func stop() {
        engine.stop()
    }
    
    func addScaleToSequencer(semintones: [Int], startSemitone start: Int = 60) {
        
        sequencer.tracks[0].clear()
        
        for (index, semintone) in semintones.enumerated() {
            sequencer.tracks[0].add(noteNumber: MIDINoteNumber(start + semintone), velocity: 90,
                      position: Duration(beats: Double(index)), duration: Duration(beats: 1), channel: MIDIChannel(1))
        }
        
//        sequencer.tracks[0] = track
//        print(sequencer.tracks)
        
        sequencer.debug()
        sequencer.setGlobalMIDIOutput(instrument.midiIn)
//        sequencer.enableLooping(Duration(beats: 4))
        sequencer.setTempo(Double(tempo))
        
        
    }
}
