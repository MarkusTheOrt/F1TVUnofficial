//
//  HomeViewController.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 11.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, HeroViewDelegate {    

    override func viewDidLoad() {
        super.viewDidLoad()
        VideoPlayer.shared.context = self
        // Do any additional setup after loading the view.
    }

    func showContentView(VC: UIViewController?) {
        self.present(VC!, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        VideoPlayer.shared.context = self
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
