//
//  PianoKeyArea.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import UIKit

struct PianoKeyInfo {
    
    enum KeyColor {
        case white, black
    }
    
    var touchArea: CGRect
    var keyColor: KeyColor
    var keyIndex: Int
}
