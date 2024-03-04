//
//  PianoKeyArea.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import UIKit

struct PianoKeyInfo: Hashable {
    enum KeyColor: Hashable {
        case white, black
    }
    
    var touchArea: CGRect
    var keyColor: KeyColor
    var keyIndex: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(touchArea.width)
        hasher.combine(touchArea.height)
        hasher.combine(touchArea.origin.x)
        hasher.combine(touchArea.origin.y)
        hasher.combine(keyColor)
        hasher.combine(keyIndex)
    }
}
