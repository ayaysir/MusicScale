//
//  QuizConfigStore.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/02.
//

import Foundation

extension String {
    static var cfgKeyList = "QUIZ_cfgKeyList"
}

struct QuizConfigStore {
    
    static var shared = QuizConfigStore()
    private let store = UserDefaults.standard
    
    var availableKeys: Set<Music.Key> {
        get {
            do {
                return try store.getObject(forKey: .cfgKeyList, castTo: Set<Music.Key>.self)
            } catch {
                print("Can't load cfgKeyList from UserDefaults:", error)
            }
            
            return [.C, .E]
        } set {
            do {
                try store.setObject(newValue, forKey: .cfgKeyList)
            } catch {
                print("Can't save cfgKeyList to UserDefaults:", error)
            }
        }
    }
}
