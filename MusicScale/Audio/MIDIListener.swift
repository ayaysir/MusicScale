//
//  MIDIListener.swift
//  MusicScale
//
//  Created by 윤범태 on 2023/09/09.
//

import AudioKit
import CoreMIDI

class MIDIListener: ObservableObject {
    private let midi = MIDI.sharedInstance
    private let generator = MIDISoundGenerator()
    
    private let isUseGenerator: Bool
    
    typealias NoteHandler = ((Int) -> Void)

    var noteOnHandler: NoteHandler?
    var noteOffHandler: NoteHandler?
    
    @Published var isDeviceConnected = false
    
    init(useGenerator: Bool = true) {
        self.isUseGenerator = useGenerator
        openMIDI()
    }
    
    func openMIDI() {
        midi.openInput(name: "Bluetooth")
        midi.openInput()
        midi.addListener(self)
        
        if self.isUseGenerator {
            generator.initEngine()
        }
    }
    
    deinit {
        if isUseGenerator {
            generator.stopEngine()
        }
    }
}

extension MIDIListener: AudioKit.MIDIListener {
    func receivedMIDINoteOn(noteNumber: AudioKit.MIDINoteNumber, velocity: AudioKit.MIDIVelocity, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        if isUseGenerator {
            generator.playSimply(noteNumber: noteNumber)
        }
        noteOnHandler?(Int(noteNumber))
    }
    
    func receivedMIDINoteOff(noteNumber: AudioKit.MIDINoteNumber, velocity: AudioKit.MIDIVelocity, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        if isUseGenerator {
            generator.stopSimply(noteNumber: noteNumber)
        }
        noteOffHandler?(Int(noteNumber))
    }
    
    func receivedMIDIController(_ controller: AudioKit.MIDIByte, value: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        print(#function)
    }
    
    func receivedMIDIAftertouch(noteNumber: AudioKit.MIDINoteNumber, pressure: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        //
    }
    
    func receivedMIDIAftertouch(_ pressure: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        //
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: AudioKit.MIDIWord, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        //
    }
    
    func receivedMIDIProgramChange(_ program: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        //
    }
    
    func receivedMIDISystemCommand(_ data: [AudioKit.MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        //
    }
    
    func receivedMIDISetupChange() {
        // 연결된 미디 장치가 한 개 이상 있을 때, openInput하면 중간에 꽂아도 연주됨
        // 중복 인풋을 방지하기 위해 먼저 closeAllInputs부터
        midi.closeAllInputs()
        if !midi.inputInfos.isEmpty {
            midi.openInput()
            midi.openInput(name: "Bluetooth")
        }
    }
    
    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        //
    }
    
    func receivedMIDINotification(notification: MIDINotification) {
        //
    }
}
