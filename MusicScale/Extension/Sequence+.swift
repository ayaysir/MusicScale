//
//  Sequence+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/16.
//

import Foundation

extension Sequence {
    
    // https://stackoverflow.com/questions/49476485/swift-loop-over-array-elements-and-access-previous-and-next-elements
    /// 사용법: array.enumerated().withPreviousAndNext.compactMap { values -> T? in ... }
    var withPreviousAndNext: [(Element?, Element, Element?)] {
        let optionalSelf = self.map(Optional.some)
        let next = optionalSelf.dropFirst() + [nil]
        let prev = [nil] + optionalSelf.dropLast()
        return zip(self, zip(prev, next)).map {
            ($1.0, $0, $1.1)
        }
    }
}
