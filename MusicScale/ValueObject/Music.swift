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
    
    private var strComponents: [String] { self.rawValue.components(separatedBy: "_") }
    private var tradScales: [String] { ["C", "D", "E", "F", "G", "A", "B"] }
    
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
    
    var distanceFromC: Int {
      switch self {
      case .C:
        return 0
      case .C_sharp, .D_flat:
        return 1
      case .D:
        return 2
      case .D_sharp, .E_flat:
        return 3
      case .E:
        return 4
      case .F:
        return 5
      case .F_sharp, .G_flat:
        return 6
      case .G:
        return 7
      case .G_sharp, .A_flat:
        return 8
      case .A:
        return 9
      case .A_sharp, .B_flat:
        return 10
      case .B:
        return 11
      }
    }
    
    var noteValue: String { strComponents[0] }
    
    var accidentalValue: String {
      if self.rawValue.count == 1 {
        return "natural"
      }
      
      return strComponents[1]
    }
    
    var enharmonicKey: Key {
      if self.rawValue.count == 1 {
        return self
      }
      
      let accidental = accidentalValue
      let index = tradScales.firstIndex(of: noteValue)! + (accidental == "sharp" ? 1 : -1)
      let newAccidental = accidental == "sharp" ? "flat" : "sharp"
      return Key(rawValue: "\(tradScales[index])_\(newAccidental)")!
    }
    
    var accidental: Music.Accidental {
      
      switch accidentalValue {
      case "natural": return .natural
      case "sharp": return .sharp
      case "flat": return .flat
      default: return .natural
      }
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
      
      let accidental = accidentalValue == "sharp" ? xSharp : xFlat
      return noteValue + accidental
    }
    
    private var musiqwikNotePart: String {
      let noteIndex: Int = 114 + tradScales.firstIndex(of: noteValue)!
      return String(UnicodeScalar(noteIndex)!)
    }
    
    var musiqwikValueWithNatural: String {
      let naturalIndex: Int = 242 + tradScales.firstIndex(of: noteValue)!
      return String(UnicodeScalar(naturalIndex)!) + musiqwikNotePart
    }
    
    var musiqwikValue: String {
      if self.rawValue.count == 1 {
        return "=\(musiqwikNotePart)"
      }
      
      let accidentalStartIndex = accidentalValue == "sharp" ? 210 : 226
      let noteIndex = tradScales.firstIndex(of: noteValue)!
      let accidentalPart = String(UnicodeScalar(accidentalStartIndex + noteIndex)!)
      return accidentalPart + musiqwikNotePart
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
    
    var strPair: NoteStrPair {
      var prefix: String!
      switch accidentalValue {
      case "natural":
        prefix = ""
      case "sharp":
        prefix = "^"
      case "flat":
        prefix = "_"
      default:
        break
      }
      
      return NoteStrPair(prefix, noteValue)
    }
    
    var startNote: Note {
      let scale7 = Scale7.getScaleByNoteName(self.rawValue)!
      return Note(scale7: scale7, accidental: self.accidental)
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
    
    var textValue: String {
      switch self {
      case .C:
        return "C"
      case .D:
        return "D"
      case .E:
        return "E"
      case .F:
        return "F"
      case .G:
        return "G"
      case .A:
        return "A"
      case .B:
        return "B"
      }
    }
    
    static func getScaleByCaseIndex(_ index: Int) -> Scale7? {
      
      guard index >= 0 && index <= self.allCases.count - 1 else {
        return nil
      }
      
      return self.allCases[index]
    }
    
    static func getScaleByNoteName(_ name: String) -> Scale7? {
      
      guard let first = name.first?.uppercased() else {
        return nil
      }
      
      switch first {
      case "C": return .C
      case "D": return .D
      case "E": return .E
      case "F": return .F
      case "G": return .G
      case "A": return .A
      case "B": return .B
      default: return nil
      }
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
    
    var abcjsPrefix: String {
      switch self {
      case .sharp:
        return "^"
      case .doubleSharp:
        return "^^"
      case .flat:
        return "_"
      case .doubleFlat:
        return "__"
      case .natural:
        return "="
      }
    }
    
    static func findAccidental(from abcjsText: String) -> Accidental? {
      switch abcjsText {
      case "^":
        return .sharp
      case "^^":
        return .doubleSharp
      case "_":
        return flat
      case "__":
        return .doubleFlat
      case "=", "":
        return .natural
      default:
        return nil
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
    
    var keyInputToBlackKeyMapper: String {
      switch self {
      case .C, .C_sharp:
        "sdghjl"
      case .D, .D_sharp:
        "asfghkl"
      case .E:
        "adfgjk"
      case .F, .F_sharp:
        "sdfhjl"
      case .G, .G_sharp:
        "asdghkl"
      case .A, .A_sharp:
        "asfgjkl"
      case .B:
        "adfhjk"
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
