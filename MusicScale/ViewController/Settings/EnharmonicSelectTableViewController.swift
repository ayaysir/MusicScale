//
//  EnharmonicSelectViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import UIKit

class EnharmonicSelectTableViewController: UITableViewController {

    private var configStore = AppConfigStore.shared
    private let tradKeys = ["C", "D", "E", "F", "G", "A", "B"]

    @IBOutlet weak var colViewNoteList: UICollectionView!
    @IBOutlet weak var colViewAvaliableNotes: UICollectionView!
    @IBOutlet weak var viewBannerContainer: UIView!
    
    private var tempUserCustomScale: [NoteStrPair] = []
    private var currentSelectedNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            setupBannerAds(self, container: self.viewBannerContainer)
        }
        
        colViewNoteList.delegate = self
        colViewNoteList.dataSource = self
        
        colViewAvaliableNotes.delegate = self
        colViewAvaliableNotes.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tempUserCustomScale = AppConfigStore.shared.userCustomScale
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        configStore.userCustomScale = tempUserCustomScale
    }
    
    private func strPairToMusiqwikNotation(_ pair: NoteStrPair, forceNatural: Bool = false) -> String {
        let noteIndex: Int = tradKeys.firstIndex(of: pair.noteStr)!
        let notePart = String(UnicodeScalar(114 + noteIndex)!)
        
        var accidentalStartIndex: Int!
        if pair.prefix == "" && !forceNatural {
            return "=\(notePart)"
        } else if pair.prefix == "" && forceNatural {
            accidentalStartIndex = 242
        } else if pair.prefix == "^" {
            accidentalStartIndex = 210
        } else {
            accidentalStartIndex = 226
        }
        
        let accidentalPart = String(UnicodeScalar(accidentalStartIndex + noteIndex)!)
        return accidentalPart + notePart
    }
    
    private func forceNatural(indexPath: IndexPath, currPair: NoteStrPair) -> Bool {
        guard indexPath.row != 0 else { return false }
        
        let prevPair = tempUserCustomScale[indexPath.row - 1]
        let prevPairHasAccidental = prevPair.prefix != ""
        let currPairHasNatural = currPair.prefix == ""
        return prevPairHasAccidental && currPairHasNatural && prevPair.noteStr == currPair.noteStr
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 0, section: 0) {
            return UITableView.automaticDimension
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
}

extension EnharmonicSelectTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case colViewNoteList:
            return tempUserCustomScale.count
        case colViewAvaliableNotes:
            guard let number = currentSelectedNumber else {
                break
            }
            
            return configStore.availableEnharmonicNotes(number)?.count ?? 0
        default:
            break
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case colViewNoteList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteSelectCell", for: indexPath) as? EnharmonicNoteSelectCell else {
                return UICollectionViewCell()
            }
            
            let pair = tempUserCustomScale[indexPath.row]
            let forceNatural = forceNatural(indexPath: indexPath, currPair: pair)
            let value = strPairToMusiqwikNotation(pair, forceNatural: forceNatural)
            
            cell.configure(number: indexPath.row + 1, musiqwikNotation: "=\(value)==")
            return cell
        case colViewAvaliableNotes:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvailableNoteCell", for: indexPath) as? AvailableNoteCell else {
                return UICollectionViewCell()
            }
            
            if let number = currentSelectedNumber {
                let pair = configStore.availableEnharmonicNotes(number)![indexPath.row]
                let value = strPairToMusiqwikNotation(pair)
                cell.configure(musiqwikNotation: "=\(value)==", pair: pair, number: number)
                cell.setBorder = pair == tempUserCustomScale[number - 1]
            }
            
            return cell
        default:
            break
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case colViewNoteList:
            let number = indexPath.row + 1
            if configStore.availableEnharmonicNotes(number) != nil {
                currentSelectedNumber = number
            } else {
                currentSelectedNumber = nil
            }
            
            colViewAvaliableNotes.reloadData()
        case colViewAvaliableNotes:
            let cell = collectionView.cellForItem(at: indexPath) as! AvailableNoteCell
            let arrayIndex = cell.number - 1
            tempUserCustomScale[arrayIndex] = cell.pair
            print(tempUserCustomScale[arrayIndex])
            colViewNoteList.reloadData()
            colViewAvaliableNotes.reloadData()
        default:
            break
        }
    }
}

class EnharmonicNoteSelectCell: UICollectionViewCell {
    
    @IBOutlet weak var lblNumberNotation: UILabel!
    @IBOutlet weak var lblStaffNotation: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = UIColor.red.cgColor
                self.layer.borderWidth = 3.5
            } else {
                self.layer.borderColor = nil
                self.layer.borderWidth = 0.0
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(number: Int, musiqwikNotation: String) {
        lblNumberNotation.text = "\(number)"
        lblNumberNotation.clipsToBounds = true
        lblNumberNotation.layer.cornerRadius = 5
        lblStaffNotation.text = musiqwikNotation
        
        if AppConfigStore.shared.availableEnharmonicNotes(number) != nil {
            lblNumberNotation.backgroundColor = .systemOrange
        } else {
            lblNumberNotation.backgroundColor = .opaqueSeparator
        }
    }
}

class AvailableNoteCell: UICollectionViewCell {
    
    @IBOutlet weak var lblStaffNotation: UILabel!
    
    private(set) var pair: NoteStrPair!
    private(set) var number: Int!
    
    var setBorder: Bool = false {
        didSet {
            if setBorder {
                self.layer.borderColor = UIColor.red.cgColor
                self.layer.borderWidth = 4.0
            } else {
                self.layer.borderColor = UIColor.systemGray4.cgColor
                self.layer.borderWidth = 4.0
            }
        }
    }
    
    func configure(musiqwikNotation: String, pair: NoteStrPair, number: Int) {
        self.pair = pair
        self.number = number
        lblStaffNotation.text = musiqwikNotation
    }
    
}
