//
//  ScaleInfoViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/05/14.
//

import UIKit

class ScaleInfoViewController: UIViewController {
    
    @IBOutlet weak var containerViewInfo: UIView!
    @IBOutlet weak var containerViewSheetWeb: UIView!
    @IBOutlet weak var containerViewPiano: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
//            let array = try ScaleInfoCDService.shared.readCoreData()
//            array[0].comment = "eeeeeee"
//            array[1].comment = "fffffff"
//            try ScaleInfoCDService.saveManagedContext()
//            print(ScaleInfoCDService.shared.printScaleInfoEntity(array: array))
        } catch {
            print(error)
        }
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
