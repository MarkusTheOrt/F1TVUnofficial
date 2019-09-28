//
//  Playback.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 28.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import Foundation
import UIKit
import AVKit

protocol VideoPlayerDelegate{
    func onVideoEnded()
}

class VideoPlayer : NSObject, AVPlayerViewControllerDelegate{
    
    // TVOS 13 Channel flipping for different cameras
    func playerViewController(_ playerViewController: AVPlayerViewController, skipToNextChannel completion: @escaping (Bool) -> Void) {
        self.nextChannel()
        let url = self.liveRequestRet()
        let playerItem = AVPlayerItem(url: URL(string: url)!)
        self.View.player?.replaceCurrentItem(with: playerItem)
        completion(true)

    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, skipToPreviousChannel completion: @escaping (Bool) -> Void) {
        self.prevChannel()
        let url = self.liveRequestRet()
        let playerItem = AVPlayerItem(url: URL(string: url)!)
        self.View.player?.replaceCurrentItem(with: playerItem)
        completion(true)

    }
    
    func nextChannelInterstitialViewController(for playerViewController: AVPlayerViewController) -> UIViewController {
        return UIViewController();
    }
    
    func previousChannelInterstitialViewController(for playerViewController: AVPlayerViewController) -> UIViewController {
        return UIViewController()
    }
    
    var delegate:VideoPlayerDelegate?
    
    static let shared = VideoPlayer()
    
    private var player = AVPlayer()
    private var View = AVPlayerViewController()
    private var hasSource = false
    private var asset = VideoFile()
    private var channelIdx = 0
    
    public func getPlayer() -> AVPlayer{
        return player
    }
    
    public func requestVideoURL(asset: VideoFile, context: UIViewController){
        if !LoginManager.shared.loggedIn() { return }

        self.asset = asset
        DispatchQueue.global().async{
            switch asset.assetType{
            case "Replay":
                self.liveRequest(context)
                break;
            case "Live":
                self.liveRequest(context)
                break;
            case "VOD":
                self.VODRequest(context)
                break;
            default:
                break;
            }
        }
    }
    
    private func nextChannel(){
        if asset.channels.count > 0 && channelIdx < asset.channels.count{
            if channelIdx + 1 == asset.channels.count
            {
                // Go Back
                channelIdx = 0;
                return;
            }
            channelIdx = channelIdx + 1
        }
        
    }
    
    private func prevChannel(){
        if asset.channels.count > 0 &&  channelIdx < asset.channels.count{
            if channelIdx - 1 < 0{
                channelIdx = asset.channels.count - 1;
                return;
            }
            channelIdx = channelIdx - 1;
        }
    }
    
    
    private func liveRequestRet() -> String{
        let httpBody = "{\"channel_url\":\"\(self.asset.channels[self.channelIdx]["self"]!)\"}"
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/viewings/")!)
        request.httpBody = httpBody.data(using: .utf8);
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.addValue("account-info=\(LoginManager.shared.cookie)", forHTTPHeaderField: "cookie")
        
        let netGroup = DispatchGroup()
        netGroup.enter()
        var videoUrl = String()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                netGroup.leave()
                return;
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else{
                    netGroup.leave()
                    return;
            }
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any],
                let tempUrl = json["tokenised_url"] as? String
                else {
                netGroup.leave()
                return
            }
            videoUrl = tempUrl
            netGroup.leave()
            
            
        }
        task.resume()
        netGroup.wait()
        
        return videoUrl
    }
    
    private func liveRequest(_ context: UIViewController){
        let httpBody = "{\"channel_url\":\"\(self.asset.channels[self.channelIdx]["self"]!)\"}"
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/viewings/")!)
        request.httpBody = httpBody.data(using: .utf8);
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.addValue("account-info=\(LoginManager.shared.cookie)", forHTTPHeaderField: "cookie")
        
        let netGroup = DispatchGroup()
        netGroup.enter()
        var videoUrl = String()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                netGroup.leave()
                return;
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else{
                    netGroup.leave()
                    return;
            }
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any],
                let tempUrl = json["tokenised_url"] as? String
                else {
                netGroup.leave()
                return
            }
            videoUrl = tempUrl
            netGroup.leave()
            
            
        }
        task.resume()
        netGroup.wait()
        self.setUrl(url: videoUrl)
        self.presentView(context: context)
    }
    
    
    
    private func VODRequest(_ context: UIViewController){
        let httpBody = "{\"asset_url\":\"\(self.asset.assetId)\"}"
        
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/viewings/")!)
        request.httpBody = httpBody.data(using: .utf8);
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.addValue("account-info=\(LoginManager.shared.cookie)", forHTTPHeaderField: "cookie")
        
        let netGroup = DispatchGroup()
        netGroup.enter()
        var videoUrl = String()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                netGroup.leave()
                return;
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else{
                    netGroup.leave()
                    return;
            }
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any],
                let objects = json["objects"] as? [[String:Any]],
                let tata = objects.first!["tata"] as? [String:String],
                let tempUrl = tata["tokenised_url"]
                else {
                netGroup.leave()
                return
            }
            videoUrl = tempUrl
            netGroup.leave()
            
            
        }
        task.resume()
        netGroup.wait()
        self.setUrl(url: videoUrl)
        self.presentView(context: context)
    }
    
    private func setUrl(url: String){
        if url.isEmpty { return }
        DispatchQueue.main.sync {
            let playerItem = AVPlayerItem(url: URL(string: url)!)
            var metadata: [AVMetadataItem] = []
            let titleItem = AVMutableMetadataItem()
            titleItem.identifier = .commonIdentifierTitle
            titleItem.value = self.asset.title as NSCopying & NSObjectProtocol
            titleItem.extendedLanguageTag = "und"
            metadata.append(titleItem.copy() as! AVMetadataItem)
            playerItem.externalMetadata = metadata;
            player.replaceCurrentItem(with: playerItem)
        }
        
        hasSource = true
    }
    
    public func presentView(context: UIViewController){
        if !hasSource { return }
        
        
        
        DispatchQueue.main.sync{
            self.View.player = self.player
            self.View.delegate = self
            
            context.present(self.View, animated: true){
                
                self.player.play()
                
                
            }
        }
    }
}
