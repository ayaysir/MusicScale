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
  var isDivBy12Tet: Bool
  var displayOrder, myPriority: Int
  var createdDate, modifiedDate: Date
  var groupName: String
  
  enum CodingKeys: String, CodingKey, CaseIterable {
    // CSV 출력될 순서대로 재정렬
    case id
    case displayOrder = "display_order"
    case name
    case nameAlias = "name_alias"
    case degreesAscending = "degrees_ascending"
    case degreesDescending = "degrees_descending"
    case defaultPriority = "default_priority"
    case myPriority = "my_priority"
    case comment
    case links
    case isDivBy12Tet = "is_div_by_12tet"
    case groupName = "group_name"
    case createdDate = "created_date"
    case modifiedDate = "modified_date"
  }
  
  
}
