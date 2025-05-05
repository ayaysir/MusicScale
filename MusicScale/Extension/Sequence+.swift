//
//  Sequence+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/16.
//

import Foundation

extension Sequence {
  /// - 사용법
  /// ```swift
  /// array.enumerated().withPreviousAndNext.compactMap { values -> T? in ... }
  /// let (prev, curr, next) = values
  /// ```
  var withPreviousAndNext: [(Element?, Element, Element?)] {
    let optionalSelf = self.map(Optional.some)
    let next = optionalSelf.dropFirst() + [nil]
    let prev = [nil] + optionalSelf.dropLast()
    return zip(self, zip(prev, next)).map {
      ($1.0, $0, $1.1)
    }
  }
}
