//
//  UIButton+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/19.
//

import UIKit

extension UIButton {
    
    func spaceBetweenImageAndText(space: CGFloat) {
        let halfSize = space / 2
        if #available(iOS 15.0, *), self.configuration != nil {
            
        } else {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -halfSize, bottom: 0, right: halfSize)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: halfSize, bottom: 0, right: halfSize)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: halfSize, bottom: 0, right: halfSize)
        }
    }
}
