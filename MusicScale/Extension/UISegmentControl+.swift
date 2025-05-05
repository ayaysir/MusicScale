//
//  UISegmentControl+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/12/05.
//

import UIKit

extension UISegmentedControl {
  func replaceSegments(segments: Array<String>) {
    self.removeAllSegments()
    for segment in segments {
      self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
    }
  }
}
