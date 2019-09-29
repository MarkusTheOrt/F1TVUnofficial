//
//  OverlayViewController.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 29.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit

class OverlayViewController: UIViewController, UITabBarDelegate {
    @IBOutlet weak var bar: UITabBar!
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Test")
        VideoPlayer.shared.changeToChannel(id: item.tag)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var i = 0
        for item in VideoPlayer.shared.asset.channels{
            if item["name"] == "WIF"{
                bar.items?.append(UITabBarItem(title: "Main Feed", image: nil, tag: i))
                i += 1
                continue;
            }
            bar.items?.append(UITabBarItem(title: item["name"], image: nil, tag: i))
            i += 1;
        }
        // Do any additional setup after loading the view.
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
