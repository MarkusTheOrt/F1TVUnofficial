//
//  ContentViewController.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 14.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var episLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var show: Show? = nil
    
    func fetchContent(slug: String){
        
        _ = Show(slug){(show) -> Void in
            self.show = show
            
            self.collectionView.reloadData()
            self.setNeedsFocusUpdate()
            self.updateFocusIfNeeded()
            
        }
        
    }
        
    func alreadyFetched(){
        self.collectionView.reloadData()
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.episLabel.text = self.show?.title ?? ""
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return show?.Episodes.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as? ContentCollectionViewCell{
            cell.Setup(epis: show?.Episodes[indexPath.row] ?? nil)
            return cell;
        }
        
        return ContentCollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        VideoPlayer.shared.obtainVideoURL(epis: (self.show?.Episodes[indexPath.row])!, VC: self)        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let focusIndex = context.nextFocusedIndexPath{
            if let vdata = try? Data(contentsOf: URL(string: (show?.Episodes[focusIndex.row].images.first!.url)!)!){
            if let image = UIImage(data: vdata){
                DispatchQueue.main.async{
                    UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
                        self.backgroundImage.image = image
                        self.episLabel.text = self.show?.Episodes[focusIndex.row].title
                        })
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: "ContentCell")
        collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContentCell")
        // Do any additional setup after loading the view.
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
