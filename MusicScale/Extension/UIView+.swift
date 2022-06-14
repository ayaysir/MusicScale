//
//  UIView+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/14.
//

import UIKit

extension UIView {
    
    enum GlowEffect: Float {
        case small = 0.4, normal = 2, semibig = 5, big = 15
    }

    func doGlowAnimation(withColor color: UIColor, withEffect effect: GlowEffect = .semibig) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero

        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = effect.rawValue
        
        let repeatTime = 0.5
        
        glowAnimation.beginTime = CACurrentMediaTime() + repeatTime
        glowAnimation.duration = CFTimeInterval(repeatTime)
        glowAnimation.fillMode = .removed
        glowAnimation.autoreverses = true
        // glowAnimation.isRemovedOnCompletion = true
        glowAnimation.repeatCount = .infinity
        layer.add(glowAnimation, forKey: "shadowGlowingAnimation")
    }
    
    func removeGlowAnimation() {
        layer.removeAnimation(forKey: "shadowGlowingAnimation")
    }
}
