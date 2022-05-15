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
    
    static func degreesToAbcjsPart(degrees: String) -> String {
        
        // sharp: ^A, flat: _A, natural =A
        // CDEFGAB cde...
        let key = ["C", "D", "E", "F", "G", "A", "B"]
//        let aeolianDegrees = "1 2 ♭3 4 5 ♭6 ♭7 1 2 ♭3 4 5 ♭6 (♮)7 1 ♯1 2 ♯2 3 4 ♯4 5 ♯5 6 ♯6 7"
        let degreeComponents = degrees.components(separatedBy: " ")
        
        let onlyNumberRegex = "^[1234567]$"
        let hasPrefixRegex = "^[♭b#♯♮=][1234567]$"
        let hasBracketedPrefixRegex = "^\\([♭b#♯♮=]\\)[1234567]$"

        let result: [String] = degreeComponents.map { str in
            let onlyNumber = str.range(of: onlyNumberRegex, options: .regularExpression)
            let hasPrefix = str.range(of: hasPrefixRegex, options: .regularExpression)
            let hasBracketedPrefix = str.range(of: hasBracketedPrefixRegex, options: .regularExpression)
            
            if onlyNumber != nil {
                return key[Int(str)! - 1]
            } else if hasPrefix != nil {
                let note = key[Int(str[1])! - 1]
                switch str[0] {
                case "♭", "b":
                    return "_\(note)"
                case "♯", "#":
                    return "^\(note)"
                case "♮", "=":
                    return "=\(note)"
                default:
                    break
                }
            } else if hasBracketedPrefix != nil {
                let removedBracketStr = str.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                let note = key[Int(removedBracketStr[1])! - 1]
                switch removedBracketStr[0] {
                case "♭", "b":
                    return "_\(note)"
                case "♯", "#":
                    return "^\(note)"
                case "♮", "=":
                    return "=\(note)"
                default:
                    break
                }
            }
            
            return ""
        }
        
        return result.joined(separator: " ")
    }
}
