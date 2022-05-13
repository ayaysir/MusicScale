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
    static let passIndexHalfRangeTo: Int = 12
    
    /// 흰 건반은 한 화면에 몇개까지 표시되는지? 단 앞 뒤 margin 범위는 제외됨.
    /// 예를 들어 8인 경우, 흰 건반은 8개에 앞뒤로 margin 길이의 잘린 건반 2개가 포함되므로 총 개수는 10개
    static let divBy: Int = 8
    
    /// 마진: top, right, bottom, left
    static let margin: Margin = (top: 10, right: 10, bottom: 10, left: 10)
    static let margins: Margins = (x: margin.left + margin.right, y: margin.top + margin.bottom)
    
    /// 박스 line의 너비
    static let lineWidth: CGFloat = 2.5
    
    /// 흰 건반 대비 검은 건반의 가로세로 길이 비율
    static let blackKeyRatio: CGSize = CGSize(width: 0.8, height: 0.65)
    
}

// MARK: - PianoView
class PianoView: UIView {

    // draw 주요 정보 저장
    var pianoViewModel: PianoViewModel!
    
    var boxOutline: CGRect!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("PianoView is initialized from \(#function)")
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("PianoView is initialized from \(#function)")
        initCommon()
    }
    
    private func initCommon() {
        pianoViewModel = PianoViewModel(frame: self.frame)
        boxOutline = pianoViewModel.boxOutline
        pianoViewModel.handlerForRefreshEntireView = {
            self.setNeedsDisplay()
        }
        pianoViewModel.handlerForRefreshPartialView = { rect in
            self.setNeedsDisplay(rect)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        print("draw start")
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
                
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(rect)
        
        // 위아래 라인
        context.setLineWidth(pianoViewModel.lineWidth)
        context.setStrokeColor(UIColor.black.cgColor)
        for line in pianoViewModel.topBottomLineDrawPosList {
            context.move(to: line.startPos)
            context.addLine(to: line.endPos)
            context.strokePath()
        }
        
        // 검은 건반 정보
        // 3, 4, 3, 4 .....
        // -11, -7 ,-4 ,0, 3, 7, 10, 14, 17, 21

        // 흰 건반 그리기: 내부를 7개 선으로 나눔
        for keyLine in pianoViewModel.whiteKeyDrawPosList {
            context.move(to: keyLine.startPos)
            context.addLine(to: keyLine.endPos)
            context.strokePath()
        }
        
        // 현재 누르고 있는 건반 하이라이트(흰색)
        // 흰 건반인 경우 검은 건반 그리기 전에 하이라이트 해야 안겹침
        if let currentTouchedKey = pianoViewModel.currentTouchedKey, currentTouchedKey.keyColor == .white {
            context.addRect(currentTouchedKey.touchArea)
            context.setFillColor(UIColor.orange.cgColor)
            context.fillPath()
        }
        
        // 검은 건반 그리기:
        context.setFillColor(UIColor.red.cgColor)
        for keyRect in pianoViewModel.blackKeyDrawPosList {
            context.addRect(keyRect)
            context.fillPath()
        }
        
        // 현재 누르고 있는 건반 하이라이트(검은색)
        // 검은색 건반인 경우 검은 건반 그린 이후에 하이라이트 해야 안묻힘
        if let currentTouchedKey = pianoViewModel.currentTouchedKey, currentTouchedKey.keyColor == .black {
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
