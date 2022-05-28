//
//  Between.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/29.
//

import Foundation

protocol BetweenNumbers {
    associatedtype N: Comparable
    func between(_ range: ClosedRange<N>) -> Bool
}

extension Int: BetweenNumbers {
    func between(_ range: ClosedRange<Int>) -> Bool {
        return range.contains(self)
    }
}
