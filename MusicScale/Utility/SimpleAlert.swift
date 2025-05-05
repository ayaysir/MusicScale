//
//  SimpleAlert.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/30.
//

import UIKit

fileprivate let CAUTION = "Caution".localized()
fileprivate let OK = "OK".localized()
fileprivate let NO = "No".localized()
fileprivate let YES = "Yes".localized()
fileprivate let CANCEL = "Cancel".localized()

func simpleAlert(_ controller: UIViewController, message: String) {
  let alertController = UIAlertController(title: CAUTION, message: message, preferredStyle: .alert)
  let alertAction = UIAlertAction(title: OK, style: .default, handler: nil)
  alertController.addAction(alertAction)
  controller.present(alertController, animated: true, completion: nil)
}

func simpleAlert(
  _ controller: UIViewController,
  message: String,
  title: String,
  handler: ((UIAlertAction) -> Void)? = nil
) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let alertAction = UIAlertAction(title: OK, style: .default, handler: handler)
  alertController.addAction(alertAction)
  controller.present(alertController, animated: true, completion: nil)
}

func simpleDestructiveYesAndNo(_ controller: UIViewController, message: String, title: String, yesHandler: ((UIAlertAction) -> Void)?) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let alertActionNo = UIAlertAction(title: NO, style: .cancel, handler: nil)
  let alertActionYes = UIAlertAction(title: YES, style: .destructive, handler: yesHandler)
  alertController.addAction(alertActionNo)
  alertController.addAction(alertActionYes)
  controller.present(alertController, animated: true, completion: nil)
}

func simpleYesAndNo(_ controller: UIViewController, message: String, title: String, yesHandler: ((UIAlertAction) -> Void)?) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let alertActionNo = UIAlertAction(title: NO, style: .cancel, handler: nil)
  let alertActionYes = UIAlertAction(title: YES, style: .default, handler: yesHandler)
  alertController.addAction(alertActionNo)
  alertController.addAction(alertActionYes)
  controller.present(alertController, animated: true, completion: nil)
}

func simpleActionSheets(_ controller: UIViewController, actionTitles: [String], actionStyles: [UIAlertAction.Style]? = nil, title: String, message: String = "", sourceView: UIView?, sourceRect: CGRect?, actionCompletion: @escaping (_ actionIndex: Int) -> ()){
  let alertController = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
  alertController.modalPresentationStyle = .popover
  for (index, actionTitle) in actionTitles.enumerated() {
    let action = UIAlertAction(title: actionTitle, style: actionStyles?[index] ?? .default, handler: { action in
      actionCompletion(index)
    })
    alertController.addAction(action)
  }
  
  alertController.addAction(UIAlertAction(title: CANCEL, style: .cancel, handler: nil))
  if let presenter = alertController.popoverPresentationController {
    presenter.sourceView = sourceView ?? controller.view.window
    presenter.sourceRect = sourceRect ?? CGRect(x: 0, y: 0, width: 0, height: 0)
  }
  controller.present(alertController, animated: true, completion: nil)
}
