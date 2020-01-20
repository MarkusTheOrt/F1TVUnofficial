//
//  VideoPlayer.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 14.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation
import AVKit
import UIKit

protocol VideoPlayerDelegate{
    func onVideoStarted()
    func onVideoEnded()
}

struct PlayerData{
    var videoUrl: String = ""
    var channelUrls: [String:String] = [:]
    var isPlayingVideo: Bool = false
    var isLiveVideo: Bool = false
    var hasMultipleChannels: Bool = false
    var channelId: Int = -1
    let player = AVPlayer()
    var view: AVPlayerViewController?
    
    init(){
        view = nil
        DispatchQueue.main.sync{
            self.view = AVPlayerViewController()
            self.view?.player = player
        }
        
        
    }
}

var player: PlayerData = PlayerData()

enum contentAPI: String{
    case viewings = "https://f1tv-api.formula1.com/api/viewings/"
    case entitlements = "https://f1tv-api.formula1.com/api/entitlements/"
}



class VideoPlayer{
    static let shared: VideoPlayer = VideoPlayer()
    
    var delegate : VideoPlayerDelegate?
    
    var context : UIViewController?
    
    func play(){
        if player.videoUrl.isEmpty { return }
        let playerItem = AVPlayerItem(url: URL(string: player.videoUrl)!)
        context?.present(player.view!, animated: true)
        player.isPlayingVideo = true
        DispatchQueue.main.sync{
            player.player.rate = 1
            player.player.replaceCurrentItem(with: playerItem)
        }
        
        
    }
    func play(url: String, VC: UIViewController){
        player.videoUrl = url
        self.play()
    }
    
    func obtainVideoURL(epis: HeroData){
        if(!isEntitled(epis: epis.this)){ return }
        var request = URLRequest(url: URL(string: contentAPI.viewings.rawValue)!)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        request.setValue("JWT \(userData.JWT)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = "{\"asset_url\": \"\(epis.items.first ?? "")\"}".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                return;
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:[[String:[String:String]]]]{
                if let obj = json["objects"]?.first{
                    if let tata = obj["tata"]{
                        if let url = tata["tokenised_url"]{
                            player.videoUrl = url
                            self.play()
                        }
                    }
                }
            }            
        }
        task.resume()
    }
    
    func obtainVideoURL(epis: Episode, VC: UIViewController){
        self.context = VC
        if(!isEntitled(epis: epis.this)){ return }
        var request = URLRequest(url: URL(string: contentAPI.viewings.rawValue)!)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        request.setValue("JWT \(userData.JWT)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = "{\"asset_url\": \"\(epis.items.first?.this ?? "")\"}".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                return;
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:[[String:[String:String]]]]{
                if let obj = json["objects"]?.first{
                    if let tata = obj["tata"]{
                        if let url = tata["tokenised_url"]{
                            player.videoUrl = url
                            self.play()
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func isEntitled(epis: String) -> Bool{
        var request = URLRequest(url: URL(string: contentAPI.entitlements.rawValue)!)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        request.setValue("JWT \(userData.JWT)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = "{\"episode_url\": \"\(epis)\"}".data(using: .utf8)
        let group = DispatchGroup()
        var retVal: Bool = false
        
        group.enter()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                group.leave()
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                print(json)
                if let expired = json["expired"] as? Bool{
                    if expired == false{
                        retVal = true;
                    }
                }
            }
            group.leave()
            
        }
        task.resume()
        group.wait()
        return retVal
    }
    
    
}
