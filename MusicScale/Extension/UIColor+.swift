//
//  UIColor+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/31.
//

import UIKit

extension UIColor {
    static let realGreeen = UIColor(red: 12/255, green: 133/255, blue: 44/255, alpha: 1)
    
    convenience init(fromGooglePicker three255Text: String) {
        let values = three255Text.components(separatedBy: ", ").map { Double($0)! / 255.0 }
        self.init(red: values[0], green: values[1], blue: values[2], alpha: 1)
    }
}
