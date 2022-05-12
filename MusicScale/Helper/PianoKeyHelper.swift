//
//  PianoKeyHelper.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/13.
//

import Foundation

struct PianoKeyHelper {
    
    static func adjustKeyPosition(key: Music.PlayableKey) -> Int {
        
        switch key {
        case .C:
            return 0
        case .C_sharp:
            return 0
        case .D:
            return -1
        case .D_sharp:
            return -1
        case .E:
            return -2
        case .F:
            return -3
        case .F_sharp:
            return -3
        case .G:
            return -4
        case .G_sharp:
            return -4
        case .A:
            return -5
        case .A_sharp:
            return -5
        case .B:
            return -6
        }
    }
    
}
