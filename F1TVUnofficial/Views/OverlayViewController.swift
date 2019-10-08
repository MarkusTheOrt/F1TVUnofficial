//
//  OverlayViewController.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 29.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit

class OverlayViewController: UIViewController, UITabBarDelegate{
    @IBOutlet weak var bar: UITabBar!

    
    
  
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        bar.addGestureRecognizer(tap)
        var i = 0
        for item in VideoPlayer.shared.asset.channels{
            if item["name"] == "WIF"{
                
                bar.items?.append(UITabBarItem(title: "Main Feed", image: nil, tag: i))
                i += 1
                continue;
            }
            else if item["name"] == "data"{
                bar.items?.append(UITabBarItem(title: "Data", image: nil, tag: i))
                i += 1;
                continue;
            }
            else if item["name"] == "driver"{
                bar.items?.append(UITabBarItem(title: "Driver Tracker", image: nil, tag: i))
                i += 1
                continue;
            }
            
            bar.items?.append(UITabBarItem(title: item["name"], image: nil, tag: i))
            i += 1;
        }
        // Do any additional setup after loading the view.
    }
    
    
    @objc func handleTap(){
         VideoPlayer.shared.changeToChannel(id: bar.selectedItem?.tag ?? 0)
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
