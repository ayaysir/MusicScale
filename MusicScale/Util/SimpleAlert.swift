//
//  SimpleAlert.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/30.
//

import UIKit

func simpleAlert(_ controller: UIViewController, message: String) {
    let alertController = UIAlertController(title: "Caution", message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(alertAction)
    controller.present(alertController, animated: true, completion: nil)
}

func simpleAlert(_ controller: UIViewController, message: String, title: String, handler: ((UIAlertAction) -> Void)?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default, handler: handler)
    alertController.addAction(alertAction)
    controller.present(alertController, animated: true, completion: nil)
}

func simpleDestructiveYesAndNo(_ controller: UIViewController, message: String, title: String, yesHandler: ((UIAlertAction) -> Void)?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let alertActionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
    let alertActionYes = UIAlertAction(title: "Yes", style: .destructive, handler: yesHandler)
    alertController.addAction(alertActionNo)
    alertController.addAction(alertActionYes)
    controller.present(alertController, animated: true, completion: nil)
}

func simpleYesAndNo(_ controller: UIViewController, message: String, title: String, yesHandler: ((UIAlertAction) -> Void)?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let alertActionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
    let alertActionYes = UIAlertAction(title: "Yes", style: .default, handler: yesHandler)
    alertController.addAction(alertActionNo)
    alertController.addAction(alertActionYes)
    controller.present(alertController, animated: true, completion: nil)
}

func simpleActionSheets(_ controller: UIViewController, actionTitles: [String], actionStyles: [UIAlertAction.Style]? = nil, title: String, message: String = "", actionCompletion: @escaping (_ actionIndex: Int, _ alertController: UIAlertController) -> ()){
    let alertController = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
    
    for (index, actionTitle) in actionTitles.enumerated() {
        let action = UIAlertAction(title: actionTitle, style: actionStyles?[index] ?? .default, handler: { action in
            actionCompletion(index, alertController)
        })
        alertController.addAction(action)
    }
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    controller.present(alertController, animated: true, completion: nil)
}
