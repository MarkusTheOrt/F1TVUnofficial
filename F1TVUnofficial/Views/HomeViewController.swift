//
//  HomeViewController.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 17.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import UIKit
import AVKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, loginDelegate {
    
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
    
    
    var videos:[VideoFile] = []
    

    required init?(coder: NSCoder){
        super.init(coder: coder)
        
        
        let initGroup = DispatchGroup()
        
        initGroup.enter()
        _ = HomeContent(){(event) -> Void in
            self.updateHomeItems(event: event)
            initGroup.leave()
            
        }
        initGroup.wait()
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.videos.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoItemCell{
            cell.configureCell(video: videos[indexPath.row])
            
            return cell
        }
        
        
        
        return VideoItemCell()
        
    }
    var homeEvent = Event()
    var timer = Timer()
    
    func HomeTimer(){
       self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: {(event) -> Void in
        DispatchQueue.global().async {
            
            _ = HomeContent(){(homeItems) -> Void in
                var needsUpdated = false
                if(self.homeEvent.this == homeItems.this){
                    for session in homeItems.sessions{
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
                    self.updateHomeItems(event: homeItems)
                }
            }
        }
       })
        
    }
    
    func updateHomeItems(event: Event){
        if(event.image.isEmpty){
            return;
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: event.image)!){
                if let image = UIImage(data: data){
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
                        UserDefaults.standard.setValue(lastSession.replays.first, forKey: "replayUrl")
                        UserDefaults.standard.setValue("replay", forKey: "mediaType")
                        UserDefaults.standard.synchronize()
                    }
                    if liveSession.name != ""{
                        
                        self.SessionButton.setTitle(liveSession.name, for: .normal)
                        self.SessionButton.isEnabled = true
                        self.SessionButton.isHidden = false
                        UserDefaults.standard.setValue(liveSession.replays.first, forKey: "liveUrl")
                        UserDefaults.standard.setValue("live", forKey: "mediaType")
                        UserDefaults.standard.synchronize()
                        
                        
                    }
                    
                    
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
        _ = SeasonVODLoader(uid: "/api/race-season/current/"){(VideoArray) -> Void in
            self.videos = VideoArray.sorted(by: {$0.date > $1.date})
            DispatchQueue.main.async {
                self.VideoList.reloadData()
            }
        }
    }
    
    func DownloadHomeSets(){
        _ = HomeContent(){(event) -> Void in
            self.updateHomeItems(event: event)
            
            
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
        
        DownloadSeasonItems()
        HomeTimer()
        VideoList.dataSource = self
        VideoList.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLoggedIn()
        if(LoginManager.shared.loggedIn()){
            self.LoginButton.setTitle(LoginManager.shared.firstName, for: .normal)
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
    
    
    @IBAction func OnLoggedIn(_ sender: LoginViewController){
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playEpisode(video: self.videos[indexPath.row])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("TEST")
        
    }
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let focusIndex = context.nextFocusedIndexPath{
            UIView.transition(with: self.SelectedVideo, duration:1.0, options: .transitionCrossDissolve, animations:{
                self.SelectedVideo.text = self.videos[focusIndex.row].title
            }, completion: nil)
        }
        
    }
    
    func playEpisode(video: VideoFile){
        if !LoginManager.shared.loggedIn(){ return; }
        if(video.assetType == "VOD"){
            let cookie = LoginManager.shared.cookie
            let channelurl = video.assetId
            let assetUrl = "{\"asset_url\":\"" + channelurl + "\"}";
            var vRequest = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/viewings/")!)
            vRequest.httpBody = assetUrl.data(using: .utf8);
            vRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            vRequest.httpMethod = "POST"
            vRequest.addValue("account-info=" + cookie, forHTTPHeaderField: "cookie")
            
            let vTask = URLSession.shared.dataTask(with: vRequest) { (data, response, error) ->
                Void in
                
                if(error != nil){
                    print(error.debugDescription)
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        return;
                }
                
                
                let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]
                let objects = json!["objects"] as? [Any]
                let tataArray = objects?.first as? [String:Any]
                let tata = tataArray?["tata"] as? [String:String]
                let ViewUrl = tata?["tokenised_url"]
                DispatchQueue.main.sync{
                    let player = AVPlayer(url: URL(string: ViewUrl!)!)
                    
                    let controller = AVPlayerViewController()
                    controller.player = player
                    
                    self.present(controller, animated: true){
                        player.play()
                    }
                }
                
                
            }
            vTask.resume()
        }else{
            let cookie = LoginManager.shared.cookie
            let channelurl = video.channels.first!["self"]
            let assetUrl = "{\"channel_url\":\"" + channelurl! + "\"}";
            print(assetUrl)
            var vRequest = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/viewings/")!)
            vRequest.httpBody = assetUrl.data(using: .utf8);
            vRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            vRequest.httpMethod = "POST"
            vRequest.addValue("account-info=" + cookie, forHTTPHeaderField: "cookie")
            
            let vTask = URLSession.shared.dataTask(with: vRequest) { (data, response, error) ->
                Void in
                
                if(error != nil){
                    print(error.debugDescription)
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        return;
                }
                
                let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]
                let ViewUrl = json!["tokenised_url"] as? String
                DispatchQueue.main.sync{
                    let player = AVPlayer(url: URL(string: ViewUrl!)!)
                    
                    let controller = AVPlayerViewController()
                    controller.player = player
                    
                    self.present(controller, animated: true){
                        player.play()
                    }
                }
                
                
            }
            vTask.resume()
        }
        
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        if !LoginManager.shared.loggedIn(){ return; }
        DispatchQueue.main.async{
            if(UserDefaults.standard.string(forKey: "mediaType") == "live"){
                let cookie = LoginManager.shared.cookie
                let channelurl = UserDefaults.standard.string(forKey: "liveUrl")!
                let assetUrl = "{\"channel_url\":\"" + channelurl + "\"}";
                var vRequest = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/viewings/")!)
                vRequest.httpBody = assetUrl.data(using: .utf8);
                vRequest.addValue("application/json", forHTTPHeaderField: "Accept")
                vRequest.httpMethod = "POST"
                vRequest.addValue("account-info=" + cookie, forHTTPHeaderField: "cookie")
                
                let vTask = URLSession.shared.dataTask(with: vRequest) { (data, response, error) ->
                    Void in
                    
                    if(error != nil){
                        print(error.debugDescription)
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            return;
                    }
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                        
                        DispatchQueue.main.sync {
                            if let ViewUrl = json["tokenised_url"] as? String{
                                let player = AVPlayer(url: URL(string: ViewUrl)!)
                                
                                let controller = AVPlayerViewController()
                                controller.player = player
                                
                                self.present(controller, animated: true){
                                    player.play()
                                }
                            }
                        }
                        
                        
                    }
                    
                    
                    
                }
                vTask.resume()
            } else{
                let cookie = LoginManager.shared.cookie
                let channelurl = UserDefaults.standard.string(forKey: "replayUrl")!
                let assetUrl = "{\"channel_url\":\"" + channelurl + "\"}";
                print(assetUrl)
                var vRequest = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/viewings/")!)
                vRequest.httpBody = assetUrl.data(using: .utf8);
                vRequest.addValue("application/json", forHTTPHeaderField: "Accept")
                vRequest.httpMethod = "POST"
                vRequest.addValue("account-info=" + cookie, forHTTPHeaderField: "cookie")
                
                let vTask = URLSession.shared.dataTask(with: vRequest) { (data, response, error) ->
                    Void in
                    
                    if(error != nil){
                        print(error.debugDescription)
                    }
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            return;
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]
                    let ViewUrl = json!["tokenised_url"] as? String
                    DispatchQueue.main.sync{
                        let player = AVPlayer(url: URL(string: ViewUrl!)!)
                        
                        let controller = AVPlayerViewController()
                        controller.player = player
                        
                        self.present(controller, animated: true){
                            player.play()
                        }
                    }
                    
                    
                }
                vTask.resume()
            }
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
