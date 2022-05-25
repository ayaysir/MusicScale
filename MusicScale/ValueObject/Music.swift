//
//  Music.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/16.
//

import Foundation

struct Music: Codable {
    
    enum Key: String, Codable, CaseIterable {
        
        case C
        case C_sharp, D_flat
        case D
        case D_sharp, E_flat
        case E
        case F
        case F_sharp, G_flat
        case G
        case G_sharp, A_flat
        case A
        case A_sharp, B_flat
        case B
        
        var playableKey: PlayableKey {
            
            switch self {
            case .C:
                return .C
            case .C_sharp, .D_flat:
                return .C_sharp
            case .D:
                return .D
            case .D_sharp, .E_flat:
                return .D_sharp
            case .E:
                return .E
            case .F:
                return .F
            case .F_sharp, .G_flat:
                return .F_sharp
            case .G:
                return .G
            case .G_sharp, .A_flat:
                return .G_sharp
            case .A:
                return .A
            case .A_sharp, .B_flat:
                return .A_sharp
            case .B:
                return .B
            }
        }
        
        var enharmonicKey: Key {
            if self.rawValue.count == 1 {
                return self
            }
            
            let scale7 = ["C", "D", "E", "F", "G", "A", "B"]
            
            let strComponents = self.rawValue.components(separatedBy: "_")
            let accidental = strComponents[1]
            let index = scale7.firstIndex(of: strComponents[0])! + (accidental == "sharp" ? 1 : -1)
            let newAccidental = accidental == "sharp" ? "flat" : "sharp"
            return Key(rawValue: "\(scale7[index])_\(newAccidental)")!
        }
        
        var accidentalValue: String {
            if self.rawValue.count == 1 {
                return "natural"
            }
            
            return self.rawValue.components(separatedBy: "_")[1]
        }
        
        var intervalFromC: Interval {
            switch self {
            case .C:
                return Interval(quality: .major, number: 1)
            case .C_sharp:
                return Interval(quality: .augmented, number: 1)
            case .D_flat:
                return Interval(quality: .minor, number: 2)
            case .D:
                return Interval(quality: .major, number: 2)
            case .D_sharp:
                return Interval(quality: .augmented, number: 2)
            case .E_flat:
                return Interval(quality: .minor, number: 3)
            case .E:
                return Interval(quality: .major, number: 3)
            case .F:
                return Interval(quality: .perfect, number: 4)
            case .F_sharp:
                return Interval(quality: .augmented, number: 4)
            case .G_flat:
                return Interval(quality: .diminished, number: 5)
            case .G:
                return Interval(quality: .perfect, number: 5)
            case .G_sharp:
                return Interval(quality: .augmented, number: 5)
            case .A_flat:
                return Interval(quality: .minor, number: 6)
            case .A:
                return Interval(quality: .major, number: 6)
            case .A_sharp:
                return Interval(quality: .augmented, number: 6)
            case .B_flat:
                return Interval(quality: .minor, number: 7)
            case .B:
                return Interval(quality: .major, number: 7)
            }
        }
        
        var textValue: String {
            
            if self.rawValue.count == 1 {
                return self.rawValue
            }
            
            let strComponents = self.rawValue.components(separatedBy: "_")
            let accidental = strComponents[1] == "sharp" ? xSharp : xFlat
            return strComponents[0] + accidental
        }
        
        var textValueMixed: String {
            switch self {
            case .C: return "C"
            case .C_sharp, .D_flat: return "C# / D♭"
            case .D: return "D"
            case .D_sharp, .E_flat: return "D♯ / E♭"
            case .E: return "E"
            case .F: return "F"
            case .F_sharp, .G_flat: return "F♯ / G♭"
            case .G: return "G"
            case .G_sharp, .A_flat: return "G♯ / A♭"
            case .A: return "A"
            case .A_sharp, .B_flat: return "A♯ / B♭"
            case .B: return "B"
            }
        }
        
        static var sharpKeys: [Key] {
            return self.allCases.filter { key in
                
                if key.rawValue.count == 1 {
                    return true
                }
                
                let component = key.rawValue.components(separatedBy: "_")
                if component[1] == "sharp" {
                    return true
                }
                
                return false
            }
        }
        
        
        static var flatKeys: [Key] {
            return self.allCases.filter { key in
                
                if key.rawValue.count == 1 {
                    return true
                }
                
                let component = key.rawValue.components(separatedBy: "_")
                if component[1] == "flat" {
                    return true
                }
                
                return false
            }
        }
        
        static func getKeyFromNoteStr(_ noteStr: String) -> Key? {
            
            if noteStr.count == 1 {
                return self.init(rawValue: noteStr)
            }
            
            let accidental = noteStr[1] == xSharp ? "sharp" : noteStr[1] == xFlat ? "flat" : ""
            let postfixStr = accidental == "" ? "" : "_\(accidental)"

            return self.init(rawValue: noteStr[0] + postfixStr)
        }
        
        static func getKey(index: Int) -> Key {
            return self.allCases[index]
        }
    }
    
    enum Scale7: Int, Codable, CaseIterable {
        case C = 0, D = 2, E = 4, F = 5, G = 7, A = 9, B = 11
        
        static func getScaleByCaseIndex(_ index: Int) -> Scale7? {
            
            guard index >= 0 && index <= self.allCases.count - 1 else {
                return nil
            }
            
            return self.allCases[index]
        }
    }
    
    enum Accidental: Int, Codable {
        case sharp = 1, doubleSharp = 2, flat = -1, doubleFlat = -2, natural = 0
        
        var textValue: String {
            switch self {
            case .sharp:
                return "♯"
            case .doubleSharp:
                return "𝄪"
            case .flat:
                return "♭"
            case .doubleFlat:
                return "𝄫"
            case .natural:
                return "♮"
            }
        }
    }
    
    enum PlayableKey: Int, Codable, CaseIterable, CaseCountable {
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
        
        static func getPlaybleKey(index: Int) -> PlayableKey {
            return self.allCases[index]
        }
    }
    
}

extension Music {
    
    struct Interval: Codable {
        
        enum Quality: Codable {
            case diminished, minor, major, perfect, augmented
        }
        
        var quality: Quality
        var number: Int
    }
    
}
