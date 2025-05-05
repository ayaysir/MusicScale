//
//  JSONCoder.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/15.
//

import Foundation

func getSampleScaleDataFromLocal(completion : @escaping ([ScaleInfo]) throws -> ()) {
  
  let fileLocation = Bundle.main.url(forResource: "SampleScaleList-20220624", withExtension: "json")
  
  do {
    let data = try Data(contentsOf: fileLocation!)
    let array = try JSONDecoder().decode(Array<ScaleInfo>.self, from: data)
    try completion(array)
  } catch {
    print(#function, error)
  }
}
