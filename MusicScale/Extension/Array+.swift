//
//  Array+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/05.
//

import Foundation

enum ShuffleArrayError: Error {
  case totalCountIsGreaterThanArrayCount, newArrayCountAndTotalCountNotSame
}

extension Array {
  
  func makeShuffledArray(totalCount: Int) throws -> Self {
    guard self.count < totalCount else {
      throw ShuffleArrayError.totalCountIsGreaterThanArrayCount
    }
    
    var newArray = self
    let repeatCount = (totalCount / self.count - 1)
    if repeatCount >= 1 {
      for _ in 0..<repeatCount {
        let shuffledArray = self.shuffled()
        newArray += shuffledArray
      }
    }
    
    // 남은 개수 이어붙이기
    
    let remainCount = totalCount - newArray.count
    newArray += Array(self[0..<remainCount])
    
    guard newArray.count == totalCount else {
      throw ShuffleArrayError.newArrayCountAndTotalCountNotSame
    }
    
    return newArray
  }
}
