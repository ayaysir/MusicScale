//
//  OnlyFirstRun.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/21.
//

import Foundation
import AppTrackingTransparency

func checkAppFirstrunOrUpdateStatus(firstrun: () -> (), updated: () -> (), nothingChanged: () -> ()) {
    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let versionOfLastRun = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
    print(#function, currentVersion ?? "", versionOfLastRun ?? "")

    if versionOfLastRun == nil {
        // First start after installing the app
        firstrun()

    } else if versionOfLastRun != currentVersion {
        // App was updated since last run
        updated()

    } else {
        // nothing changed
        nothingChanged()
    }

    UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
    UserDefaults.standard.synchronize()
}

func setConfigValueOnFirstrun() {
    userDefaultsConfiguratorList.forEach { instance in
        var instance = instance
        instance.initalizeConfigValueOnFirstrun()
    }
}

func TrackingTransparencyPermissionRequest() {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            print("requestTrackingAuthorization status:", status)
        })
    }
}
