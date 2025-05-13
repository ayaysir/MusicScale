//
//  PostViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/14.
//

import Foundation

class PostViewModel {
  
  private(set) var post: Post!
  
  var scaleInfoVM: SimpleScaleInfoViewModel {
    SimpleScaleInfoViewModel(scaleInfo: post.scaleInfo, currentKey: .C, currentTempo: self.currentTempo)
  }
  var currentTempo: Double = 120.0
  
  init(post: Post) {
    self.post = post
  }
  
  var name: String { post.scaleInfo.name }
  var alias: String { post.scaleInfo.nameAlias }
  var relativeCreatedTimeStr: String? {
    if let timestamp = post.serverCreatedTS {
      let date = FirebaseUtil.timestampToDate(timestamp)
      return date.localizedRelativeTime
    }
    
    return nil
  }
  
  var authorUID: String { post.authorUID }
  var authorUIDTruncated4: String { authorUID[0..<4] }
  var documentID: String { post.documentID! }
  var createdDateStr: String? {
    if let seconds = post.serverCreatedTS?.seconds {
      print(seconds)
      let date = Date(timeIntervalSince1970: TimeInterval(seconds))
      let formatter = DateFormatter()
      formatter.timeZone = .autoupdatingCurrent
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      
      return formatter.string(from: date) + " (\(formatter.timeZone.identifier))"
    }
    
    return nil
  }
  var additionalComment: String? { post.additionalComment }
  
  func writeToCoreData() throws -> ScaleInfoEntity {
    let oldInfo = post.scaleInfo
    let lowestDisplayOrder = try? ScaleInfoCDService.shared.lowestDisplayOrder()
    
    let newScaleInfo = ScaleInfo(id: UUID(),
                                 name: oldInfo.name,
                                 nameAlias: oldInfo.nameAlias,
                                 degreesAscending: oldInfo.degreesAscending,
                                 degreesDescending: oldInfo.degreesDescending,
                                 defaultPriority: oldInfo.defaultPriority,
                                 comment: oldInfo.comment,
                                 links: oldInfo.links,
                                 isDivBy12Tet: oldInfo.isDivBy12Tet,
                                 displayOrder: Int(lowestDisplayOrder ?? 0) - 1,
                                 myPriority: 0,
                                 createdDate: Date(),
                                 modifiedDate: Date(),
                                 groupName: "")
    do {
      return try ScaleInfoCDService.shared.saveCoreData(scaleInfo: newScaleInfo)
    } catch {
      throw error
    }
  }
}
