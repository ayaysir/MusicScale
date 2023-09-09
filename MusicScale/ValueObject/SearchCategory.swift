//
//  SearchCategory.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/01.
//

import Foundation

enum SearchCategory: Int, Codable, CaseIterable {
    case all, name, comment, degrees
    
    var textValue: String {
        switch self {
        case .all:
            return "All"
        case .name:
            return "Name"
        case .comment:
            return "Comment"
        case .degrees:
            return "Degrees"
        }
    }
}
