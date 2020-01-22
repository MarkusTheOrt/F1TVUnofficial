//
//  HeroView.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 11.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import UIKit


@objc protocol HeroViewDelegate{
    func showContentView(VC: UIViewController?)
}

@IBDesignable
class HeroView: UIView, HeroDelegate {
    var view: UIView!
    
    private var show: Show? = nil
   
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    @IBOutlet var delegate: HeroViewDelegate? = nil
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        ContentManager.shared.heroDelegate = self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        ContentManager.shared.heroDelegate = self
    }

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
    
        addSubview(view)
        self.view = view
        ContentManager.shared.loadHero()

    }

    
    func onHeroLoaded(data: HeroData) {
        // UI Stuff only on main thread
        DispatchQueue.main.sync{
            nameLabel.text = data.title
            synopsisLabel.text = data.synopsis
        }
        _ = Show(data.slug){(show) -> Void in
            
            self.show = show
            
        }
        
        DispatchQueue.global().async { [weak self] in
            if let vdata = try? Data(contentsOf: URL(string: data.imageUrl)!){
            if let image = UIImage(data: vdata){
                DispatchQueue.main.async{
                    UIView.transition(with: self!, duration: 1.0, options: .transitionCrossDissolve, animations: {
                        self?.backgroundImage.image = image
                        })
                    }
                }
            }
        }
        
        
        
        DispatchQueue.global().async{
            ShowSlugs.forEach({(slug) -> Void in
                _ = Show(slug){(show) -> Void in
                    shows.append(show)
                }
            })
        }
        
        _ = Season("/api/race-season/current"){(season) -> Void in
            let ev = season.events.first!
            ev.sessions.forEach(){(sess) -> Void in
                sess.resolve()
                print(sess.name)
                print(sess.type)
                print("================")
            }
        }
        
    }
    
    @IBAction func onPlayButtonPressed(_ sender: Any){
        
    
        VideoPlayer.shared.obtainVideoURL(epis: heroData)
        
    }
    
    @IBAction func onEpisodeButtonPressed(_ sender: Any){
        let VC = ContentViewController(nibName: "ContentViewController", bundle: nil);
        
        DispatchQueue.global().async{
            while(self.show == nil){}
            DispatchQueue.main.sync{
                VC.show = self.show
                self.delegate?.showContentView(VC: VC)
            }
            
        }
        
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
