//
//  VideoItemCell.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 17.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit

class VideoItemCell: UICollectionViewCell   {
    @IBOutlet weak var Thumbnail: UIImageView!

    
    var title: String!
    var imageUrl: String!
    var assetUrl: String!
    
    func configureCell(video: VideoFile ){
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: video.thumbnail)!){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async{
                        self?.Thumbnail.image = image
                    }
                }
            }
        }
        
    }
    
    

    
}
