//
//  AccountViewController.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 28.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var AccountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !LoginManager.shared.loggedIn(){
            self.dismiss(animated: true)
        }
        AccountLabel.text = "Hello \(LoginManager.shared.firstName)"
        // Do any additional setup after loading the view.
    }

    
    @IBAction func onLogoutClicked(_ sender: Any){
        LoginManager.shared.logout()
        self.dismiss(animated: true)
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
