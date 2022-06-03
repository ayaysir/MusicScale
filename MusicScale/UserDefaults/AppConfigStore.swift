//
//  AppConfigStore.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/03.
//

import Foundation

extension String {
    static let cfgAppCustomScale = "APP_cfgAppCustomScale"
}

struct AppConfigStore {
    
    static let shared = AppConfigStore()
    private let store = UserDefaults.standard
    
    var userCustomScale: [NoteStrPair] {
        get {
            do {
                return try store.getObject(forKey: .cfgAppCustomScale, castTo: [NoteStrPair].self)
            } catch {
                print("AppConfigStore: userCustomScale can't load from UserDefaults:", error)
                return [
                    NoteStrPair("", "C"),
                    NoteStrPair("^", "C"),
                    NoteStrPair("", "D"),
                    NoteStrPair("_", "E"),
                    NoteStrPair("", "E"),
                    NoteStrPair("", "F"),
                    NoteStrPair("^", "F"),
                    NoteStrPair("", "G"),
                    NoteStrPair("^", "G"),
                    NoteStrPair("", "A"),
                    NoteStrPair("^", "A"),
                    NoteStrPair("", "B"),
                ]
            }
        } set {
            do {
                try store.setObject(newValue, forKey: .cfgAppCustomScale)
            } catch {
                print("AppConfigStore: userCustomScale can't save to UserDefaults:", error)
            }
        }
    }
    
}
