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
    static var cfgQuizNumOfQuest = "QUIZ_cfgQuizNumOfQuest"
    static var cfgQuizTypeOfQuest = "QUIZ_cfgQuizTypeOfQuest"
    static var cfgQuizEnharmonicMode = "QUIZ_cfgQuizEnharmonicMode"
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
    
    var numberOfQuestions: Int {
        get {
            let number = store.integer(forKey: .cfgQuizNumOfQuest)
            if number <= 0 {
                return -999
            }
            return number
        } set {
            store.set(newValue, forKey: .cfgQuizNumOfQuest)
        }
    }
    
    var typeOfQuestions: QuizType {
        get {
            let number = store.integer(forKey: .cfgQuizTypeOfQuest)
            if let type = QuizType(rawValue: number) {
                return type
            }
            return .matchKeys
        } set {
            store.set(newValue.rawValue, forKey: .cfgQuizTypeOfQuest)
        }
    }
    
    var enharmonicMode: EnharmonicMode {
        get {
            let rawValue = store.integer(forKey: .cfgQuizEnharmonicMode)
            if let mode = EnharmonicMode(rawValue: rawValue) {
                return mode
            }
            return .standard
        } set {
            store.set(newValue.rawValue, forKey: .cfgQuizEnharmonicMode)
        }
    }
    
    var quizConfigChunk: QuizConfig {
        return QuizConfig(availableKeys: availableKeys, ascSelected: ascSelected, descSelected: descSelected, selectedScaleInfoId: selectedScaleInfoId, numberOfQuestions: numberOfQuestions, typeOfQuestions: typeOfQuestions, enharmonicMode: enharmonicMode)
    }
}
