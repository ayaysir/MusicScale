//
//  NSLayoutConstraint+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/19.
//

import UIKit

extension NSLayoutConstraint {
  /**
   Change multiplier constraint.
   https://stackoverflow.com/questions/19593641/can-i-change-multiplier-property-for-nslayoutconstraint
   
   - parameter multiplier: CGFloat
   - returns: NSLayoutConstraint
   */
  func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
    
    NSLayoutConstraint.deactivate([self])
    
    let newConstraint = NSLayoutConstraint(
      item: firstItem as Any,
      attribute: firstAttribute,
      relatedBy: relation,
      toItem: secondItem,
      attribute: secondAttribute,
      multiplier: multiplier,
      constant: constant)
    
    newConstraint.priority = priority
    newConstraint.shouldBeArchived = self.shouldBeArchived
    newConstraint.identifier = self.identifier
    
    NSLayoutConstraint.activate([newConstraint])
    return newConstraint
  }
}
