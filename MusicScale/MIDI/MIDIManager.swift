//
//  MIDIManager.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/13.
//

import AVFoundation

class MIDIManager {
    
    var soundbank: URL?
    
    var midiPlayer: AVMIDIPlayer?
    var musicPlayer: MusicPlayer?
    
    var notePlayers: [AVMIDIPlayer] = []
    
    var headSilence: Double = 0.1
    
    var musicSequence: MusicSequence! {
        didSet {
            createAVMIDIPlayer(sequence: self.musicSequence)
            self.musicPlayer = createMusicPlayer(musicSequence)
        }
    }
    
    var currentBPM: Double = 100
    
    // 기본 사운드폰트 사용
    convenience init() {
        let generalSoundbank = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2")
        self.init(soundbank: generalSoundbank)
    }
    
    init(soundbank: URL?) {
        self.soundbank = soundbank
        createNotePlayers()
//        print(notePlayers)
    }
    
    deinit {
        self.soundbank = nil
        self.musicSequence = nil
        self.musicPlayer = nil
        self.midiPlayer = nil
    }
    
    func createOneNotePlayer(semitone: Int) -> AVMIDIPlayer? {
        
        guard let bankURL = soundbank else {
            fatalError("sound bank file not found.")
        }
        
        var status = noErr
        var data: Unmanaged<CFData>?
        
        status = MusicSequenceFileCreateData (oneNoteSequence(semitone: semitone),
                                              MusicSequenceFileTypeID.midiType,
                                              MusicSequenceFileFlags.eraseFile,
                                              480, &data)
        if status != noErr {
            print("bad status \(status)")
        }
        
        if let md = data {
            let midiData = md.takeUnretainedValue() as Data
            do {
                let player = try AVMIDIPlayer(data: midiData as Data, soundBankURL: bankURL)
                return player
            } catch let error as NSError {
                print("nil midi player")
                print("Error \(error.localizedDescription)")
            }
            data?.release()
        }
        
        return nil
    }
    
    func createNotePlayers() {
        
        for semitone in 0...120 {
            notePlayers.append(createOneNotePlayer(semitone: semitone)!)
        }
    }
    
    func createAVMIDIPlayer(sequence musicSequence: MusicSequence) {
        
        guard let bankURL = soundbank else {
            fatalError("sound bank file not found.")
        }
        
        var status = noErr
        var data: Unmanaged<CFData>?
        status = MusicSequenceFileCreateData (musicSequence,
                                              MusicSequenceFileTypeID.midiType,
                                              MusicSequenceFileFlags.eraseFile,
                                              480, &data)
        
        if status != noErr {
            print("bad status \(status)")
        }
        
        if let md = data {
            let midiData = md.takeUnretainedValue() as Data
            do {
                try self.midiPlayer = AVMIDIPlayer(data: midiData as Data, soundBankURL: bankURL)
                print("created midi player with sound bank url \(bankURL)")
            } catch let error as NSError {
                print("nil midi player")
                print("Error \(error.localizedDescription)")
            }
            data?.release()
            
            self.midiPlayer?.prepareToPlay()
        }
        
    }
    
    func createAVMIDIPlayer(midiFile midiFileURL: URL?) {
        
        guard let midiFileURL = midiFileURL else {
            fatalError("midi file not found.")
        }
        
        guard let bankURL = soundbank else {
            fatalError("sound bank file not found.")
        }
        
        do {
            try self.midiPlayer = AVMIDIPlayer(contentsOf: midiFileURL, soundBankURL: bankURL)
            print("created midi player with sound bank url \(bankURL)")
        } catch let error {
            print("Error \(error.localizedDescription)")
        }
        
        self.midiPlayer?.prepareToPlay()
    }
    
    func createMusicPlayer(_ musicSequence: MusicSequence) -> MusicPlayer {
        var musicPlayer: MusicPlayer? = nil
        var status = noErr
        
        status = NewMusicPlayer(&musicPlayer)
        if status != noErr {
            print("bad status \(status) creating player")
        }
        
        status = MusicPlayerSetSequence(musicPlayer!, musicSequence)
        if status != noErr {
            print("setting sequence \(status)")
        }
        
        status = MusicPlayerPreroll(musicPlayer!)
        if status != noErr {
            print("prerolling player \(status)")
        }
        
        return musicPlayer!
    }
    
    func playMusicPlayer() {
        var status = noErr
        var playing = DarwinBoolean(false)
        
        status = MusicPlayerIsPlaying(musicPlayer!, &playing)
        if playing != false {
            print("music player is playing. stopping")
            status = MusicPlayerStop(musicPlayer!)
            if status != noErr {
                print("Error stopping \(status)")
                return
            }
        } else {
            print("music player is not playing.")
        }
        
        status = MusicPlayerSetTime(musicPlayer!, 0)
        if status != noErr {
            print("setting time \(status)")
            return
        }
        
        status = MusicPlayerStart(musicPlayer!)
        if status != noErr {
            print("Error starting \(status)")
            return
        }
    }
    
    func stopMusicPlayer() {
        let status = MusicPlayerStop(musicPlayer!)
        if status != noErr {
            print("Error stopping \(status)")
            return
        }
        
    }
}

extension MIDIManager {
    
    func playNote(semitone: Int) {
        self.notePlayers[semitone].play()
    }
    
    func stopNote() {
        
        for semitone in (0...notePlayers.count - 1) {
            if notePlayers[semitone].isPlaying {
                notePlayers[semitone].stop()
                //
                notePlayers[semitone] = createOneNotePlayer(semitone: semitone)!
            }
        }
    }
    
    func oneNoteSequence(semitone: Int) -> MusicSequence {
        
        // create the sequence
        var musicSequence: MusicSequence?
        var status = NewMusicSequence(&musicSequence)
        if status != noErr {
            print(" bad status \(status) creating sequence")
        }
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(musicSequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }
        
        let bpm: Double = currentBPM
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, Float64(bpm)) != noErr {
            print("could not set tempo")
        }
        
        // add a track
        var track: MusicTrack?
        status = MusicSequenceNewTrack(musicSequence!, &track)
        if status != noErr {
            print("error creating track \(status)")
        }
        
        // bank select msb
        var chMsg = MIDIChannelMessage(status: 0xB0, data1: 0, data2: 0, reserved: 0)
        status = MusicTrackNewMIDIChannelEvent(track!, 0, &chMsg)
        if status != noErr {
            print("creating bank select event \(status)")
        }
        
        // bank select lsb
        chMsg = MIDIChannelMessage(status: 0xB0, data1: 32, data2: 0, reserved: 0)
        status = MusicTrackNewMIDIChannelEvent(track!, 0, &chMsg)
        if status != noErr {
            print("creating bank select event \(status)")
        }
        
        // program change. first data byte is the patch, the second data byte is unused for program change messages.
        let instNumber = 0
        chMsg = MIDIChannelMessage(status: 0xC0, data1: UInt8(instNumber), data2: 0, reserved: 0)
        status = MusicTrackNewMIDIChannelEvent(track!, 0, &chMsg)
        if status != noErr {
            print("creating program change event \(status)")
        }
        
        var msg = MIDINoteMessage(channel: 0,
                                  note: UInt8(semitone),
                                  velocity: 96,
                                  releaseVelocity: 96,
                                  duration: 1000 )
        status = MusicTrackNewMIDINoteEvent(track!, 0, &msg)
        if status != noErr {
            print("error: creating new midi note event \(status)")
        }
        
        CAShow(UnsafeMutablePointer<MusicSequence>(musicSequence!))
        
        return musicSequence!
    }
}
