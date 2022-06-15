//
//  MIDISoundGenerator.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/10.
//

import Foundation
import AudioKit

// let gsMuseScoreFileURL = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2")

class MIDISoundGenerator {
    
    let engine = AudioEngine()
    private var instrument = MIDISampler(name: "Instrument 1")
    private var currentMIDINoteNumber: MIDINoteNumber!
    private var currentChannel: MIDIChannel!
    
    init(soundbankURL: URL? = gsMuseScoreFileURL, instPreset preset: Int = AppConfigStore.shared.pianoInstrument) {
        engine.output = instrument
        
        // Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
        do {
            if let fileURL = soundbankURL {
                try instrument.loadMelodicSoundFont(url: fileURL, preset: preset)
            } else {
                Log("MIDISoundGenerator: Could not find soundbank file.")
            }
        } catch {
            Log("MIDISoundGenerator: Could not load instrument.")
        }
        
        startEngine()
    }
    
    func playSound(noteNumber: MIDINoteNumber, velocity: MIDIVelocity = 90, channel: MIDIChannel = 1) {
        currentMIDINoteNumber = noteNumber
        currentChannel = channel
        instrument.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
    }
    
    func playSound(noteNumber: Int, velocity: MIDIVelocity = 90, channel: MIDIChannel = 1) {
        playSound(noteNumber: MIDINoteNumber(noteNumber), velocity: velocity, channel: channel)
    }
    
    func playSoundWithDuration(noteNumber: Int, millisecond: Int, velocity: MIDIVelocity = 90, channel: MIDIChannel = 1) {
        let midiNoteNumber = MIDINoteNumber(noteNumber)
        instrument.play(noteNumber: midiNoteNumber, velocity: velocity, channel: channel)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(millisecond)) {
            self.instrument.stop(noteNumber: midiNoteNumber, channel: channel)
        }
    }
    
    func stopSound() {
        if let midiNoteNumber = currentMIDINoteNumber, let channel = currentChannel {
            instrument.stop(noteNumber: midiNoteNumber, channel: channel)
            self.currentMIDINoteNumber = nil
        } else {
            instrument.stop()
        }
    }
    
    func startEngine() {
        do {
            try engine.start()
        } catch {
            Log("MIDISoundGenerator: AudioKit did not start!")
        }
    }
    
    func stopEngine() {
        engine.stop()
    }
}
