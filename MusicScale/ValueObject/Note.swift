//
//  Note.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import Foundation

struct Note: Codable, Equatable, Comparable {
    
    var scale7: Music.Scale7 = .C
    var pitchShift: Music.PitchShift = .natural
    
    var semitone: Int {
        return scale7.rawValue + pitchShift.rawValue
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.scale7 == rhs.scale7 && lhs.pitchShift == rhs.pitchShift
    }
    
    static func < (lhs: Note, rhs: Note) -> Bool {
        
        if lhs.scale7 == rhs.scale7 {
            return lhs.pitchShift.rawValue < rhs.pitchShift.rawValue
        }
        return lhs.scale7.rawValue < rhs.scale7.rawValue
    }
}


