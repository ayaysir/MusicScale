//
//  PianoView.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import UIKit

typealias Margin = (top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat)
typealias Margins = (x: CGFloat, y: CGFloat)

struct PianoViewConstants {
    
    /// 0을 기준으로 +- 몇개까지 passIndex를 만들건지?
    static let passIndexHalfRangeTo: Int = 6
    
    /// 흰 건반은 한 화면에 몇개까지 표시되는지? 단 앞 뒤 margin 범위는 제외됨.
    /// 예를 들어 8인 경우, 흰 건반은 8개에 앞뒤로 margin 길이의 잘린 건반 2개가 포함되므로 총 개수는 10개
    static let divBy: Int = 8
    
    /// 마진: top, right, bottom, left
    static let margin: Margin = (top: 10, right: 10, bottom: 10, left: 10)
    static let margins: Margins = (x: margin.left + margin.right, y: margin.top + margin.bottom)
    
    /// 박스 line의 너비
    static let lineWidth = 2.5
    
    /// 흰 건반 대비 검은 건반의 가로세로 길이 비율
    static let blackKeyRatio: (width: CGFloat, height: CGFloat) =  (width: 0.8, height: 0.65)
}

// MARK: - PianoView
class PianoView: UIView {
    
    let divBy = PianoViewConstants.divBy
    let margin = PianoViewConstants.margin
    let margins = PianoViewConstants.margins

    // draw 주요 정보 저장
    var adjustKeyPosition: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    private var passIndexInC: [Int]!
    
    var touchWhiteKeyArea: [PianoKeyInfo] = []
    var touchBlackKeyArea: [PianoKeyInfo] = []
    var currentTouchedKey: PianoKeyInfo? {
        didSet {
            if let currentTouchArea = currentTouchedKey {
                setNeedsDisplay(currentTouchArea.touchArea)
            } else {
                setNeedsDisplay()
            }
        }
    }
    
    var boxOutline: CGRect!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("PianoView is initialized from \(#function)")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("PianoView is initialized from \(#function)")
        configure()
    }
    
    func configure() {
        
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
    }
    
    func changeKey(key: Music.PlayableKey) {
        
        self.adjustKeyPosition = PianoKeyHelper.adjustKeyPosition(key: key)
    }
    
    override func draw(_ rect: CGRect) {
        
        print("draw start")
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 초기화
        touchWhiteKeyArea = []
        touchBlackKeyArea = []
        
        print(self.frame)
        let viewWidth = self.frame.width
        let viewHeight = self.frame.height
                
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(rect)
        
        boxOutline = CGRect(x: margin.left, y: margin.top, width: viewWidth - (margin.left + margin.right), height: viewHeight - (margin.top + margin.bottom))
        
        let topBottomPosY = [margin.top, viewHeight - margin.bottom]
        let lineWidth = 2.5
        
        // 위아래 라인
        context.setLineWidth(lineWidth)
        for posY in topBottomPosY {
            context.setStrokeColor(UIColor.black.cgColor)
            context.move(to: CGPoint(x: 0, y: posY))
            context.addLine(to: CGPoint(x: viewWidth, y: posY))
            context.strokePath()
        }
        
        // 검은 건반 정보
        // 3, 4, 3, 4 .....
        // -11, -7 ,-4 ,0, 3, 7, 10, 14, 17, 21
        let passIndexAdjusted = passIndexInC.map { $0 + (adjustKeyPosition) }

        // 흰 건반 그리기: 내부를 7개 선으로 나눔
        let whiteKeyWidth = (viewWidth - margins.x) / CGFloat(divBy)
        
        var whiteKeyIndex = -1
        for seq in -1...(divBy + 1) {
            let eachPosX: CGFloat = margin.left + whiteKeyWidth * CGFloat(seq)
            
            let startPos = CGPoint(x: eachPosX, y: margin.top)
            let endPos = CGPoint(x: eachPosX, y: viewHeight - margin.bottom)
            
            context.move(to: startPos)
            context.addLine(to: endPos)
            context.strokePath()
            
            let touchArea = CGRect(origin: startPos, size: CGSize(width: whiteKeyWidth, height: endPos.y - startPos.y))
            let keyIndexStep = passIndexAdjusted.contains(seq) ? 1 : 2
            if seq != -1 {
                whiteKeyIndex += keyIndexStep
            }
            touchWhiteKeyArea.append(PianoKeyInfo(touchArea: touchArea, keyColor: .white, keyIndex: whiteKeyIndex))
        }
        
        // 현재 누르고 있는 건반 하이라이트(흰색)
        // 흰 건반인 경우 검은 건반 그리기 전에 하이라이트 해야 안겹침
        if let currentTouchedKey = currentTouchedKey, currentTouchedKey.keyColor == .white {
            context.addRect(currentTouchedKey.touchArea)
            context.setFillColor(UIColor.orange.cgColor)
            context.fillPath()
        }
        
        // 검은 건반 그리기:
        var blackKeyIndex = -2
        for seq in 0...divBy {
            if passIndexAdjusted.contains(seq) {
                blackKeyIndex += 1
                continue
            }
            
            context.setFillColor(UIColor.red.cgColor)
            
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
            
            context.addRect(keyArea)
            context.fillPath()
            
            // 검은 건반 touchArea 추가
            blackKeyIndex += 2
//            print("blackKeySeq:", seq, seq-1, passIndexAdjusted.contains(seq - 1), 0, blackKeyIndex)
            touchBlackKeyArea.append(PianoKeyInfo(touchArea: keyArea, keyColor: .black, keyIndex: blackKeyIndex))
        }
        
        // 현재 누르고 있는 건반 하이라이트(검은색)
        // 검은색 건반인 경우 검은 건반 그린 이후에 하이라이트 해야 안묻힘
        if let currentTouchedKey = currentTouchedKey, currentTouchedKey.keyColor == .black {
            context.addRect(currentTouchedKey.touchArea)
            context.setFillColor(UIColor.orange.cgColor)
            context.fillPath()
        }
        
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct PianoView_Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = PianoView()
            return view
        }
        .previewLayout(.sizeThatFits)
        .padding(0)
    }
}
#endif
