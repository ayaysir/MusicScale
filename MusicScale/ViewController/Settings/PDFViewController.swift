//
//  WebViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/23.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    @IBOutlet weak var pdfView: PDFView!
    
    enum Category {
        case help, licenses
    }
    var category: Category = .help
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = category == .help ? "HELP" : "LICENSES"
        
        let fileName = category == .help ? "MusicScale_ManualFileName".localized() : "MusicScale Licenses"
        let url = Bundle.main.url(forResource: fileName, withExtension: "pdf")
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(url: url!)
    }
}
