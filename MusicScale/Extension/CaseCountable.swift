//
//  CaseCountable.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/13.
//
// https://stackoverflow.com/questions/27094878/how-do-i-get-the-count-of-a-swift-enum
//

import Foundation

protocol CaseCountable {
    static var caseCount: Int { get }
}

extension CaseCountable where Self: RawRepresentable, Self.RawValue == Int {
    internal static var caseCount: Int {
        var count = 0
        while let _ = Self(rawValue: count) {
            count += 1
        }
        return count
    }
}
