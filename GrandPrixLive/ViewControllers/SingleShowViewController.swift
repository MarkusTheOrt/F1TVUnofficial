//
//  SingleShowViewController.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 20.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

class SingleShowViewController: UIViewController {

    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var show: Show? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(show != nil){
            Setup(show: show!)
        }

        // Do any additional setup after loading the view.
    }
    
    func Setup(show: Show){
        nameLabel.text = show.title
        self.show = show
      
        if let vdata = try? Data(contentsOf: URL(string: (show.Episodes.first?.images.first!.url)!)!){
        if let image = UIImage(data: vdata){
            DispatchQueue.main.async{
                UIView.transition(with: self.backgroundImage, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    self.backgroundImage.image = image
                    })
                }
            }
        }
        
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
