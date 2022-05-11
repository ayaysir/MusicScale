//
//  PianoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/11.
//

import UIKit

class PianoViewController: UIViewController {
    
    @IBOutlet weak var viewPiano: PianoView!
    @IBOutlet weak var lblCurrentKeyPosition: UILabel!
    @IBOutlet weak var lblCurrentPianoViewScale: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let pianoLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePianoLongPress(gesture:)))
        pianoLongPressRecognizer.minimumPressDuration = 0
        viewPiano.addGestureRecognizer(pianoLongPressRecognizer)
    }
    
    @objc func handlePianoLongPress(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .possible:
            print("possible")
        case .began:
            let location = gesture.location(in: gesture.view)
            print("touchLocation:", location)
            
//            let whiteKeyResult = viewPiano.touchWhiteKeyArea.reduce(into: []) { partialResult, rect in
//                partialResult.append(rect.contains(location))
//            }
//            let blackKeyResult = viewPiano.touchBlackKeyArea.reduce(into: []) { partialResult, rect in
//                partialResult.append(rect.contains(location))
//            }
//            print("whiteKey:", whiteKeyResult)
//            print("blackKey:", blackKeyResult)
            
            if let targetBlackKey = viewPiano.touchBlackKeyArea.first(where: { $0.touchArea.contains(location) }) {
                print(targetBlackKey)
                viewPiano.currentTouchedKey = targetBlackKey
                return
            }
            
            if let targetWhiteKey = viewPiano.touchWhiteKeyArea.first(where: { $0.touchArea.contains(location) }) {
                print(targetWhiteKey)
                viewPiano.currentTouchedKey = targetWhiteKey
                return
            }
            
        case .changed:
            print("changed")
        case .ended:
            print("ended")
            viewPiano.currentTouchedKey = nil
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        @unknown default:
            print("default")
        }
    }
    
    @IBAction func sldActViewScale(_ sender: UISlider) {
        viewPiano.transform = .identity.scaledBy(x: CGFloat(sender.value), y: CGFloat(sender.value))
        lblCurrentPianoViewScale.text = "\(sender.value)"
    }
    
    @IBAction func stepAdjustKeyPosition(_ sender: UIStepper) {
        viewPiano.adjustKeyPosition = Int(sender.value)
        lblCurrentKeyPosition.text = "\(Int(sender.value))"
    }
    
}

// MARK: - PianoView
class PianoView: UIView {
    
    // draw 주요 정보 저장
    var boxOutline: CGRect!
    var adjustKeyPosition: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var touchWhiteKeyArea: [PianoKeyArea] = []
    var touchBlackKeyArea: [PianoKeyArea] = []
    var currentTouchedKey: PianoKeyArea? {
        didSet {
            if let currentTouchArea = currentTouchedKey {
                setNeedsDisplay(currentTouchArea.touchArea)
            } else {
                setNeedsDisplay()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("PianoView is initialized from \(#function)")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("PianoView is initialized from \(#function)")
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 초기화
        touchWhiteKeyArea = []
        touchBlackKeyArea = []
        
        print(self.frame)
        let viewWidth = self.frame.width
        let viewHeight = self.frame.height
        
        // 마진: 10 10 10 10
        typealias Margin = (left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat)
        let margin: Margin = (left: 10, right: 10, top: 10, bottom: 10)
        let marginsX = margin.left + margin.right
        let marginsY = margin.top + margin.bottom
        
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
        
        // 흰 건반: 내부를 7개 선으로 나눔
        let divBy: Int = 8
        let whiteKeyWidth = (viewWidth - marginsX) / CGFloat(divBy)
        
        for seq in 0...divBy {
            let eachPosX: CGFloat = margin.left + whiteKeyWidth * CGFloat(seq)
            
            let startPos = CGPoint(x: eachPosX, y: margin.top)
            let endPos = CGPoint(x: eachPosX, y: viewHeight - margin.bottom)
            
            context.move(to: startPos)
            context.addLine(to: endPos)
            context.strokePath()
            
            // 흰 건반 touchArea에 추가
            if seq == 0 {
                let touchArea = CGRect(x: 0, y: margin.top, width: margin.left, height: endPos.y - startPos.y)
                touchWhiteKeyArea.append(PianoKeyArea(touchArea: touchArea, keyColor: .white))
            }
            
            let touchArea = CGRect(origin: startPos, size: CGSize(width: whiteKeyWidth, height: endPos.y - startPos.y))
            touchWhiteKeyArea.append(PianoKeyArea(touchArea: touchArea, keyColor: .white))
            
        }
        
        // 현재 누르고 있는 건반 하이라이트(흰색)
        // 흰 건반인 경우 검은 건반 그리기 전에 하이라이트 해야 안겹침
        if let currentTouchedKey = currentTouchedKey, currentTouchedKey.keyColor == .white {
            context.addRect(currentTouchedKey.touchArea)
            context.setFillColor(UIColor.orange.cgColor)
            context.fillPath()
        }
        
        // 검은 건반 그리기:
        // 3, 4, 3, 4 .....
        // -11, -7 ,-4 ,0, 3, 7, 10, 14, 17, 21
        let passIndexHalfRangeTo: Int = 6
        let passIndexInC_upper = (1...passIndexHalfRangeTo).reduce(into: [Int]()) { partialResult, index in
            let lastElement = partialResult.last ?? 0
            partialResult.append(lastElement + (index % 2 != 0 ? 3 : 4))
        }
        let passIndexInC_lower = (1...passIndexHalfRangeTo).reduce(into: [Int]()) { partialResult, index in
            let lastElement = partialResult.last ?? 0
            partialResult.append(lastElement + (index % 2 != 0 ? -4 : -3))
        }
        
        let passIndexInC = passIndexInC_lower + [0] + passIndexInC_upper
        let passIndexAdjusted = passIndexInC.map { $0 + (adjustKeyPosition) }
//        print(passIndexAdjusted)
        
        for seq in 0...divBy {
            if passIndexAdjusted.contains(seq) {
                continue
            }
            
            context.setFillColor(UIColor.red.cgColor)
            let blackKeyWidth = whiteKeyWidth * 0.8
            let keyArea = CGRect(x: margin.left + (whiteKeyWidth * CGFloat(seq) - blackKeyWidth * 0.5), y: margin.top - lineWidth * 0.5, width: blackKeyWidth, height: (viewHeight - marginsY) * 0.65)
            context.addRect(keyArea)
            context.fillPath()
            
            // 검은 건반 touchArea 추가
            touchBlackKeyArea.append(PianoKeyArea(touchArea: keyArea, keyColor: .black))
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
