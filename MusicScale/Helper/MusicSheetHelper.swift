//
//  MusicSheetHelper.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import Foundation

/*
 X: 1
 T:
 V: T1 clef=treble
 L: 1/1
 R: C Aeolian
 K: C
 Q: 1/1=120
 C D _E F G _A _B c |
 w: C D E♭ F G A♭ B♭ C
 */

struct MusicSheetHelper {
    
    typealias NoteStrPair = (prefix: String, noteStr: String)
    private func degreesToNoteStrPair(degrees: String, completeFinalNote: Bool = true) -> [NoteStrPair] {
        
        let key = ["C", "D", "E", "F", "G", "A", "B"]
        let degreeComponents = degrees.components(separatedBy: " ")
        
        let onlyNumberRegex = "^[1234567]$"
        let hasPrefixRegex = "^[♭b#♯♮=][1234567]$"
        let hasBracketedPrefixRegex = "^\\([♭b#♯♮=]\\)[1234567]$"
        
        let hasSharpAndFlatPrefixRegex = "^[♭b#♯][1234567]$"
        let hasSharpAndFlatBracketedPrefixRegex = "^\\([♭b#♯]\\)[1234567]$"

        let result = degreeComponents.enumerated().withPreviousAndNext.compactMap { values -> NoteStrPair? in
            
            let (prev, curr, _) = values
            let str = curr.element
            
            let onlyNumber = str.range(of: onlyNumberRegex, options: .regularExpression)
            let hasPrefix = str.range(of: hasPrefixRegex, options: .regularExpression)
            let hasBracketedPrefix = str.range(of: hasBracketedPrefixRegex, options: .regularExpression)
            
            if onlyNumber != nil {
                
                if let prevElement = prev?.element {
                    
                    let isPrevHasPrefix = (prevElement.range(of: hasSharpAndFlatPrefixRegex, options: .regularExpression)) != nil
                    let isPrevAndCurrSameNumber1 = prevElement[1] == str
                    
                    let isPrevHasBracketPrefix = (prevElement.range(of: hasSharpAndFlatBracketedPrefixRegex, options: .regularExpression)) != nil
                    let removeBracketStrOfPrev = prevElement.replacingOccurrences(of: "[\\(\\)]", with: "", options: .regularExpression)
                    let isPrevAndCurrSameNumber2 = removeBracketStrOfPrev[1] == str
                    
                    if isPrevHasPrefix && isPrevAndCurrSameNumber1 {
                        return ("=", key[Int(str)! - 1])
                    }
                    
                    if isPrevHasBracketPrefix && isPrevAndCurrSameNumber2 {
                        return ("=", key[Int(str)! - 1])
                    }
                }
                
                return ("", key[Int(str)! - 1])
                
            } else if hasPrefix != nil {
                let note = key[Int(str[1])! - 1]
                switch str[0] {
                case "♭", "b":
                    return ("_", note)
                case "♯", "#":
                    return ("^", note)
                case "♮", "=":
                    return ("=", note)
                default:
                    break
                }
            } else if hasBracketedPrefix != nil {
                let removedBracketStr = str.replacingOccurrences(of: "[\\(\\)]", with: "", options: .regularExpression)
                let note = key[Int(removedBracketStr[1])! - 1]
                switch removedBracketStr[0] {
                case "♭", "b":
                    return ("_", note)
                case "♯", "#":
                    return ("^", note)
                case "♮", "=":
                    return ("=", note)
                default:
                    break
                }
            }
            
            return ("", "")
        }
        
        if completeFinalNote {
            let finalNotePair = (result[0].prefix, result[0].noteStr.lowercased())
            return result + [finalNotePair]
        }
        
        return result
    }
    
    func degreesToAbcjsPart(degrees: String, completeFinalNote: Bool = true) -> String {
        
        // sharp: ^A, flat: _A, natural =A
        // CDEFGAB cde...
        let pairs = degreesToNoteStrPair(degrees: degrees, completeFinalNote: completeFinalNote)
        return pairs.map { $0.prefix + $0.noteStr }.joined(separator: " ")
    }
    
    func degreesToAbcjsLyric(degrees: String, completeFinalNote: Bool = true) -> String {
        
        let pairs = degreesToNoteStrPair(degrees: degrees, completeFinalNote: completeFinalNote)
        return pairs.map { pair in
            let noteStr = pair.noteStr.uppercased()
            let postfix: String = {
                switch pair.prefix {
                case "_":
                    return "♭"
                case "^":
                    return "♯"
                case "=":
                    return "♮"
                default:
                    return ""
                }
            }()
            return noteStr + postfix
        }.joined(separator: " ")
    }
    
    func scaleInfoToAbcjsText(scaleInfo: ScaleInfo, isDesceding: Bool = false, startKey: Music.PlayableKey = .C, tempo: Int = 120) -> String {
        
        let targetDegrees = isDesceding ? scaleInfo.degreesDescending : scaleInfo.degreesAscending
        return """
                X: 1
                T:
                V: T1 clef=treble
                L: 1/1
                R: C \(scaleInfo.name)
                Q: 1/1=\(tempo)
                K: C
                \(degreesToAbcjsPart(degrees: targetDegrees)) |
                w: \(degreesToAbcjsLyric(degrees: targetDegrees))
                """
    }
}
