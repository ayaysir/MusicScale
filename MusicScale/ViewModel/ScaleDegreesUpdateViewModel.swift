//
//  ScaleDegreesUpdateViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/26.
//

import Foundation

class ScaleDegreesUpdateViewModel {
    
    var onEditDegreesAsc: [String] = ["1"]
    var onEditDegreesDesc: [String] = ["1"]
    
    private let helper = MusicSheetHelper()
    
    init() {
        
    }
    
    init(ascDegrees: String, descDegrees: String) {
        onEditDegreesAsc = ascDegrees.components(separatedBy: " ")
        onEditDegreesDesc = ascDegrees.components(separatedBy: " ")
    }
    
    var degreesAsc: String {
        onEditDegreesAsc.joined(separator: " ")
    }
    
    var degreesDesc: String {
        onEditDegreesDesc.joined(separator: " ")
    }
    
    
}
