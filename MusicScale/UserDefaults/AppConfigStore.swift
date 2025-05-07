//
//  AppConfigStore.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/03.
//

import Foundation

struct AppConfigStore: UserDefaultsConfigurator {
  
  mutating func initalizeConfigValueOnFirstrun() {
    playbackInstrument = 5
    pianoInstrument = 5
    userCustomScale = [
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
    
    appAppearance = 0
    isShowHWKeyboardMapping = false
  }
  
  
  static var shared = AppConfigStore()
  private let store = UserDefaults.standard
  
  var playbackInstrument: Int {
    get {
      let value = store.integer(forKey: .cfgAppPlaybackInstrument)
      return value >= 0 ? value : 5
    } set {
      store.set(newValue, forKey: .cfgAppPlaybackInstrument)
    }
  }
  
  var pianoInstrument: Int {
    get {
      let value = store.integer(forKey: .cfgAppPianoInstrument)
      return 0...127 ~= value ? value : 5
    } set {
      store.set(newValue, forKey: .cfgAppPianoInstrument)
    }
  }
  
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
  
  private let availableEnharmonicList: [Int: [NoteStrPair]] = [
    2: [
      NoteStrPair("^", "C"),
      NoteStrPair("_", "D"),
    ],
    4: [
      NoteStrPair("^", "D"),
      NoteStrPair("_", "E"),
    ],
    7: [
      NoteStrPair("^", "F"),
      NoteStrPair("_", "G"),
    ],
    9: [
      NoteStrPair("^", "G"),
      NoteStrPair("_", "A"),
    ],
    11: [
      NoteStrPair("^", "A"),
      NoteStrPair("_", "B"),
    ]
  ]
  
  func availableEnharmonicNotes(_ number: Int) -> [NoteStrPair]? {
    return availableEnharmonicList[number]
  }
  
  var appAppearance: Int {
    get { return store.integer(forKey: .cfgAppAppearance) }
    set { store.set(newValue, forKey: .cfgAppAppearance) }
  }
  
  var isShowHWKeyboardMapping: Bool {
    get { store.bool(forKey: .cfgAppIsShowHWKeyboardMapping) }
    set { store.set(newValue, forKey: .cfgAppIsShowHWKeyboardMapping) }
  }
}
