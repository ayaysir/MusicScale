//
//  AvailableSoundInSilentMode.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/10.
//

import AVFoundation

func availableSoundInSilentMode(_ isOn: Bool = true) throws {
    if isOn {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
    } else {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(false)
    }
}
