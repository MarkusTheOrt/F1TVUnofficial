//
//  VOD.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 20.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import Foundation

struct SeasonVODLoader{
    
    init?(uid: String, completion: @escaping ([VideoFile]) -> ()){
        
        DispatchQueue.global().async {
            let fields = "?fields=name,self,has_content,year,eventoccurrence_urls,eventoccurrence_urls__self,eventoccurrence_urls__name,eventoccurrence_urls__sessionoccurrence_urls,eventoccurrence_urls__official_name&fields_to_expand=eventoccurrence_urls"
            
            var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/" + uid + fields)!)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("en-en", forHTTPHeaderField: "accept-language")
            let seasonGroup = DispatchGroup()
            var seasonObj = VODSeason()
            seasonGroup.enter()
            DispatchQueue.global().async {
                seasonGroup.enter()
                let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
                    if(error != nil){
                        print(error.debugDescription)
                    }
                    guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else{
                        seasonGroup.leave()
                        return;
                    }
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                        seasonObj = VODSeason(json: json)!
                        
                        seasonGroup.leave()
                    }
                    
                }
                task.resume()
                seasonGroup.leave()
            }
            seasonGroup.wait()
            
            
            
            var list: [VideoFile] = []
            
            let sessionGroup = DispatchGroup()
            
            for grandPrix in seasonObj.events{
                
                for session in grandPrix.sessionUrls{
                    let fields = "?fields=status,channel_urls,name,content_urls,start_time,channel_urls__self,channel_urls__name,content_urls__title,content_urls__self,content_urls__items,content_urls__image_urls,content_urls__image_urls__url,image_urls,image_urls__url,content_urls__created&fields_to_expand=channel_urls,content_urls,content_urls__image_urls,image_urls"
                    
                    var sessionRequest = URLRequest(url: URL(string: "https://f1tv.formula1.com/" + session + fields)!)
                    sessionRequest.addValue("en-en", forHTTPHeaderField: "accept-language")
                    sessionGroup.enter()
                    DispatchQueue.global().async {
                        
                        let task = URLSession.shared.dataTask(with: sessionRequest){(data, response, error) -> Void in
                            if(error != nil){
                                print(error.debugDescription)
                            }
                            guard let httpResponse = response as? HTTPURLResponse,
                                (200...299).contains(httpResponse.statusCode) else{
                                    
                                    sessionGroup.leave()
                                    return;
                                    
                            }
                            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any] {
                                
                                let session = VODSession(json:json, grandPrix: grandPrix.name)
                                
                                if(session!.status == "replay" && session!.replay.title != ""){
                                    list.append(session!.replay)
                                }
                                for video in session!.videos{
                                    if video.title != ""{
                                        list.append(video)
                                    }
                                }
                                
                            }
                            sessionGroup.leave()
                        }
                        task.resume()
                        
                    }
                }
                
                
                
            }
            sessionGroup.wait()
            
            
            completion(list)
        }
    }
}

struct VODSeason{
    
    init?(json: [String:Any]){
        guard let year = json["year"] as? Int,
            let hasContent = json["has_content"] as? Bool,
            let name = json["name"] as? String,
            let this = json["self"] as? String
            else{
                return nil
        }
        
        self.year = year
        self.name = name
        self.this = this
        self.hasContent = hasContent
        
        if let events = json["eventoccurrence_urls"] as? [[String:Any]]{
            for event in events{
                self.events.append(VODEvent(json: event)!)
            }
        }
        
    }
    
    init(){
        
    }
    
    var events: [VODEvent] = []
    var year: Int = 0
    var hasContent: Bool = false
    var name: String = ""
    var this: String = ""
    
}

struct VODSession{
    
    init?(json: [String:Any], grandPrix: String = ""){
        guard
        let status = json["status"] as? String,
        let startTime = json["start_time"] as? String,
        let name = json["name"] as? String,
        let replayChannels = json["channel_urls"] as? [[String:String]],
        let videoContainers = json["content_urls"] as? [[String:Any]]
            else{
                return
        }
        
        
        
        if let urls = json["image_urls"] as? [[String:String]]{
            if(urls.count > 0){
                self.image = urls.first!["url"]!
            }
        }
        
        self.name = name
        self.status = status
        let formatter = ISO8601DateFormatter()
        self.sessionTime = formatter.date(from: startTime)!
        self.grandPrix = grandPrix
        
        if(self.status == "replay"){
            self.replay = VideoFile(title: self.name + " Replay", thumbnail: self.image, assetType: "replay", assetId: "", channels: replayChannels, date: sessionTime, grandPrix: grandPrix)
        }
        
        for video in videoContainers{
            guard let videoTitle = video["title"] as? String,
            let thumbnails = video["image_urls"] as? [[String:String]],
            let thumbnail = thumbnails.first?["url"],
            let assets = video["items"] as? [String],
            let stringDate = video["created"] as? String,
            let asset = assets.first
                else{
                    return
            }
            let assetType = "VOD"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
            let formattedDat = formatter.date(from: stringDate)
            
            self.videos.append(VideoFile(title: videoTitle, thumbnail: thumbnail, assetType: assetType, assetId: asset, channels: [], date: formattedDat!, grandPrix: grandPrix))
        }
        
    }
    
    var status: String = ""
    var name: String = ""
    var sessionTime: Date = Date()
    var videos: [VideoFile] = []
    var replay: VideoFile = VideoFile()
    var image: String = ""
    var grandPrix: String = ""
}

struct VODEvent{
    init?(json: [String:Any]){
        guard
        let this = json["self"] as? String,
        let officialName = json["official_name"] as? String,
        let name = json["name"] as? String,
        let sessionUrls = json["sessionoccurrence_urls"] as? [String]
            else{
                return nil
        }
        
        self.this = this
        self.officialName = officialName
        self.name = name
        self.sessionUrls = sessionUrls
        
    }
    
    init(){
        
        
    }
    
    var this: String = ""
    var officialName: String = ""
    var name: String = ""
    var sessionUrls: [String] = []
    
}

struct VideoFile{
    
    init(title: String, thumbnail: String, assetType: String, assetId: String, channels: [[String:String]], date: Date, grandPrix: String){
        self.title = title
        self.thumbnail = thumbnail
        self.assetType = assetType
        if(assetType == "replay")
        {
            self.title = grandPrix + " " + self.title
        }
        self.assetId = assetId
        self.channels = channels
        self.date = date
        self.grandPrix = grandPrix
    }
    init(){
        
    }
    
    var title: String = ""
    var thumbnail: String = ""
    var assetType: String = ""
    var assetId: String = ""
    var channels: [[String:String]] = []
    var date: Date = Date()
    var grandPrix: String = ""
    
}
