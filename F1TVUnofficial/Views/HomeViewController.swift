//
//  HomeViewController.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 17.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit
import AVKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, loginDelegate, EventSelectDelegate, GPEventDelegate {
    
    func onLoginError(_ message: String) {
        
    }
    
    func onLoginSuccess() {
        
    }
    
    
    @IBOutlet weak var LoginButton : UIButton!
    @IBOutlet weak var CurrentGP : UILabel!
    @IBOutlet weak var NextSession : UILabel!
    @IBOutlet weak var VideoList : UICollectionView!
    @IBOutlet weak var PosterImage: UIImageView!
    @IBOutlet weak var SessionButton: UIButton!
    @IBOutlet weak var SelectedVideo: UILabel!
    @IBOutlet weak var EventBtn: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    var buttonFile = VideoFile()
    
    var videos:[VideoFile] = []
    

    required init?(coder: NSCoder){
        super.init(coder: coder)
        LoginManager.shared.delegate = self
        GPEvents.shared.delegate = self
        
        let initGroup = DispatchGroup()
        
        initGroup.enter()
        DispatchQueue.global().async{
            _ = HomeContent(){(event) -> Void in
                if event == nil{
                    //initGroup.leave()
                    return;
                }
                self.updateHomeItems(event: event!, group: initGroup)
                initGroup.leave()
            }
        }
        
        initGroup.wait()
        
    }
    
    
    func onGPLoaded() {
        GPEvents.shared.episodes = GPEvents.shared.episodes.sorted(by: {$0.date > $1.date});
        
        DispatchQueue.main.sync{
            self.VideoList.reloadData()
            self.ActivityIndicator.stopAnimating()
            UIView.transition(with: self.VideoList, duration: 1.0, options: .transitionCrossDissolve, animations: {
                self.VideoList.isHidden = false
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  GPEvents.shared.episodes.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoItemCell{
            if GPEvents.shared.episodes.count < indexPath.row{
                return cell;
            }
            cell.configureCell(video: GPEvents.shared.episodes[indexPath.row])
            
            return cell
        }
        
        
        
        return VideoItemCell()
        
    }
    var homeEvent = Event()
    var timer = Timer()
    
    func OnNewEvent(_ event: EventMinimal) {
        self.EventBtn.setTitle(event.name, for: .normal)
        self.ActivityIndicator.startAnimating()
        UIView.transition(with: self.VideoList, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.VideoList.isHidden = true
            self.SelectedVideo.text = ""
            
        })
        DispatchQueue.global().async{
            GPEvents.shared.getEvents(eventStr: event.this)
        }
    }
    
    
    func HomeTimer(){
       self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: {(event) -> Void in
        DispatchQueue.global().async {
            
            _ = HomeContent(){(homeItems) -> Void in
                var needsUpdated = false
                if(self.homeEvent.this == homeItems!.this){
                    for session in homeItems!.sessions{
                        for homeSession in self.homeEvent.sessions{
                            if(session.this == homeSession.this){
                                if(session.status != homeSession.status){
                                    needsUpdated = true
                                }
                            }
                        }
                    }
                }else{
                    needsUpdated = true
                }
                if(needsUpdated){
                    self.updateHomeItems(event: homeItems!, group: nil)
                }
            }
        }
       })
        
    }
    
    func updateHomeItems(event: Event, group: DispatchGroup?){
        if(event.image.isEmpty){
            return;
        }
        group?.enter()
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: event.image)!){
                if let image = UIImage(data: data){
                    group?.leave()
                    DispatchQueue.main.async{
                        UIView.transition(with: self!.PosterImage, duration: 1.0, options: .transitionCrossDissolve, animations: {
                            self?.PosterImage.image = image
                        })
                        
                        
                        
                    }
                }
            }
        }
        
        DispatchQueue.global().async {
            self.homeEvent = event
            
            GPEvents.shared.getEvents(eventStr: event.this)
            var replaySessions: [Session] = []
            var upcomingSessions: [Session] = []
            var liveSession: Session = Session()
            for session in event.sessions{
                if(session.status == "replay"){
                    replaySessions.append(session)
                }
                if(session.status == "upcoming"){
                    upcomingSessions.append(session)
                }
                if(session.status == "live"){
                    liveSession = session
                }
            }
            replaySessions = replaySessions.sorted(by: {$0.startTime > $1.startTime});
            upcomingSessions = upcomingSessions.sorted(by: {$0.startTime < $1.startTime});
            DispatchQueue.main.sync{
                UIView.transition(with: self.CurrentGP, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    
                    self.CurrentGP.text = event.name
                    
                    if(upcomingSessions.count > 0){
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMM HH:mm"
                        
                        self.NextSession.text = upcomingSessions.first!.name + " starts at " + formatter.string(from: upcomingSessions.first!.startTime)
                    }
                    if(replaySessions.count > 0){
                        let lastSession = replaySessions.first!
                        self.SessionButton.setTitle(lastSession.name + " Replay", for: .normal)
                        self.SessionButton.isEnabled = true
                        self.SessionButton.isHidden = false
                        self.buttonFile = VideoFile(title: lastSession.name, assetType: "Replay", channels: lastSession.replays)
                    }
                    if liveSession.name != ""{
                        
                        self.SessionButton.setTitle(liveSession.name, for: .normal)
                        self.SessionButton.isEnabled = true
                        self.SessionButton.isHidden = false
                        self.buttonFile = VideoFile(title: liveSession.name, assetType: "Live", channels: liveSession.replays)
                        
                        
                    }
                    
                    self.EventBtn.setTitle(event.officialName, for: .normal)
                }, completion: nil)
            }
            
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 340, height: 240)
    }
    
    func DownloadSeasonItems(){
        
    }
    
    func DownloadHomeSets(){
        _ = HomeContent(){(event) -> Void in
            self.updateHomeItems(event: event!, group: nil)
            
            
        }
        
        
    }
    
    func checkLoggedIn(){
        if !LoginManager.shared.loggedIn() ||
            UserDefaults.standard.object(forKey: "user") == nil ||
            UserDefaults.standard.object(forKey: "pass") == nil{
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil);
            let controller = storyBoard.instantiateViewController(withIdentifier: "LVC") as! LoginViewController
            
            self.present(controller, animated: true)
            return;
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoginManager.shared.delegate = self
        //DownloadSeasonItems()
        HomeTimer()
        VideoList.dataSource = self
        VideoList.delegate = self
        
        let focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)
        
        focusGuide.preferredFocusEnvironments = [self.EventBtn]
        
        focusGuide.topAnchor.constraint(equalTo: self.EventBtn.topAnchor).isActive = true
        focusGuide.leftAnchor.constraint(equalTo: self.VideoList.leftAnchor).isActive = true
        focusGuide.rightAnchor.constraint(equalTo: self.VideoList.rightAnchor).isActive = true
        focusGuide.heightAnchor.constraint(equalTo: self.EventBtn.heightAnchor).isActive = true
        focusGuide.widthAnchor.constraint(equalTo: self.VideoList.widthAnchor).isActive = true

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLoggedIn()
        LoginManager.shared.delegate = self
        if(LoginManager.shared.loggedIn()){
            self.LoginButton.setTitle(LoginManager.shared.firstName, for: .normal)
        }
    }
    
    func onNoConnection() {
        DispatchQueue.main.sync{
            let controller = NoConnectionViewController(nibName: "NoConnectionViewController", bundle: nil)
            self.present(controller, animated: true)
        }
        
    }
    
    @IBAction func OnAccountBtn(_ sender: Any){
        if LoginManager.shared.loggedIn(){
            let storyBoard = UIStoryboard(name: "Main", bundle: nil);
            let controller = storyBoard.instantiateViewController(withIdentifier: "AVC") as! AccountViewController
            
            self.present(controller, animated: true)
        }else{
            let storyBoard = UIStoryboard(name: "Main", bundle: nil);
            let controller = storyBoard.instantiateViewController(withIdentifier: "LVC") as! LoginViewController
            
            self.present(controller, animated: true)
        }
    }
    
    @IBAction func SelectSeason(_ sender: UIButton){
        let SeasonList = SeasonSelectViewController(nibName: "SeasonSelectViewController", bundle: nil)
        SeasonList.delegate = self
        //SeasonList.modalPresentationStyle = .blurOverFullScreen
        
        self.show(SeasonList, sender: sender)
        //self.present(SeasonList, animated: true)
    }
    
    @IBAction func OnLoggedIn(_ sender: LoginViewController){
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //playEpisode(video: self.videos[indexPath.row])
        VideoPlayer.shared.requestVideoURL(asset: GPEvents.shared.episodes[indexPath.row], context: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let focusIndex = context.nextFocusedIndexPath{
            UIView.transition(with: self.SelectedVideo, duration:1.0, options: .transitionCrossDissolve, animations:{
                
                self.SelectedVideo.text = GPEvents.shared.episodes[focusIndex.row].title
            }, completion: nil)
        }
        
    }
    
    
    @IBAction func playVideo(_ sender: UIButton) {
        if !LoginManager.shared.loggedIn(){ return; }
        
            
        VideoPlayer.shared.requestVideoURL(asset: self.buttonFile, context: self)
        
        
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
