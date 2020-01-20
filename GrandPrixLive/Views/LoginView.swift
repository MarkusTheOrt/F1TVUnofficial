//
//  LoginView.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 12.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

@IBDesignable
class LoginView: UIView, loginDelegate {
    
    var view: UIView!
    var isLoggingIn: Bool = false;
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        LoginManager.shared.delegate = self;
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        LoginManager.shared.delegate = self;
    }

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
    
        addSubview(view)
        self.view = view
    }

    
    @IBAction func onFormCompleted(_ sender: Any){
        if(!isLoggingIn){
            LoginManager.shared.Login(mail: mailField.text!, pass: passField.text!)
            isLoggingIn = true;
            loadingSpinner.startAnimating()
            mailField.isEnabled = false
            passField.isEnabled = false
        }
    }
    
    func loginSuccessful() {
        print(userData)
    }
    
    func loginError(string: String?) {
        print("LoginError: \(string ?? "")")
        isLoggingIn = false
        loadingSpinner.stopAnimating()
        mailField.isEnabled = true
        passField.isEnabled = true
    }
    
    func loginFinished() {
        print(userData)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
