//
//  SettingTableViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/16.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var viewBannerContainer: UIView!
    
    let playbackInstCell = IndexPath(row: 0, section: 0)
    let pianoInstCell = IndexPath(row: 1, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [unowned self] in
            setupBannerAds(self, container: viewBannerContainer)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case playbackInstCell:
            performSegue(withIdentifier: "InstrumentSegue", sender: InstrumentTableViewController.Place.playback)
        case pianoInstCell:
            performSegue(withIdentifier: "InstrumentSegue", sender: InstrumentTableViewController.Place.piano)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "InstrumentSegue":
            let selectVC = segue.destination as! InstrumentTableViewController
            let place = sender as! InstrumentTableViewController.Place
            selectVC.place = place
        default:
            break
        }
    }
}