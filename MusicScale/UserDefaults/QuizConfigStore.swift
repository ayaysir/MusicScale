//
//  QuizConfigStore.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/02.
//

import Foundation

extension String {
    static var cfgQuizKeyList = "QUIZ_cfgQuizKeyList"
    static var cfgQuizAscSelected = "QUIZ_cfgQuizAscSelected"
    static var cfgQuizDescSelected = "QUIZ_cfgQuizDescSelected"
    static var cfgQuizScaleIdList = "QUIZ_cfgQuizScaleIdList"
}

struct QuizConfigStore {
    
    static var shared = QuizConfigStore()
    private let store = UserDefaults.standard
    
    var availableKeys: Set<Music.Key> {
        get {
            do {
                return try store.getObject(forKey: .cfgQuizKeyList, castTo: Set<Music.Key>.self)
            } catch {
                print("Can't load cfgKeyList from UserDefaults:", error)
            }
            
            return [.C, .E]
        } set {
            do {
                try store.setObject(newValue, forKey: .cfgQuizKeyList)
            } catch {
                print("Can't save cfgKeyList to UserDefaults:", error)
            }
        }
    }
    
    var ascSelected: Bool {
        get {
            return store.bool(forKey: .cfgQuizAscSelected)
        } set {
            store.set(newValue, forKey: .cfgQuizAscSelected)
        }
    }
    
    var descSelected: Bool {
        get {
            return store.bool(forKey: .cfgQuizDescSelected)
        } set {
            store.set(newValue, forKey: .cfgQuizDescSelected)
        }
    }
    
    var selectedScaleInfoId: Set<UUID> {
        get {
            do {
                return try store.getObject(forKey: .cfgQuizScaleIdList, castTo: Set<UUID>.self)
            } catch {
                print("Can't load cfgQuizScaleIdList from UserDefaults:", error)
            }
            
            return []
        } set {
            do {
                try store.setObject(newValue, forKey: .cfgQuizScaleIdList)
            } catch {
                print("Can't save cfgQuizScaleIdList to UserDefaults:", error)
            }
        }
    }
}
