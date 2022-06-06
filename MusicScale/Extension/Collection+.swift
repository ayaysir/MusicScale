//
//  Collection+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/06.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
