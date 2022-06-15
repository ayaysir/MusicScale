//
//  SearchDegreesReplaceAltText.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import Foundation

extension String {
    
    func erase(_ text: String) -> String {
        return self.replacingOccurrences(of: text, with: "")
    }
}

func replaceAltText(searchText: String) -> String {
    let regex = "[b#=][1-7]"
    
    if searchText.range(of: regex, options: .regularExpression) != nil {
        let result = searchText.replacingOccurrences(of: "b[1-7]", with: "\(xFlat)$0", options: .regularExpression)
            .replacingOccurrences(of: "#[1-7]", with: "\(xSharp)$0", options: .regularExpression)
            .replacingOccurrences(of: "=[1-7]", with: "\(xNatural)$0", options: .regularExpression)
            .replacingOccurrences(of: "♭b", with: "♭")
            .replacingOccurrences(of: "♯#", with: "♯")
            .replacingOccurrences(of: "♮=", with: "♮")
        return result
    }
    
    return searchText
}
