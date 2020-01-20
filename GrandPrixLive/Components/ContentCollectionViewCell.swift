//
//  ContentCollectionViewCell.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 19.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    
    func Setup(epis: Episode?){
        if(epis == nil){
            return
        }
        if(epis?.images.first == nil){
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let vdata = try? Data(contentsOf: URL(string: (epis?.images.first!.url)!)!){
            if let image = UIImage(data: vdata){
               DispatchQueue.main.async{
                UIView.transition(with: self!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self?.image.image = image
                       })
                   }
               }
           }
       }
       
    }
    
    
}
