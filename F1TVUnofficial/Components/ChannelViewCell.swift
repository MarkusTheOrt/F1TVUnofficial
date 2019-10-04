//
//  ChannelViewCell.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 04.10.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit

class ChannelViewCell: UICollectionViewCell {
    
    @IBOutlet weak var Bttn: UIButton!
    func setupCell(name: String){
        let btn = UIButton(type: .plain);
        self.addSubview(btn)
        btn.setTitle(name, for: .normal)
        
    }
    
}
