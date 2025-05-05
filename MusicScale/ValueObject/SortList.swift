//
//  SortList.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/31.
//

import Foundation

enum SortState: Int, Codable {
  case none, displayOrder, name, priority
}

enum SortOrder: Int {
  case none, ascending, descending
}

struct SortInfo {
  var title: String
  var order: SortOrder
  var state: SortState
}
