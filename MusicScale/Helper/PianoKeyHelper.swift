//
//  PianoKeyHelper.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/13.
//

import Foundation

struct PianoKeyHelper {
    
    static var passIndexInC: [Int] {
        
        // 3, 4, 3, 4 .....
        // -11, -7 ,-4 ,0, 3, 7, 10, 14, 17, 21
        let passIndexHalfRange = (1...PianoViewConstants.passIndexHalfRangeTo)
        
        let passIndexInC_upper = passIndexHalfRange.reduce(into: [Int]()) { partialResult, index in
            let lastElement = partialResult.last ?? 0
            partialResult.append(lastElement + (index % 2 != 0 ? 3 : 4))
        }
        let passIndexInC_lower = passIndexHalfRange.reduce(into: [Int]()) { partialResult, index in
            let lastElement = partialResult.last ?? 0
            partialResult.append(lastElement + (index % 2 != 0 ? -4 : -3))
        }
        
        return passIndexInC_lower + [0] + passIndexInC_upper
    }
    
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
    
    static func adjustKeyPosForAvaliableKeyIndexes(playableKey key: Music.PlayableKey) -> Int {
        switch key {
        case .C:
            return 0
        case .C_sharp:
            return 1
        case .D:
            return 1
        case .D_sharp:
            return 2
        case .E:
            return 1
        case .F:
            return 0
        case .F_sharp:
            return 1
        case .G:
            return 1
        case .G_sharp:
            return 2
        case .A:
            return 1
        case .A_sharp:
            return 2
        case .B:
            return 1
        }
    }
    
    static func adjustKeySemitone(key: Music.PlayableKey) -> Int {
        return adjustKeySemitone(adjustPostion: adjustKeyPosition(key: key))
    }
    
    static func adjustKeySemitone(adjustPostion: Int) -> Int {
        
        /*
         +7 -12 -14 +2
         +6 -11 -12 +1
         +5 -9 -10 +1
         +4 -7 -8 +1
         +3 -6 -6 0
         +2 -4 -4 0
         +1 -2 -2 0
         0 0 0 0
         -1 +1 2 -1
         -2 +3 4 -1
         -3 +5 6 -1
         -4 +6 8 -2
         -5 +8 10 -2
         -6 +10 12 -2
         -7 +12 14 -2
         
         (-2)를 곱한 후, 조정
         조정: abs(7)을 제외하고 adjustPostion에서 (-1)을 더하고 -7까지 반음이 몇개인지를 센 뒤 (-3)을 더한다.
         */
        
        
        if adjustPostion == 0 {
            return 0
        }
        
        let mod = adjustPostion % 12
        if abs(mod) == 7 {
            return 12 * -mod.signum()
        }
        
        let adjustStep = (-7...(adjustPostion - 1)).filter {
            passIndexInC.contains($0)
        }.count - 3
        
        return mod * (-2) + adjustStep
    }
}
