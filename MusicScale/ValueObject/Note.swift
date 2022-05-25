//
//  Note.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import Foundation

struct Note: Codable, Equatable, Comparable {
    
    var scale7: Music.Scale7 = .C
    var accidental: Music.Accidental = .natural
    
    var semitone: Int {
        return scale7.rawValue + accidental.rawValue
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.scale7 == rhs.scale7 && lhs.accidental == rhs.accidental
    }
    
    static func < (lhs: Note, rhs: Note) -> Bool {
        
        if lhs.scale7 == rhs.scale7 {
            return lhs.accidental.rawValue < rhs.accidental.rawValue
        }
        return lhs.scale7.rawValue < rhs.scale7.rawValue
    }
}


