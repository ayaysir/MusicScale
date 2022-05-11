//
//  PianoKeyArea.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import UIKit

struct PianoKeyArea {
    
    enum KeyColor {
        case white, black
    }
    
    var touchArea: CGRect
    var keyColor: KeyColor
    var note: Note?
}
