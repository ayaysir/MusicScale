//
//  ScaleInfoViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/16.
//

import Foundation

class SimpleScaleInfoViewModel {
    
    fileprivate var scaleInfo: ScaleInfo
    fileprivate let helper = MusicSheetHelper()
    
    var currentKey: Music.Key
    var currentTempo: Double
    var currentOctaveShift: Int
    var currentEnharmonicMode: EnharmonicMode
    
    init(scaleInfo: ScaleInfo, currentKey: Music.Key, currentTempo: Double, currentOctaveShift: Int = 0, currentEnharmonicMode: EnharmonicMode = .standard) {
        self.scaleInfo = scaleInfo
        self.currentKey = currentKey
        self.currentTempo = currentTempo
        self.currentOctaveShift = currentOctaveShift
        self.currentEnharmonicMode = currentEnharmonicMode
    }
    
    // MARK: - current 변수의 변화와 무관
    var id: UUID {
        return scaleInfo.id
    }
    
    var name: String {
        return scaleInfo.name
    }
    
    var nameAlias: String {
        return scaleInfo.nameAlias
    }
    
    var defaultPriority: Int {
        return scaleInfo.defaultPriority
    }
    
    var myPriority: Int {
        return scaleInfo.myPriority
    }
    
    var isPriorityCustomized: Bool {
        if myPriority > 0 {
            return true
        }
        
        return false
    }
    
    var priorityForDisplayBoth: Int {
        // if myPriority <= 0 {
        //     return defaultPriority
        // }
        
        return isPriorityCustomized ? myPriority : defaultPriority
    }
    
    var comment: String {
        return scaleInfo.comment
    }
    
    var degreesAscending: String {
        return scaleInfo.degreesAscending
    }
    
    var degreesDescending: String {
        return scaleInfo.degreesDescending
    }
    
    var nameAliasFormatted: String {
        return scaleInfo.nameAlias.replacingOccurrences(of: ";", with: "\n")
    }
    
    var ascendingIntegerNotation: String? {
        let integersText = helper.getIntegerNotation(degrees: scaleInfo.degreesAscending, order: .ascending).map(String.init).joined(separator: ", ")
        return "(\(integersText))"
    }
    
    var ascendingIntegerNotationArray: [Int] {
        return helper.getIntegerNotation(degrees: scaleInfo.degreesAscending, order: .ascending, completeFinalNote: true)
    }
    
    var availableIntNoteArrayInDescOrder: [Int] {
        if isAscAndDescDifferent {
            return helper.getIntegerNotation(degrees: scaleInfo.degreesDescending, order: .descending, completeFinalNote: true).map { abs($0) }
        } else {
            return ascendingIntegerNotationArray
        }
    }
    
    var ascendingPattern: String? {
        do {
            return try helper.getPattern(degrees: scaleInfo.degreesAscending).map(String.init).joined(separator: " ")
        } catch {
            print(error)
            return nil
        }
    }
    
    var isAscAndDescDifferent: Bool {
        return scaleInfo.degreesDescending != "" && scaleInfo.degreesAscending != scaleInfo.degreesDescending
    }
    
    // MARK: - current 변수에 따라 변화되는 것
    
    var abcjsTextAscending: String {
        return helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, order: .ascending, key: currentKey, tempo: currentTempo, octaveShift: currentOctaveShift, enharmonicMode: currentEnharmonicMode)
    }
    
    var abcjsTextDescending: String {
        return helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, order: .descending, key: currentKey, tempo: currentTempo, octaveShift: currentOctaveShift, enharmonicMode: currentEnharmonicMode)
    }
    
    /// Flashcard용 악보
    func abcjsTextForFlashcard(isAscending: Bool) -> String {
        let order: DegreesOrder = isAscending ? .ascending : .descending
        let targetDegrees = helper.getTargetDegrees(scaleInfo: scaleInfo, order: order)
        let partText = helper.degreesToAbcjsPart(degrees: targetDegrees, order: order, completeFinalNote: true, key: currentKey, octaveShift: currentOctaveShift, enharmonicMode: currentEnharmonicMode)
        return helper.composeAbcjsText(scaleNameText: "???", tempo: currentTempo, partText: partText, lyricText: targetDegrees + " 🤔")
    }
    
    var playbackSemitoneAscending: [Int]? {
        return helper.getSemitoneToPlaybackNotes(scaleInfo: scaleInfo, order: .ascending, key: currentKey, octaveShift: currentOctaveShift)
    }
    
    var playbackSemitoneDescending: [Int]? {
        return helper.getSemitoneToPlaybackNotes(scaleInfo: scaleInfo, order: .descending, key: currentKey, octaveShift: currentOctaveShift)
    }
    
    var expectedPlayTime: Double {
        // t = 1 / b. Therefore: 1 min / 96 = 60,000 ms / 96 = 625 ms.
        return (60 / currentTempo) * Double(playbackSemitoneAscending!.count)
    }
    
    // MARK: - 편집용
    var abcjsTextForEditAsc: String {
        return helper.composeAbcjsText(scaleNameText: "C " + scaleInfo.name, tempo: 100, partText: helper.degreesToAbcjsPart(degrees: scaleInfo.degreesAscending, order: .ascending, completeFinalNote: false, key: .C, octaveShift: 0, enharmonicMode: .standard), lyricText: scaleInfo.degreesAscending)
    }
}

class ScaleInfoViewModel: SimpleScaleInfoViewModel {
    
    private let _entity: ScaleInfoEntity
    
    init(scaleInfo: ScaleInfo, currentKey: Music.Key, currentTempo: Double, currentOctaveShift: Int = 0, currentEnharmonicMode: EnharmonicMode = .standard, entity: ScaleInfoEntity) {
        
        self._entity = entity
        super.init(scaleInfo: scaleInfo, currentKey: currentKey, currentTempo: currentTempo, currentOctaveShift: currentOctaveShift, currentEnharmonicMode: currentEnharmonicMode)
    }
    
    /// CoreData entity가 업데이트되면 여기 내의 내용도 전부 바꾼다.
    func reloadInfoFromEntity() {
        guard let newScaleInfo = ScaleInfoCDService.shared.toScaleInfoStruct(from: entity) else {
            return
        }
        self.scaleInfo = newScaleInfo
    }
    
    // MARK: - current 변수의 변화와 무관
    var entity: ScaleInfoEntity {
        return _entity
    }
    
    // MARK: - update Core Data Entity
    func updateMyPriority(_ priority: Int) {
        entity.myPriority = Int16(priority)
        reloadInfoFromEntity()
        do {
            try ScaleInfoCDService.shared.saveManagedContext()
        } catch {
            print(#function, error)
        }
    }
}

// class ScaleInfoViewModel {
//
//     private var scaleInfo: ScaleInfo
//     private let _entity: ScaleInfoEntity
//     private let helper = MusicSheetHelper()
//
//     var currentKey: Music.Key
//     var currentTempo: Double
//     var currentOctaveShift: Int
//     var currentEnharmonicMode: EnharmonicMode
//
//     init(scaleInfo: ScaleInfo, currentKey: Music.Key, currentTempo: Double, currentOctaveShift: Int = 0, currentEnharmonicMode: EnharmonicMode = .standard, entity: ScaleInfoEntity) {
//         self.scaleInfo = scaleInfo
//         self.currentKey = currentKey
//         self.currentTempo = currentTempo
//         self.currentOctaveShift = currentOctaveShift
//         self.currentEnharmonicMode = currentEnharmonicMode
//         self._entity = entity
//     }
//
//     /// CoreData entity가 업데이트되면 여기 내의 내용도 전부 바꾼다.
//     func reloadInfoFromEntity() {
//         guard let newScaleInfo = ScaleInfoCDService.shared.toScaleInfoStruct(from: entity) else {
//             return
//         }
//         self.scaleInfo = newScaleInfo
//     }
//
//     // MARK: - current 변수의 변화와 무관
//     var id: UUID {
//         return scaleInfo.id
//     }
//
//     var entity: ScaleInfoEntity {
//         return _entity
//     }
//
//     var name: String {
//         return scaleInfo.name
//     }
//
//     var nameAlias: String {
//         return scaleInfo.nameAlias
//     }
//
//     var defaultPriority: Int {
//         return scaleInfo.defaultPriority
//     }
//
//     var myPriority: Int {
//         return scaleInfo.myPriority
//     }
//
//     var isPriorityCustomized: Bool {
//         if myPriority > 0 {
//             return true
//         }
//
//         return false
//     }
//
//     var priorityForDisplayBoth: Int {
//         // if myPriority <= 0 {
//         //     return defaultPriority
//         // }
//
//         return isPriorityCustomized ? myPriority : defaultPriority
//     }
//
//     var comment: String {
//         return scaleInfo.comment
//     }
//
//     var degreesAscending: String {
//         return scaleInfo.degreesAscending
//     }
//
//     var degreesDescending: String {
//         return scaleInfo.degreesDescending
//     }
//
//     var nameAliasFormatted: String {
//         return scaleInfo.nameAlias.replacingOccurrences(of: ";", with: "\n")
//     }
//
//     var ascendingIntegerNotation: String? {
//         let integersText = helper.getIntegerNotation(degrees: scaleInfo.degreesAscending, order: .ascending).map(String.init).joined(separator: ", ")
//         return "(\(integersText))"
//     }
//
//     var ascendingIntegerNotationArray: [Int] {
//         return helper.getIntegerNotation(degrees: scaleInfo.degreesAscending, order: .ascending, completeFinalNote: true)
//     }
//
//     var availableIntNoteArrayInDescOrder: [Int] {
//         if isAscAndDescDifferent {
//             return helper.getIntegerNotation(degrees: scaleInfo.degreesDescending, order: .descending, completeFinalNote: true).map { abs($0) }
//         } else {
//             return ascendingIntegerNotationArray
//         }
//     }
//
//     var ascendingPattern: String? {
//         do {
//             return try helper.getPattern(degrees: scaleInfo.degreesAscending).map(String.init).joined(separator: " ")
//         } catch {
//             print(error)
//             return nil
//         }
//     }
//
//     var isAscAndDescDifferent: Bool {
//         return scaleInfo.degreesDescending != "" && scaleInfo.degreesAscending != scaleInfo.degreesDescending
//     }
//
//     // MARK: - current 변수에 따라 변화되는 것
//     // var abcjsPart: String {
//     //     helper.degreesToAbcjsPart(degrees: scaleInfo.degreesAscending)
//     // }
//     //
//     // var abcjsLyric: String {
//     //     helper.degreesToAbcjsLyric(degrees: scaleInfo.degreesAscending)
//     // }
//
//     var abcjsTextAscending: String {
//         return helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, order: .ascending, key: currentKey, tempo: currentTempo, octaveShift: currentOctaveShift, enharmonicMode: currentEnharmonicMode)
//     }
//
//     var abcjsTextDescending: String {
//         return helper.scaleInfoToAbcjsText(scaleInfo: scaleInfo, order: .descending, key: currentKey, tempo: currentTempo, octaveShift: currentOctaveShift, enharmonicMode: currentEnharmonicMode)
//     }
//
//     var playbackSemitoneAscending: [Int]? {
//         return helper.getSemitoneToPlaybackNotes(scaleInfo: scaleInfo, order: .ascending, key: currentKey, octaveShift: currentOctaveShift)
//     }
//
//     var playbackSemitoneDescending: [Int]? {
//         return helper.getSemitoneToPlaybackNotes(scaleInfo: scaleInfo, order: .descending, key: currentKey, octaveShift: currentOctaveShift)
//     }
//
//     var expectedPlayTime: Double {
//         // t = 1 / b. Therefore: 1 min / 96 = 60,000 ms / 96 = 625 ms.
//         return (60 / currentTempo) * Double(playbackSemitoneAscending!.count)
//     }
//
//     // MARK: - 편집용
//     var abcjsTextForEditAsc: String {
//         return helper.composeAbcjsText(scaleNameText: "C " + scaleInfo.name, tempo: 100, partText: helper.degreesToAbcjsPart(degrees: scaleInfo.degreesAscending, order: .ascending, completeFinalNote: false, key: .C, octaveShift: 0, enharmonicMode: .standard), lyricText: scaleInfo.degreesAscending)
//     }
//
//     // MARK: - update Core Data Entity
//     func updateMyPriority(_ priority: Int) {
//         entity.myPriority = Int16(priority)
//         reloadInfoFromEntity()
//         do {
//             try ScaleInfoCDService.shared.saveManagedContext()
//         } catch {
//             print(#function, error)
//         }
//     }
// }
