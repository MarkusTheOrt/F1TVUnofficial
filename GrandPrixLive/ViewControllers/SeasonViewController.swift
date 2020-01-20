//
//  SeasonViewController.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 11.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

class SeasonViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
