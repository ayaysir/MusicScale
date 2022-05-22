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
    static let lineWidth: CGFloat = 0.7
    
    /// 흰 건반 대비 검은 건반의 가로세로 길이 비율
    static let blackKeyRatio: CGSize = CGSize(width: 0.8, height: 0.65)
    
}

// MARK: - PianoView
class PianoView: UIView {

    // draw 주요 정보 저장
    var viewModel: PianoViewModel!
    
    var boxOutline: CGRect!
    
    let lightYellow = CGColor(red: 255/255, green: 235/255, blue: 60/255, alpha: 1)
    // let darkYellow = CGColor(red: 255/255, green: 200/255, blue: 50/255, alpha: 1)
    let darkYellow = CGColor(red: 195/255, green: 150/255, blue: 10/255, alpha: 1)
    let violet = CGColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
    let purple = CGColor(red: 150/255, green: 33/255, blue: 170/255, alpha: 1)
    
    let orange = CGColor(red: 250/255, green: 177/255, blue: 88/255, alpha: 1)
    
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
        viewModel = PianoViewModel(frame: self.frame)
        boxOutline = viewModel.boxOutline
        viewModel.handlerForRefreshEntireView = {
            self.setNeedsDisplay()
        }
        viewModel.handlerForRefreshPartialView = { rect in
            self.setNeedsDisplay(rect)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
//        print("draw start")
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
                
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(rect)
        
        // 위아래 라인
        context.setLineWidth(viewModel.lineWidth)
        context.setStrokeColor(UIColor.darkGray.cgColor)
        for line in viewModel.topBottomLineDrawPosList {
            context.move(to: line.startPos)
            context.addLine(to: line.endPos)
            context.strokePath()
        }
        
        // 검은 건반 정보
        // 3, 4, 3, 4 .....
        // -11, -7 ,-4 ,0, 3, 7, 10, 14, 17, 21

        // 흰 건반 그리기: 내부를 7개 선으로 나눔
        for keyLine in viewModel.whiteKeyDrawPosList {
            context.move(to: keyLine.startPos)
            context.addLine(to: keyLine.endPos)
            context.strokePath()
        }
        
        // 키별로 동그라미 그리기 (흰 건반 - 누르기 전)
        for info in viewModel.pianoWhiteKeys {
            if viewModel.availableKeyIndexes.contains(info.keyIndex) {
                let touchArea = info.touchArea
                let startY = touchArea.minY + touchArea.height * (1 - PianoViewConstants.blackKeyRatio.height)
                let keyRect = CGRect(x: touchArea.minX, y: startY, width: touchArea.width, height: touchArea.height)
                
                let midPoint = CGPoint(x: keyRect.midX, y: keyRect.midY)
                let arcRadius = keyRect.width / 2 / 1.5
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let gradientColors = [
                    darkYellow,
                    purple,
                ] as CFArray
                
                let colorLocations: [CGFloat] = [0.5, 0.95]
                let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: colorLocations)
                
                context.drawRadialGradient(gradient!, startCenter: midPoint, startRadius: 0, endCenter: midPoint, endRadius: arcRadius, options: [])
            }
            
        }
        
        
        // 현재 누르고 있는 건반 하이라이트(흰색)
        // 흰 건반인 경우 검은 건반 그리기 전에 하이라이트 해야 안겹침
        if let currentTouchedKey = viewModel.currentTouchedKey, currentTouchedKey.keyColor == .white {
            context.addRect(currentTouchedKey.touchArea)
            context.setFillColor(orange)
            context.fillPath()
            
            // 키별로 동그라미 그리기 (흰색 건반 - 누른 후)
            if viewModel.availableKeyIndexes.contains(currentTouchedKey.keyIndex) {
                let touchArea = currentTouchedKey.touchArea
                let startY = touchArea.minY + touchArea.height * (1 - PianoViewConstants.blackKeyRatio.height)
                let keyRect = CGRect(x: touchArea.minX, y: startY, width: touchArea.width, height: touchArea.height)
                let midPoint = CGPoint(x: keyRect.midX, y: keyRect.midY)
                let arcRadius = keyRect.width / 2 / 1.5
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let gradientColors = [
                    lightYellow,
                    violet,
                ] as CFArray
                
                let colorLocations: [CGFloat] = [0.5, 0.95]
                let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: colorLocations)
                
                context.drawRadialGradient(gradient!, startCenter: midPoint, startRadius: 0, endCenter: midPoint, endRadius: arcRadius, options: [])
            }
            
            
        }
        
        // 검은 건반 그리기:
        for keyRect in viewModel.blackKeyDrawPosList {
            context.setFillColor(CGColor(gray: 0.1, alpha: 1))
            context.addRect(keyRect)
            context.fillPath()
        }
        
        // 키별로 동그라미 그리기 (검은 건반 - 누르기 전)
        for info in viewModel.pianoBlackKeys {
            if viewModel.availableKeyIndexes.contains(info.keyIndex) {
                let keyRect = info.touchArea
                let midPoint = CGPoint(x: keyRect.midX, y: keyRect.midY)
                let arcRadius = keyRect.width / 2 / 1.5
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let gradientColors = [
                    darkYellow,
                    purple,
                ] as CFArray
                
                let colorLocations: [CGFloat] = [0.5, 0.95]
                let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: colorLocations)
                
                context.drawRadialGradient(gradient!, startCenter: midPoint, startRadius: 0, endCenter: midPoint, endRadius: arcRadius, options: [])
            }
        }
        
        // 현재 누르고 있는 건반 하이라이트(검은색)
        // 검은색 건반인 경우 검은 건반 그린 이후에 하이라이트 해야 안묻힘
        if let currentTouchedKey = viewModel.currentTouchedKey, currentTouchedKey.keyColor == .black {
            context.addRect(currentTouchedKey.touchArea)
            context.setFillColor(orange)
            context.fillPath()
            
            // 키별로 동그라미 그리기 (검은 건반 - 누른 후)
            if viewModel.availableKeyIndexes.contains(currentTouchedKey.keyIndex) {
                
                let keyRect = currentTouchedKey.touchArea
                let midPoint = CGPoint(x: keyRect.midX, y: keyRect.midY)
                let arcRadius = keyRect.width / 2 / 1.5
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let gradientColors = [
                    lightYellow,
                    violet,
                ] as CFArray
                
                let colorLocations: [CGFloat] = [0.5, 0.95]
                let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: colorLocations)
                
                context.drawRadialGradient(gradient!, startCenter: midPoint, startRadius: 0, endCenter: midPoint, endRadius: arcRadius, options: [])
            }
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
