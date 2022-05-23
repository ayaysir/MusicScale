//
//  ScaleInfo.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let scaleInfo = try? newJSONDecoder().decode(ScaleInfo.self, from: jsonData)

import Foundation

// MARK: - ScaleInfo
struct ScaleInfo: Codable {
    
    let id: UUID
    let name, nameAlias: String
    let degreesAscending, degreesDescending: String
    let defaultPriority: Int
    var comment, links: String
    let isDivBy12Tet: Bool
    var displayOrder, myPriority: Int

    enum CodingKeys: String, CodingKey {
        case id, name
        case nameAlias = "name_alias"
        case degreesAscending = "degrees_ascending"
        case degreesDescending = "degrees_descending"
        case defaultPriority = "default_priority"
        case comment, links
        case isDivBy12Tet = "is_div_by_12tet"
        case displayOrder = "display_order"
        case myPriority = "my_priority"
    }
    
    
}
