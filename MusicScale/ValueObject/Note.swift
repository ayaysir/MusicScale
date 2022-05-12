//
//  Note.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import Foundation

struct Music: Codable {
    
    enum Scale7: Int, Codable {
        case C = 0, D = 2, E = 4, F = 5, G = 7, A = 9, B = 11
    }
    
    enum PitchShift: Int, Codable {
        case sharp = 1, doubleSharp = 2, flat = -1, doubleFlat = -2, natural = 0
    }
    
    enum PlayableKey: Int, Codable, CaseCountable {
        case C, C_sharp, D, D_sharp, E, F, F_sharp, G, G_sharp, A, A_sharp, B
        
        var textValueForSharp: String {
            switch self {
            case .C: return "C"
            case .C_sharp: return "C#"
            case .D: return "D"
            case .D_sharp: return "D♯"
            case .E: return "E"
            case .F: return "F"
            case .F_sharp: return "F♯"
            case .G: return "G"
            case .G_sharp: return "G♯"
            case .A: return "A"
            case .A_sharp: return "A♯"
            case .B: return "B"
            }
        }
        
        var textValueForFlat: String {
            switch self {
            case .C: return "C"
            case .C_sharp: return "D♭"
            case .D: return "D"
            case .D_sharp: return "E♭"
            case .E: return "E"
            case .F: return "F"
            case .F_sharp: return "G♭"
            case .G: return "G"
            case .G_sharp: return "A♭"
            case .A: return "A"
            case .A_sharp: return "B♭"
            case .B: return "B"
            }
        }
        
        var textValueMixed: String {
            switch self {
            case .C: return "C"
            case .C_sharp: return "C# / D♭"
            case .D: return "D"
            case .D_sharp: return "D♯ / E♭"
            case .E: return "E"
            case .F: return "F"
            case .F_sharp: return "F♯ / G♭"
            case .G: return "G"
            case .G_sharp: return "G♯ / A♭"
            case .A: return "A"
            case .A_sharp: return "A♯ / B♭"
            case .B: return "B"
            }
        }
    }
}

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


