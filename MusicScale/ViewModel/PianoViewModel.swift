//
//  PianoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import UIKit



class PianoViewModel {
    
    private(set) var currentPlayableKey: Music.PlayableKey = .C
    private(set) var touchBlackKeyArea: [PianoKeyInfo] = []
    
    var frame: CGRect!
    
    private var adjustKeyPosition: Int = 0 {
        didSet {

        }
    }
    
    init(viewFrame frame: CGRect, key playableKey: Music.PlayableKey) {
        self.frame = frame
        drawBlackKey()
    }
    
    func drawBlackKey() {
        // 검은 건반 그리기:
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
        
        let passIndexInC = passIndexInC_lower + [0] + passIndexInC_upper
        let passIndexAdjusted = passIndexInC.map { $0 + (adjustKeyPosition) }
        
        let divBy = PianoViewConstants.divBy
        for seq in 0...divBy {
            if passIndexAdjusted.contains(seq) {
                continue
            }
            
            let blackKeyRatio = PianoViewConstants.blackKeyRatio
            let margin = PianoViewConstants.margin
            let margins = PianoViewConstants.margins
            let lineWidth = PianoViewConstants.lineWidth
            
            let whiteKeyWidth = (frame.width - margins.x) / CGFloat(divBy)
            let blackKeyWidth = whiteKeyWidth * blackKeyRatio.width
            let keyArea = CGRect(x: margin.left + (whiteKeyWidth * CGFloat(seq) - blackKeyWidth * 0.5),
                                 y: margin.top - lineWidth * 0.5,
                                 width: blackKeyWidth,
                                 height: (frame.height - margins.y) * blackKeyRatio.height)
            
            // 검은 건반 touchArea 추가
            touchBlackKeyArea.append(PianoKeyInfo(touchArea: keyArea, keyColor: .black, keyIndex: seq))
        }
    }
}
