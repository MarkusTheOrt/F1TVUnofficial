//
//  NoConnectionViewController.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 05.10.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit

class NoConnectionViewController: UIViewController {
    @IBOutlet weak var nextCheckLabel: UILabel!
    
    var group: DispatchGroup? = nil
    
    @IBAction func onTryAgain(){
        if (LoginManager.shared.loggedIn()){
            self.dismiss(animated: true);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var timer = Timer()
    func setTimer(){
        var i = 0;
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            var timerRunOut = false
            if i == 10 { i = 0; timerRunOut = true }
            if timerRunOut { self.onTryAgain() }
            self.nextCheckLabel.text = "Next check in \(10 - i) seconds";
        });
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
