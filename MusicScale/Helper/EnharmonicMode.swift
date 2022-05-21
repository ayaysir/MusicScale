//
//  EnharmonicMode.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/21.
//

import Foundation

enum EnharmonicMode: Int {
    case standard, sharpAndNatural, flatAndNatural, userCustom
    
    var noteStrOfFirstOctave: [NoteStrPair]? {
        switch self {
        case .standard:
            return nil
        case .sharpAndNatural:
            return [
                NoteStrPair("", "C"),
                NoteStrPair("^", "C"),
                NoteStrPair("", "D"),
                NoteStrPair("^", "D"),
                NoteStrPair("", "E"),
                NoteStrPair("", "F"),
                NoteStrPair("^", "F"),
                NoteStrPair("", "G"),
                NoteStrPair("^", "G"),
                NoteStrPair("", "A"),
                NoteStrPair("^", "A"),
                NoteStrPair("", "B"),
            ]
        case .flatAndNatural:
            return [
                NoteStrPair("", "C"),
                NoteStrPair("_", "D"),
                NoteStrPair("", "D"),
                NoteStrPair("_", "E"),
                NoteStrPair("", "E"),
                NoteStrPair("", "F"),
                NoteStrPair("_", "G"),
                NoteStrPair("", "G"),
                NoteStrPair("_", "A"),
                NoteStrPair("", "A"),
                NoteStrPair("_", "B"),
                NoteStrPair("", "B"),
            ]
        case .userCustom:
            return [
                NoteStrPair("", "C"),
                NoteStrPair("_", "D"),
                NoteStrPair("", "D"),
                NoteStrPair("^", "D"),
                NoteStrPair("", "E"),
                NoteStrPair("", "F"),
                NoteStrPair("^", "F"),
                NoteStrPair("", "G"),
                NoteStrPair("_", "A"),
                NoteStrPair("", "A"),
                NoteStrPair("_", "B"),
                NoteStrPair("", "B"),
            ]
        }
    }
}
