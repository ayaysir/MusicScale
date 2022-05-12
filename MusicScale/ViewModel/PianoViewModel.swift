//
//  PianoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/12.
//

import UIKit

class PianoViewModel {
    
    var adjustKeyPosition: Int = 0 {
        didSet {
            
        }
    }
    private var passIndexInC: [Int]!
    
    var touchWhiteKeyArea: [PianoKeyInfo] = []
    var touchBlackKeyArea: [PianoKeyInfo] = []
    var currentTouchedKey: PianoKeyInfo? {
        didSet {
            if let currentTouchArea = currentTouchedKey {
                
            } else {
                
            }
        }
    }
}
