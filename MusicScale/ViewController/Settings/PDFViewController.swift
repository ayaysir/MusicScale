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
    case help, licenses, newFeatureAndShortcuts
  }
  var category: Category = .help
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = switch category {
    case .help:
      "HELP"
    case .licenses:
      "LICENSES"
    case .newFeatureAndShortcuts:
      "New Features & Shortcut Table"
    }
    
    let fileName = switch category {
    case .help:
      "MusicScale_ManualFileName".localized()
    case .licenses:
      "MusicScale Licenses"
    case .newFeatureAndShortcuts:
      "MusicScale - ShortcutTable - en".localized()
    }
    
    let url = Bundle.main.url(forResource: fileName, withExtension: "pdf")
    
    pdfView.autoScales = true
    pdfView.displayMode = .singlePageContinuous
    pdfView.displayDirection = .vertical
    pdfView.document = PDFDocument(url: url!)
  }
}
