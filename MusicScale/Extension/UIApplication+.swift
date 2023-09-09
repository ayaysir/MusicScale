//
//  UIApplication+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/14.
//

import UIKit

extension UIApplication {
    
    // https://g-y-e-o-m.tistory.com/93
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
