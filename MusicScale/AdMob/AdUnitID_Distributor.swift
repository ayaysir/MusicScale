//
//  AdUnitID_Distributor.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/20.
//

import Foundation

func adUnitIDDistributor(_ instance: NSObject) -> String {
    /*
     
     1.
     - ScaleList TVC
     - ScaleSubInfo TVC
     - ScaleInfoUpdate TVC
     
     2.
     - MatchKeys VC
     - Flashcards VC
     - QuizInProgress VC
     - QuizFinished VC
     - QuizIntro TVC
     
     3.
     - ArchiveMain TVC
     - ArchiveDetail TVC
     
     4.
     - Setting TVC
     - Enharmonic TVC
     - Instrument TVC
     */
    
    switch instance {
        
    case
        is ScaleListTableViewController,
        is ScaleSubInfoTableViewController,
        is ScaleInfoUpdateTableViewController:
        
        return "ca-app-pub-6364767349592629/8826386168"
        
    case
        is MatchKeysViewController,
        is FlashcardsViewController,
        is QuizInProgressViewController,
        is QuizFinishedViewController,
        is QuizIntroTableViewController:
        
        return "ca-app-pub-6364767349592629/3574059480"
        
    case
        is ArchiveMainTableViewController,
        is ArchiveDetailTableViewController:
        
        return "ca-app-pub-6364767349592629/2069406129"
        
    case
        is SettingTableViewController,
        is EnharmonicSelectTableViewController,
        is InstrumentTableViewController:
        
        return "ca-app-pub-6364767349592629/1877834439"
        
    default:
        break
    }
    
    // return default test ad id
    return "ca-app-pub-3940256099942544/2934735716"
}
