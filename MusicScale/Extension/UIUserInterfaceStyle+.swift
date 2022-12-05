//
//  UIUserInterfaceStyle+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/12/05.
//

import Foundation
import UIKit

extension UIUserInterfaceStyle {
    private var text: String {
        switch self {
        case .unspecified:
            return "Use device theme"
        case .light:
            return "Light theme"
        case .dark:
            return "Dark theme"
        @unknown default:
            return "unknown"
        }
    }
    
    private var emoji: String {
        switch self {
        case .unspecified:
            return "📱"
        case .light:
            return "☀️"
        case .dark:
            return "🌒"
        @unknown default:
            return "🤨"
        }
    }
    
    var menuText: String {
        return "\(emoji) \(text.localized())"
    }
    
    func overrideAllWindow() {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = self
        }
    }
}
