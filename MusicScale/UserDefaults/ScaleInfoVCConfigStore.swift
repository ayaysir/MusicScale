//
//  ScaleInfoVCConfigStore.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/21.
//

import Foundation

struct ScaleInfoVCConfigStore: UserDefaultsConfigurator {
  
  static var shared = ScaleInfoVCConfigStore()
  private let store = UserDefaults.standard
  
  mutating func initalizeConfigValueOnFirstrun() {
    degreesOrder = .ascending
    octaveShift = 0
    tempo = 120
    transpose = "C"
    enharmonicMode = .standard
    customEnharmonics = EnharmonicMode.userCustom.noteStrOfFirstOctave!
    keyPressModeOnStrictMode = .singleTouchOnly
  }
  
  var degreesOrder: DegreesOrder {
    get {
      return store.bool(forKey: .kDegreesOrder) ? .ascending : .descending
    } set {
      store.set(newValue == .ascending, forKey: .kDegreesOrder)
    }
  }
  
  var octaveShift: Int {
    get {
      return store.integer(forKey: .kOctaveShift)
    } set {
      store.set(newValue, forKey: .kOctaveShift)
    }
  }
  
  var tempo: Double {
    get {
      return store.double(forKey: .kTempo)
    } set {
      store.set(newValue, forKey: .kTempo)
    }
  }
  
  var transpose: String? {
    get {
      return store.string(forKey: .kTranspose)
    } set {
      store.set(newValue, forKey: .kTranspose)
    }
  }
  
  var enharmonicMode: EnharmonicMode {
    get {
      let storedRawValue = store.integer(forKey: .kEnharmonicMode)
      return EnharmonicMode(rawValue: storedRawValue)!
    } set {
      store.set(newValue.rawValue, forKey: .kEnharmonicMode)
    }
  }
  
  var customEnharmonics: [NoteStrPair] {
    get {
      do {
        return try store.getObject(forKey: .kCustomEnharmonics, castTo: [NoteStrPair].self)
      } catch {
        print(error)
        return EnharmonicMode.sharpAndNatural.noteStrOfFirstOctave!
      }
    } set {
      do {
        try store.setObject(newValue, forKey: .kCustomEnharmonics)
      } catch {
        print(error)
      }
    }
  }
  
  var keyPressModeOnStrictMode: PianoViewController.KeyPressMode {
    get {
      let storedValue = store.integer(forKey: .kKeyPressMode)
      return PianoViewController.KeyPressMode(rawValue: storedValue) ?? .singleTouchOnly
    }
    set {
      store.set(newValue.rawValue, forKey: .kKeyPressMode)
    }
  }
  
  func printCurrentStore() {
    print("======\(#function)======")
    print("degressOrder:", degreesOrder)
    print("octaveShift:", octaveShift)
    print("tempo:", tempo)
    print("transpose:", transpose ?? "?")
    print("enharmonicMode:", enharmonicMode)
    print("customEnharmonics", customEnharmonics)
    print("========================")
  }
}
