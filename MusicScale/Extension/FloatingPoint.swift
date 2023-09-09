//
//  FloatingPoint.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/23.
//

import Foundation

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
