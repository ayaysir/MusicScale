//
//  WebMusicSheetHelper.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/25.
//

import Foundation

/// abcjs 텍스트를 웹에서 실행할 수 있게 래핑함, 이것을 유저 스크립트로 wkView에 전송.
func generateAbcJsInjectionSource(from abcjsText: String) -> String {
    return "onRender('\(abcjsText.replacingOccurrences(of: "\n", with: "\\n"))');"
}

/// 쌍따옴표 크래시 문제 해결
func charFixedAbcjsText(_ abcjsText: String) -> String {
    return abcjsText.replacingOccurrences(of: "'", with: "\\'")
}
