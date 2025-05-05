//
//  StarRatingViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/13.
//

import UIKit

struct StarRatingViewModel {
  
  let dataSource: [String] = [
    "★★★★★",
    "★★★★",
    "★★★",
    "★★",
    "★",
  ]
  
  func countStarText(_ starText: String) -> Int {
    return starText.count
  }
  
  func starTextWithBlankStars(fillCount: Int) -> String {
    return String(repeating: "★", count: fillCount) + String(repeating: "☆", count: 5 - fillCount)
  }
  
  func starTextAttributedStr(fillCount: Int, fillColor: UIColor = .orange) -> NSMutableAttributedString {
    
    let starTextAttr = NSMutableAttributedString(string: String(repeating: "★", count: 5))
    
    var strokeTextAttributes: [NSAttributedString.Key: Any] = [
      .strokeColor: UIColor.orange,
      .foregroundColor: fillColor,
      .strokeWidth: -1.25,
      .font: UIFont.systemFont(ofSize: 15),
    ]
    starTextAttr.addAttributes(strokeTextAttributes, range: NSRange(location: 0, length: fillCount))
    
    strokeTextAttributes[.foregroundColor] = UIColor.clear
    starTextAttr.addAttributes(strokeTextAttributes, range: NSRange(location: fillCount, length: 5 - fillCount))
    
    return starTextAttr
  }
}
