//
//  AccountViewController.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 11.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, viewDelegate {
    @IBOutlet weak var loginview: LoginView!
    @IBOutlet weak var accountview: AccountView!
    
    var loggedIn: Bool = false
    
    func nowLoginView() {
        DispatchQueue.main.sync{
            loggedIn = true
            setViewVisibility()
        }
        
    }
    
    func setViewVisibility(){
        loginview.isHidden = loggedIn
        accountview.isHidden = !loggedIn
        accountview.updateData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        LoginManager.shared.vdelegate = self
        if(userData.JWT.count > 0){
            loggedIn = true;
            setViewVisibility()
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        if(userData.JWT.count > 0){
            loggedIn = true;
            setViewVisibility()
        }
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
