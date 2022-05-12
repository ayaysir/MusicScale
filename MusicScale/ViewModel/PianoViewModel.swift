//
//  PianoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import UIKit

typealias StartEndPositions = (startPos: CGPoint, endPos: CGPoint)

class PianoViewModel {
    
    // Constants
    private(set) var divBy: Int!
    private(set) var margin: Margin!
    private(set) var lineWidth: CGFloat!
    private(set) var blackKeyRatio: CGSize!
    
    private var frame: CGRect!
    
    var adjustKeyPosition: Int = 0 {
        didSet {
            arrangeKeys()
            handlerForRefreshEntireView()
        }
    }
    
    private var passIndexInC: [Int]!
    private var passIndexAdjusted: [Int]!
    
    private(set) var pianoKeys: [PianoKeyInfo] = []
    var pianoWhiteKeys: [PianoKeyInfo] {
        return pianoKeys.filter { $0.keyColor == .white }
    }
    var pianoBlackKeys: [PianoKeyInfo] {
        return pianoKeys.filter { $0.keyColor == .black }
    }
    
    private(set) var whiteKeyDrawPosList: [StartEndPositions] = []
    private(set) var blackKeyDrawPosList: [CGRect] = []
    private(set) var topBottomLineDrawPosList: [StartEndPositions] = []
    
    var handlerForRefreshEntireView: (() -> ()) = {}
    var handlerForRefreshPartialView: ((CGRect) -> ()) = { _ in }
    
    
    var boxOutline: CGRect {
        return CGRect(x: margin.left, y: margin.top, width: frame.width - (margin.left + margin.right), height: frame.height - (margin.top + margin.bottom))
    }
    
    var currentTouchedKey: PianoKeyInfo? {
        didSet {
            if let currentTouchedKey = currentTouchedKey {
                handlerForRefreshPartialView(currentTouchedKey.touchArea)
            } else {
                handlerForRefreshEntireView()
            }
        }
    }
    
    init(frame: CGRect, divBy: Int, margin: Margin, lineWidth: CGFloat, blackKeyRatio: CGSize) {
        
        self.divBy = divBy
        self.margin = margin
        self.lineWidth = lineWidth
        self.blackKeyRatio = blackKeyRatio
        
        self.frame = frame
        
        configurePassIndexInC()
        createTopBottomLine()
        arrangeKeys()
    }
    
    convenience init(frame: CGRect) {
        
        let divBy: Int = PianoViewConstants.divBy
        let margin: Margin = PianoViewConstants.margin
        let lineWidth = PianoViewConstants.lineWidth
        let blackKeyRatio = PianoViewConstants.blackKeyRatio
        
        self.init(frame: frame, divBy: divBy, margin: margin, lineWidth: lineWidth, blackKeyRatio: blackKeyRatio)
    }
    
    private func configurePassIndexInC() {
        
        let passIndexHalfRange = (1...PianoViewConstants.passIndexHalfRangeTo)
        
        let passIndexInC_upper = passIndexHalfRange.reduce(into: [Int]()) { partialResult, index in
            let lastElement = partialResult.last ?? 0
            partialResult.append(lastElement + (index % 2 != 0 ? 3 : 4))
        }
        let passIndexInC_lower = passIndexHalfRange.reduce(into: [Int]()) { partialResult, index in
            let lastElement = partialResult.last ?? 0
            partialResult.append(lastElement + (index % 2 != 0 ? -4 : -3))
        }
        
        self.passIndexInC = passIndexInC_lower + [0] + passIndexInC_upper
        print("keyInfo:", passIndexInC)
    }
    
    private func arrangeKeys() {
        
        passIndexAdjusted = passIndexInC.map { $0 + (adjustKeyPosition) }
        print("keyInfo:", passIndexAdjusted)
        pianoKeys = []
        whiteKeyDrawPosList = []
        blackKeyDrawPosList = []
        createWhiteKeys()
        createBlackKeys()
    }
    
    func changeKey(key: Music.PlayableKey) {
        self.adjustKeyPosition = PianoKeyHelper.adjustKeyPosition(key: key)
    }
    
    func getKeyInfoBy(touchLocation location: CGPoint) -> PianoKeyInfo? {
        
        print(pianoBlackKeys)
        if let targetBlackKey = pianoBlackKeys.first(where: { $0.touchArea.contains(location) }) {
            return targetBlackKey
        }
        
        print("whiteKeys:", pianoWhiteKeys)
        if let targetWhiteKey = pianoWhiteKeys.first(where: { $0.touchArea.contains(location) }) {
            return targetWhiteKey
        }
        
        return nil
    }
    
    // 상하 라인 정보 제공
    private func createTopBottomLine() {
        
        let topBottomPosY = [margin.top, frame.height - margin.bottom]
        
        // 위아래 라인
        for posY in topBottomPosY {
            let startPos = CGPoint(x: 0, y: posY)
            let endPos = CGPoint(x: frame.width, y: posY)
            topBottomLineDrawPosList.append((startPos: startPos, endPos: endPos))
        }
    }
    
    // 흰 건반 영역 추가
    private func createWhiteKeys() {
        
        let margins: Margins = (x: margin.left + margin.right, y: margin.top + margin.bottom)

        let whiteKeyWidth = (frame.width - margins.x) / CGFloat(divBy)
        
        var whiteKeyIndex = -1
        for seq in -1...(divBy + 1) {
            let eachPosX: CGFloat = margin.left + whiteKeyWidth * CGFloat(seq)
            
            let startPos = CGPoint(x: eachPosX, y: margin.top)
            let endPos = CGPoint(x: eachPosX, y: frame.height - margin.bottom)
            whiteKeyDrawPosList.append((startPos: startPos, endPos: endPos))
            
            // 그리기 방법
//            context.move(to: startPos)
//            context.addLine(to: endPos)
//            context.strokePath()
            
            let touchArea = CGRect(origin: startPos, size: CGSize(width: whiteKeyWidth, height: endPos.y - startPos.y))
            let keyIndexStep = passIndexAdjusted.contains(seq) ? 1 : 2
            if seq != -1 {
                whiteKeyIndex += keyIndexStep
            }
            
            print("whiteKeys:", seq, passIndexAdjusted.contains(seq), keyIndexStep, whiteKeyIndex, touchArea)
            pianoKeys.append(PianoKeyInfo(touchArea: touchArea, keyColor: .white, keyIndex: whiteKeyIndex))
        }
    }
    
    // 검은 건반 영역 추가
    private func createBlackKeys() {
        
        let margins: Margins = (x: margin.left + margin.right, y: margin.top + margin.bottom)
        
        var blackKeyIndex = -2
        for seq in 0...divBy {
            if passIndexAdjusted.contains(seq) {
                blackKeyIndex += 1
                continue
            }
            
//            context.setFillColor(UIColor.red.cgColor)
            
            let whiteKeyWidth = (frame.width - margins.x) / CGFloat(divBy)
            let blackKeyWidth = whiteKeyWidth * blackKeyRatio.width
            let keyArea = CGRect(x: margin.left + (whiteKeyWidth * CGFloat(seq) - blackKeyWidth * 0.5),
                                 y: margin.top - lineWidth * 0.5,
                                 width: blackKeyWidth,
                                 height: (frame.height - margins.y) * blackKeyRatio.height)
            blackKeyDrawPosList.append(keyArea)
//            context.addRect(keyArea)
//            context.fillPath()
            
            // 검은 건반 touchArea 추가
            blackKeyIndex += 2
            pianoKeys.append(PianoKeyInfo(touchArea: keyArea, keyColor: .black, keyIndex: blackKeyIndex))
        }
    }
    
    
}
