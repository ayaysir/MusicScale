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

typealias NoteNumberPair = (prefix: String, number: Int)
typealias NoteStrPair = (prefix: String, noteStr: String)

struct MusicSheetHelper {
    
    enum IntervalError: String, Error {
        case notCalculable = "계산 불가"
    }
    
    enum DegreesError: String, Error {
        case malformedDegrees = "Degree is malformed."
    }
        
    private func degreesToNoteNumberPair(degrees: String, completeFinalNote: Bool = true) -> [NoteNumberPair] {
        
//        let key = ["C", "D", "E", "F", "G", "A", "B"]
        let degreeComponents = degrees.components(separatedBy: " ")
        
        let onlyNumberRegex = "^[1234567]$"
        let hasPrefixRegex = "^[♭b#♯♮=][1234567]$"
        let hasBracketedPrefixRegex = "^\\([♭b#♯♮=]\\)[1234567]$"
        
        let hasSharpAndFlatPrefixRegex = "^[♭b#♯][1234567]$"
        let hasSharpAndFlatBracketedPrefixRegex = "^\\([♭b#♯]\\)[1234567]$"
        
        let result = degreeComponents.enumerated().withPreviousAndNext.compactMap { values -> NoteNumberPair? in
            
            let (prev, curr, _) = values
            let str = curr.element
            
            let onlyNumber = str.range(of: onlyNumberRegex, options: .regularExpression)
            let hasPrefix = str.range(of: hasPrefixRegex, options: .regularExpression)
            let hasBracketedPrefix = str.range(of: hasBracketedPrefixRegex, options: .regularExpression)
            
            if onlyNumber != nil {
                
                let number = Int(str)!
                
                if let prevElement = prev?.element {
                    
                    let isPrevHasPrefix = (prevElement.range(of: hasSharpAndFlatPrefixRegex, options: .regularExpression)) != nil
                    let isPrevAndCurrSameNumber1 = prevElement[1] == str
                    
                    let isPrevHasBracketPrefix = (prevElement.range(of: hasSharpAndFlatBracketedPrefixRegex, options: .regularExpression)) != nil
                    let removeBracketStrOfPrev = prevElement.replacingOccurrences(of: "[\\(\\)]", with: "", options: .regularExpression)
                    let isPrevAndCurrSameNumber2 = removeBracketStrOfPrev[1] == str
                    
                    if isPrevHasPrefix && isPrevAndCurrSameNumber1 {
                        return ("=", number)
                    }
                    
                    if isPrevHasBracketPrefix && isPrevAndCurrSameNumber2 {
                        return ("=", number)
                    }
                }
                
                return ("", number)
                
            } else if hasPrefix != nil {
                let number = Int(str[1])!
                switch str[0] {
                case "♭", "b":
                    return ("_", number)
                case "♯", "#":
                    return ("^", number)
                case "♮", "=":
                    return ("=", number)
                default:
                    break
                }
            } else if hasBracketedPrefix != nil {
                let removedBracketStr = str.replacingOccurrences(of: "[\\(\\)]", with: "", options: .regularExpression)
                let number = Int(removedBracketStr[1])!
                switch removedBracketStr[0] {
                case "♭", "b":
                    return ("_", number)
                case "♯", "#":
                    return ("^", number)
                case "♮", "=":
                    return ("=", number)
                default:
                    break
                }
            }
            
            return ("", -99)
        }
        
        if completeFinalNote {
            let finalNotePair = (result[0].prefix, result[0].number + 7)
            return result + [finalNotePair]
        }
        return result
    }
    
    private func degreesToNoteStrPair(degrees: String, completeFinalNote: Bool = true) -> [NoteStrPair] {
        
        let key = ["C", "D", "E", "F", "G", "A", "B", "c", "d", "e", "f", "g", "a", "b"]
        
        let noteNumPairs = degreesToNoteNumberPair(degrees: degrees, completeFinalNote: completeFinalNote)
        return noteNumPairs.enumerated().map { (index, value) -> NoteStrPair in
            
            if index == noteNumPairs.count - 1 && completeFinalNote {
                return (prefix: value.prefix, noteStr: key[7])
            }
            
            return (prefix: value.prefix, noteStr: key[value.number - 1])
        }
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
    
    func getIntervalOfAscendingTwoNumPair(leftPair: NoteNumberPair, rightPair: NoteNumberPair) throws -> Int {
        
        guard leftPair.number <= rightPair.number else {
            throw IntervalError.notCalculable
        }
        
        var leftInteger: Int!
        var rightInteger: Int!
        
        //  1,  2,  3,  4,  5,  6,  7
        //  8,  9, 10, 11, 12, 13, 14
        // 15, 16, 17, 18, 19, 20, 21
        
        leftInteger = leftPair.number * 2
        if leftPair.number % 7 >= 4 {
            leftInteger -= 1
        }
        
        switch leftPair.prefix {
        case "_":
            leftInteger -= 1
        case "^":
            leftInteger += 1
        default:
            break
        }
        
        rightInteger = rightPair.number * 2
        if rightPair.number >= 4 {
            rightInteger -= 1
        }
        
        switch rightPair.prefix {
        case "_":
            rightInteger -= 1
        case "^":
            rightInteger += 1
        default:
            break
        }
        
        guard rightInteger - leftInteger >= 0 else {
            throw IntervalError.notCalculable
        }
        
        return rightInteger - leftInteger
    }
    
    func getIntegerNotationOfAscending(degrees: String, completeFinalNote: Bool = false) throws -> [Int] {
        
        /*
          1  2  ♭3  4  5  ♭6  ♭7
           +2 +1  +2 +2 +1  +2
         (0,2,3,5,7,8,10)
         
         1   3   ♯4  5   7
           +4  +2  -1  +4
         (0,4,6,7,11)
         
         1  2  3   5   6
          +2 +2  +3  +2
         (0,2,4,7,9)
         
         3~4 는 반음
         */
        
        
        let noteNumPairs = degreesToNoteNumberPair(degrees: degrees, completeFinalNote: completeFinalNote)
        return try noteNumPairs.enumerated().withPreviousAndNext.reduce(into: [Int]()) { partialResult, values in
            let (prev, curr, _) = values
            
            if curr.offset == 0 {
                partialResult.append(0)
            }
            
            if let prevPair = prev?.element {
                do {
                    let interval = try getIntervalOfAscendingTwoNumPair(leftPair: prevPair, rightPair: curr.element)
                    let lastInteger = partialResult.last!
                    partialResult.append(lastInteger + interval)
                } catch {
                    throw DegreesError.malformedDegrees
                }
            }
        }
    }
    
    func getPattern(degrees: String) throws -> [Int] {
        
        let integerNotation = try getIntegerNotationOfAscending(degrees: degrees, completeFinalNote: true)
        return try integerNotation.enumerated().withPreviousAndNext.compactMap { values -> Int? in
            let (prev, curr, _) = values
            
            if curr.offset == 0 {
                return nil
            }
            
            guard let prevInteger = prev?.element else {
                throw DegreesError.malformedDegrees
            }
            
            return curr.element - prevInteger
        }
    }
}
