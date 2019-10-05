//
//  SeasonSelectViewController.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 30.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit

protocol EventSelectDelegate{
    func OnNewEvent(_ event: EventMinimal)
}

class SeasonSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, CMDelegate {
    
    var delegate: EventSelectDelegate?
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var events: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        indicator.startAnimating()
        DispatchQueue.global().async{
             self.season = ContentManager.shared.GetSeasons()[item.tag];
             
             _ = ContentManager.shared.getGrandPrixforSeason(season: self.season!)
        }
       
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContentManager.shared.delegate = self
        self.tabBar.isUserInteractionEnabled = false
        DispatchQueue.global().async {
            let seasons = ContentManager.shared.GetSeasons()
                   var i = 0;
                   var tabItems: [UITabBarItem] = []
                   for season in seasons{
                       if !season.hasContent { i += 1; continue }
                       
                       tabItems.append(UITabBarItem(title: String(season.year), image: nil, tag: i))
                       i += 1;
                   }
            DispatchQueue.main.sync{
                self.tabBar.items = tabItems
                self.tabBar.isUserInteractionEnabled = true
                if ContentManager.shared.lastSelectedYear == 0{
                    self.tabBar.selectedItem = self.tabBar.items?.first!
                    ContentManager.shared.lastSelectedYear = self.tabBar.selectedItem!.tag;
                }else{
                    for item in self.tabBar.items!{
                        if item.tag == ContentManager.shared.lastSelectedYear{
                            self.tabBar.selectedItem = item;
                            break;
                        }
                    }
                }
            }
            
        }
       
        
        // Do any additional setup after loading the view.
    }
    
    var sessions: [EventMinimal] = []
    var season: SeasonMinimal? = nil
    
    func onSeasonLoaded(_ events: [EventMinimal]) {
        self.sessions = events.sorted(by: {$0.date > $1.date})
        
        DispatchQueue.main.sync{
            UIView.transition(with: self.events, duration: 1.0, options: .transitionCrossDissolve, animations: {() -> Void in
                self.events.reloadData()
            })
            
            indicator.stopAnimating()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        delegate?.OnNewEvent(sessions[indexPath.row])
        ContentManager.shared.lastSelectedYear = self.tabBar.selectedItem!.tag;
        self.dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = sessions[indexPath.row].name;
        if sessions[indexPath.row].date > Date(){
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
