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
        
        print("group 1")
        break
        
    case
        is MatchKeysViewController,
        is FlashcardsViewController,
        is QuizInProgressViewController,
        is QuizFinishedViewController,
        is QuizIntroTableViewController:
        
        print("group 2")
        break
        
    case
        is ArchiveMainTableViewController,
        is ArchiveDetailTableViewController:
        
        print("group 3")
        break
        
    case
        is SettingTableViewController,
        is EnharmonicSelectTableViewController,
        is InstrumentTableViewController:
        
        print("group 4")
        break
        
    default:
        break
    }
    
    // return default test ad id
    return "ca-app-pub-3940256099942544/2934735716"
}
