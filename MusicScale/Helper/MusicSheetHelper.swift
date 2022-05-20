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

//typealias NoteNumberPair = (prefix: String, number: Int)
//typealias NoteStrPair = (prefix: String, noteStr: String)

enum DegreesOrder {
    case ascending, descending
    
    var signum: Int {
        switch self {
        case .ascending:
            return 1
        case .descending:
            return -1
        }
    }
}

struct NoteNumberPair: Codable, Equatable {
    
    init(prefix: String, number: Int) {
        self.prefix = prefix
        self.number = number
    }
    
    init(_ prefix: String, _ number: Int) {
        self.init(prefix: prefix, number: number)
    }
    
    var prefix: String
    var number: Int
    
}

struct NoteStrPair: Codable, Equatable {
    
    init(prefix: String, noteStr: String) {
        self.prefix = prefix
        self.noteStr = noteStr
    }
    
    init(_ prefix: String, _ noteStr: String) {
        self.init(prefix: prefix, noteStr: noteStr)
    }
    
    var prefix: String
    var noteStr: String
}

struct MusicSheetHelper {
    
    enum IntervalError: String, Error {
        case notCalculable = "계산 불가"
        case numberIsInvalidate = "interval의 number는 1~8까지"
        case wrongPairPrefix = "Prefix of pair 잘못됨"
    }
    
    enum DegreesError: String, Error {
        case malformedDegrees = "Degree is malformed."
    }
        
    private func degreesToNoteNumberPair(degrees: String, order: DegreesOrder, completeFinalNote: Bool = true, key: Music.Key = .C, octaveShift: Int = 0) -> [NoteNumberPair] {
        
        let degreeComponents = degrees.components(separatedBy: " ")
        
        let onlyNumberRegex = "^[1234567]$"
        let hasPrefixRegex = "^[♭b#♯♮=][1234567]$"
        let hasBracketedPrefixRegex = "^\\([♭b#♯♮=]\\)[1234567]$"
        
        let hasSharpAndFlatPrefixRegex = "^[♭b#♯][1234567]$"
        let hasSharpAndFlatBracketedPrefixRegex = "^\\([♭b#♯]\\)[1234567]$"
        
        var result = degreeComponents.enumerated().withPreviousAndNext.compactMap { values -> NoteNumberPair? in
            
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
                        return NoteNumberPair("=", number)
                    }
                    
                    if isPrevHasBracketPrefix && isPrevAndCurrSameNumber2 {
                        return NoteNumberPair("=", number)
                    }
                }
                
                return NoteNumberPair("", number)
                
            } else if hasPrefix != nil {
                let number = Int(str[1])!
                switch str[0] {
                case "♭", "b":
                    return NoteNumberPair("_", number)
                case "♯", "#":
                    return NoteNumberPair("^", number)
                case "♮", "=":
                    return NoteNumberPair("=", number)
                default:
                    break
                }
            } else if hasBracketedPrefix != nil {
                let removedBracketStr = str.replacingOccurrences(of: "[\\(\\)]", with: "", options: .regularExpression)
                let number = Int(removedBracketStr[1])!
                switch removedBracketStr[0] {
                case "♭", "b":
                    return NoteNumberPair("_", number)
                case "♯", "#":
                    return NoteNumberPair("^", number)
                case "♮", "=":
                    return NoteNumberPair("=", number)
                default:
                    break
                }
            }
            
            return NoteNumberPair("", -99)
        }
        
        if completeFinalNote && order == .ascending {
            let finalNotePair = NoteNumberPair(result[0].prefix, result[0].number + 7)
            result += [finalNotePair]
        } else if completeFinalNote && order == .descending {
            if let lastNotePair = result.last {
                let toFirstNotePair = NoteNumberPair(lastNotePair.prefix, lastNotePair.number + 7)
                result.insert(toFirstNotePair, at: 0)
            }
        }
        
        if key == .C && octaveShift == 0 {
            return result
        } else if key == .C && octaveShift != 0 {
            return result.map { (pair: NoteNumberPair) -> NoteNumberPair in
                let newNumber = pair.number + (octaveShift * 7)
                return NoteNumberPair(pair.prefix, newNumber)
            }
        } else if key != .C && octaveShift == 0 {
            do {
                return try getTransposedNoteNumberPairsUseInterval(pairs: result, interval: key.intervalFromC)
            } catch {
                print(error)
            }
        } else if octaveShift != 0 {
            do {
                let transposed = try getTransposedNoteNumberPairsUseInterval(pairs: result, interval: key.intervalFromC)
                return transposed.map { (pair: NoteNumberPair) -> NoteNumberPair in
                    let newNumber = pair.number + (octaveShift * 7)
                    return NoteNumberPair(pair.prefix, newNumber)
                }
            } catch {
                print(error)
            }
        }
        
        return result
    }
    
    private func getTransposedNoteNumberPairsUseInterval(pairs: [NoteNumberPair], interval: Music.Interval) throws -> [NoteNumberPair] {
        return try pairs.map { pair in
            return try getAboveIntervalNoteFrom(pair: pair, interval: interval)
        }
    }
    
    private func degreesToNoteStrPair(degrees: String, order: DegreesOrder, completeFinalNote: Bool = true, key: Music.Key = .C, octaveShift: Int = 0) -> [NoteStrPair] {
        
        // 옥타브 올리기 (C'), 옥타브 내리기(C,)
        
        let noteNumPairs = degreesToNoteNumberPair(degrees: degrees, order: order, completeFinalNote: completeFinalNote, key: key, octaveShift: octaveShift)
        
        let compactedStrPair = noteNumPairs.enumerated().withPreviousAndNext.compactMap { values -> NoteStrPair? in
            let (prev, curr, _) = values
            let pair = curr.element
            
            let numberInFirstOctave = (pair.number - 1) % 7
            let octave = Int(floor(Double(pair.number - 1) / 7.0))
            let scaleIndex = numberInFirstOctave.signum() >= 0 ? numberInFirstOctave : 7 + numberInFirstOctave
            let noteScale = Music.Scale7.getScaleByCaseIndex(scaleIndex)!
            
            let pairPrefix: String = {
                
                if curr.offset == 0 && pair.prefix == "=" {
                    return ""
                }
                
                // 기본적으로 natural(=)은 표시하지 않는다.
                // 단, 이전 노트가 동일한 높이(number)이고, accidental이 붙어있다면 natural 기호를 붙인다.
                if let prevPair = prev?.element {
                    let prevPrefixIsAccidental = prevPair.prefix.range(of: "^[\\^_]*$", options: .regularExpression) != nil
                    let currPrefixIsNatural = pair.prefix == "" || pair.prefix == "="
                    
                    if prevPair.number != pair.number && pair.prefix == "=" {
                        return ""
                    } else if prevPair.number == pair.number && prevPrefixIsAccidental && currPrefixIsNatural {
                        return "="
                    }
                }
                
                return pair.prefix
            }()
            
            let notePostfix: String = {
                
                if octave == 0 {
                    return ""
                } else if octave >= 1 {
                    return String(repeating: "'", count: octave)
                } else if octave <= 1 {
                    return String(repeating: ",", count: abs(octave))
                } else {
                    return ""
                }
            }()
            
            return NoteStrPair(prefix: pairPrefix, noteStr: "\(noteScale)\(notePostfix)")
        }
        
        return compactedStrPair
    }
    
    func degreesToAbcjsPart(degrees: String, order: DegreesOrder, completeFinalNote: Bool = true, key: Music.Key = .C, octaveShift: Int = 0) -> String {
        
        // sharp: ^A, flat: _A, natural =A
        // CDEFGAB cde...
        
        // TODO: degreesToNoteStrPair 중복 안되게
        let pairs = degreesToNoteStrPair(degrees: degrees, order: order, completeFinalNote: completeFinalNote, key: key, octaveShift: octaveShift)
        return pairs.map { $0.prefix + $0.noteStr }.joined(separator: " ")
    }
    
    func degreesToAbcjsLyric(degrees: String, order: DegreesOrder, completeFinalNote: Bool = true, key: Music.Key = .C) -> String {
        
        // TODO: degreesToNoteStrPair 중복 안되게
        let pairs = degreesToNoteStrPair(degrees: degrees, order: order, completeFinalNote: completeFinalNote, key: key)
        return pairs.map { pair in
            let noteStr = pair.noteStr.uppercased().replacingOccurrences(of: "[\\'\\,]", with: "", options: .regularExpression)
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
    
    func scaleInfoToAbcjsText(scaleInfo: ScaleInfo, order: DegreesOrder = .ascending, key: Music.Key = .C, tempo: Double = 120, octaveShift: Int = 0) -> String {
        
        let targetDegrees = getTargetDegrees(scaleInfo: scaleInfo, order: order)
        
        let text = """
                X: 1
                T:
                V: T1 clef=treble
                L: 1/1
                R: \(key.textValue) \(scaleInfo.name)
                Q: 1/1=\(tempo)
                K: C
                \(degreesToAbcjsPart(degrees: targetDegrees, order: order, completeFinalNote: true, key: key, octaveShift: octaveShift)) |
                w: \(degreesToAbcjsLyric(degrees: targetDegrees, order: order, completeFinalNote: true, key: key))
                """
        return text
    }
    
    func getIntervalOfTwoNumPair(leftPair: NoteNumberPair, rightPair: NoteNumberPair) -> Int {
       
        //  1,  2,  3,  4,  5,  6,  7
        //  8,  9, 10, 11, 12, 13, 14
        // 15, 16, 17, 18, 19, 20, 21
        
        var leftInteger = leftPair.number * 2
        var rightInteger = rightPair.number * 2
        
        switch leftPair.prefix {
        case "_":
            leftInteger -= 1
        case "^":
            leftInteger += 1
        default:
            break
        }
        
        switch rightPair.prefix {
        case "_":
            rightInteger -= 1
        case "^":
            rightInteger += 1
        default:
            break
        }

        let numbers = [leftPair.number, rightPair.number].sorted()
        let numRange = numbers[0]...numbers[1]
        
        let totalHalfCount = numRange.enumerated().reduce(0) { partialResults, values in
            
            let (index, num) = values
            
            if index == 0 {
                return partialResults
            }
            
            let currentNumMod7 = num % 7
            if (currentNumMod7 == 4 || currentNumMod7 == 1) {
                return partialResults + 1
            }
            
            return partialResults
        }
        
        return (rightInteger - leftInteger) - (leftInteger <= rightInteger ? totalHalfCount : -totalHalfCount)
    }

    
    func getIntegerNotation(degrees: String, order: DegreesOrder, completeFinalNote: Bool = false) -> [Int] {
        
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
        
        
        let noteNumPairs = degreesToNoteNumberPair(degrees: degrees, order: order, completeFinalNote: completeFinalNote)
//        print(#function, noteNumPairs, degrees)
        return noteNumPairs.enumerated().withPreviousAndNext.reduce(into: [Int]()) { partialResult, values in
            let (prev, curr, _) = values
            
            if curr.offset == 0 {
                partialResult.append(0)
            }
            
            if let prevPair = prev?.element {
                let interval = order == .ascending ?
                getIntervalOfTwoNumPair(leftPair: prevPair, rightPair: curr.element) :
                getIntervalOfTwoNumPair(leftPair: curr.element, rightPair: prevPair)
                
                let lastInteger = partialResult.last!
                let adjustInterval = order == .ascending ? interval : -interval
                partialResult.append(lastInteger + adjustInterval)
            }
        }
    }
    
    func getTargetDegrees(scaleInfo: ScaleInfo, order: DegreesOrder) -> String {
        
        if order == .descending && scaleInfo.degreesDescending != "" {
            return scaleInfo.degreesDescending
        } else if order == .descending && scaleInfo.degreesDescending == "" {
            return scaleInfo.degreesAscending.components(separatedBy: " ").reversed().joined(separator: " ")
        }
        
        return scaleInfo.degreesAscending
    }
    
    func getSemitoneToPlaybackNotes(scaleInfo: ScaleInfo, order: DegreesOrder, key: Music.Key, octaveShift: Int = 0) -> [Int] {
        
        let targetDegrees = getTargetDegrees(scaleInfo: scaleInfo, order: order)
        
        let integerNotation = getIntegerNotation(degrees: targetDegrees, order: order, completeFinalNote: true)
        let startSemitone = order.signum == 1 ? key.playableKey.rawValue : key.playableKey.rawValue + 12
        
        let result = integerNotation.map { ($0 + startSemitone) + (octaveShift * 12) }
        return result
    }
    
    func getPattern(degrees: String) throws -> [Int] {
        
        let integerNotation = getIntegerNotation(degrees: degrees, order: .ascending, completeFinalNote: true)
        
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
    
    func getCountOfHalfStep(pairNum: Int, intervalNum: Int) -> Int {
        
        let resultNumber = (pairNum - 1) + intervalNum
        
        if pairNum == resultNumber {
            return 0
        }
        
        guard pairNum <= resultNumber else {
            return -99
        }
        
        // 반음 갯수 구하기
        // 4, 8, 11, 15, 18, 22...
        // 1, 2,  3,  4,  5,  6...
        
        let numRange = pairNum...resultNumber
        return numRange.enumerated().reduce(0) { partialResults, values in
            
            let (index, num) = values
            
            if index == 0 {
                return partialResults
            }
            
            let currentNumMod7 = num % 7
            if (currentNumMod7 == 4 || currentNumMod7 == 1) {
                return partialResults + 1
            }
            
            return partialResults
        }
    }
    
    /// 음정 입력하면 해당 음정보다 위에 있는 노트 계산
    func getAboveIntervalNoteFrom(pair: NoteNumberPair, interval: Music.Interval) throws -> NoteNumberPair {
        
        /*
         C - C : 완전 1도
         C - C# : 증 1도
         C - Db : 단 2도
         C - D :  장 2도
         C - D# : 증 2도
         C - Eb : 단 3도
         C - E : 장 3도
         C - F : 완전 4도
         C - F# : 증 4도
         C - Gb : 감 5도
         C - G : 완전 5도
         C - G# : 증 5도
         C - Ab : 단 6도
         C - A : 장 6도
         C - A# : 증 6도
         C - Bb : 단 7도
         C - B: 장 7도
         
         1) x도 만큼 음을 올린다. (반음 포함여부 무관)
         예) 3도: C -> E, E - G, G -> B
         
         2) 장음정
         2-1) 장 3도 이하이고, 두 음 사이에 반음이 없다면, prefix는 그대로 따라간다.
         예) C# -> E#, Gb -> Bb, G -> B
         
         2-2) 장 3도 이하이고, 두 음 사이에 반음이 한 개 있다면 (3-4 또는 7-8), 원래 음에서 반음이 높아진다(=prefix가 1단계 높아진다).
         예) E -> G는 E -> G#, Eb -> G는 Eb -> G(=), C -> A
         
         2-3) 장 6 ~ 7도이고, 두 음 사이에 반음이 한 개 있다면 prefix는 그대로 따라간다.
         예) C -> A, Db -> Bb, G# -> E#
         
         2-4) 장 6 ~ 7도이고, 두 음 사이에 반음이 두 개 있다면, 원래 음에서 반음이 높아진다(=prefix가 1단계 높아진다).
         예) E -> C# (EF, BC), A -> F# (BC, EF), Bb -> G (BC, EF)
         
         3) 단음정
         장음정을 기준으로 먼저 계산한 뒤, 반음 내린다(=prefix는 1단계 낮아진다).
         예1) C -> Eb (단 3도, from E), Eb -> Gb (단 3도, from G), Gb -> Bbb (from Bb), F# -> A (단 3도, from A#)
         예2) E -> C (from C#), Db -> Bbb (from Bb), Bb -> Ab (from A)
         
         4) 완전음정
         4-1) 완전음정 4, 5도 사이에 반음이 한 개 있다면, prefix는 그대로 따라간다.
         예) C -> F (EF), Eb -> Ab (EF), Bb -> Eb (BC)
         
         4-2) 완전음정 4, 5도 사이에 반음이 한 개 있다면, 반음씩 올리면 된다(=prefix가 1단계 높아진다).
         예) Bb -> F (BC, EF)
         
         4-3) 완전음정 4, 5도 사이에 반음이 하나도 없다면, 원래 음에서 반음이 낮아진다(=prefix는 1단계 낮아진다).
         참고) 이 케이스는 F밖에 존재할 수밖에 없다.
         예) F -> Bb, F# -> B, Fb -> Fbb
         
         5) 증음정
         장음정 또는 완전음정을 기준으로 먼저 계산한 뒤, 반음씩 올리면 된다(=prefix가 1단계 높아진다).
         예) C -> C# (증 1도, from C), E -> F## (증 2도, from F#)
         
         6) 감음정
         감 5도만 있음 (겹증, 겹감, 감 4도(=장 3도) 제외)
         완전 5도에서 반음 내린다(=prefix는 1단계 낮아진다).
         예) Eb -> Bbb (from Bb), F# -> C (from C#)
         
         */
        
        if interval.quality == .perfect && interval.number == 1 {
            return pair
        }
        
        guard interval.number >= 1 && interval.number <= 8 else {
            throw IntervalError.numberIsInvalidate
        }
        
        let perfect = [1, 4, 5, 8]
        let prefixList = ["__", "_", "=", "^", "^^"]
        
        let resultNumber = (pair.number - 1) + interval.number
        
//        let totalHalfCount = (numberDiv7 >= 4 && numberDiv7 <= 6) ? 1 : (numberDiv7 >= 7) ? 2 : 0
        let totalHalfCount = getCountOfHalfStep(pairNum: pair.number, intervalNum: interval.number)
        
        let currentPairPrefix = pair.prefix == "" ? "=" : pair.prefix
        guard let pairPrefixIndex = prefixList.firstIndex(of: currentPairPrefix), pairPrefixIndex >= 1 else {
            throw IntervalError.wrongPairPrefix
        }
        
        var basePrefixIndex: Int {
            
            if perfect.contains(interval.number) {
                if interval.number == 1 || interval.number == 8 {
                    return pairPrefixIndex
                }
                
                return pairPrefixIndex + (totalHalfCount - 1)
//                return totalHalfCount == 1 ? pairPrefixIndex : pairPrefixIndex - 1
                
            } else {
                if interval.number <= 3 {
                    return totalHalfCount == 0 ? pairPrefixIndex : pairPrefixIndex + 1
                } else {
                    return totalHalfCount == 1 ? pairPrefixIndex : pairPrefixIndex + 1
                }
            }
        }
//        print(interval, basePrefixIndex, prefixList[basePrefixIndex], totalHalfCount)
        
        switch interval.quality {
        case .perfect, .major:
            return NoteNumberPair(prefixList[basePrefixIndex], resultNumber)
        case .diminished, .minor:
            let resultPrefix = prefixList[basePrefixIndex - 1]
            return NoteNumberPair(resultPrefix, resultNumber)
        case .augmented:
            let resultPrefix = prefixList[basePrefixIndex + 1]
            return NoteNumberPair(resultPrefix, resultNumber)
        
        }
    }
}
