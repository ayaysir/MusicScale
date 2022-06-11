//
//  InitViewControllerFromStoryboard.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/07.
//

import UIKit

enum VCStoryboardID: String {
    case QuizIntroTableViewController = "QuizIntroTableViewController"
    case MatchKeysViewController = "MatchKeysViewController"
    case FlashcardsViewController = "FlashcardsViewController"
    case ScoreWebViewController = "ScoreWebViewController"
    case QuizFinishedViewController = "QuizFinishedViewController"
    case ScaleListTableViewController = "ScaleListTableViewController"
}

func initVCFromStoryboard(storyboardID: VCStoryboardID, storyboardName: String = "Main") -> UIViewController {
    return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: storyboardID.rawValue)
}
