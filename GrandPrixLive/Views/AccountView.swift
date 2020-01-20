//
//  AccountView.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 11.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

@IBDesignable
class AccountView: UIView {
    var view: UIView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mail: UILabel!
    @IBOutlet weak var plan: UILabel!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
    
        addSubview(view)
        self.view = view
    }

    func updateData(){
        name.text = "\(userData.firstName) \(userData.lastName)"
        mail.text = userData.mail
        plan.text = userData.activeSubscription ? "Yes" : "No"
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
