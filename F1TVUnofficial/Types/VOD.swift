//
//  VOD.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 20.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import Foundation

protocol CMDelegate{
    func onSeasonLoaded(_ events: [EventMinimal]);
}

class ContentManager{
    
    
    var delegate: CMDelegate?
    static var shared = ContentManager()
    var lastSelectedYear: Int = 0
    
    private let apiUrl = "https://f1tv.formula1.com/api/race-season/?fields=year,name,self,has_content&order=-year"
    
    private var seasons: [SeasonMinimal] = []
    private var hasSeasons = false
    private var cachedEvents: [Int:[EventMinimal]] = [:]
    
    func getGrandPrixforSeason(season: SeasonMinimal) -> [EventMinimal]{
        if(cachedEvents[season.year]!.count == 0){
            delegate?.onSeasonLoaded(self.getGPsForSeason(season))
            return cachedEvents[season.year]!
        }
        delegate?.onSeasonLoaded(cachedEvents[season.year]!)
        return cachedEvents[season.year]!
    }
    
    
    func GetSeasons() ->[SeasonMinimal] {
        if hasSeasons == true{
            return self.seasons
        }
        let seasonGroup = DispatchGroup()
        GetSeasons(seasonGroup)
        return self.seasons
    }
    
    func GetSeasons(_ AsyncGroup: DispatchGroup?){
        AsyncGroup?.enter()
        DispatchQueue.global().async{
            var request = URLRequest(url: URL(string: self.apiUrl)!);
            if(LoginManager.shared.loggedIn()) {
                request.addValue(LoginManager.shared.cookie, forHTTPHeaderField: "cookie")
            }
            request.addValue("en-en", forHTTPHeaderField: "accept-language")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
                if(error != nil){
                    print(error.debugDescription)
                    AsyncGroup?.leave()
                }
                guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else{
                    AsyncGroup?.leave()
                    return;
                }
                if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:[[String:Any]]]{
                    for season in json["objects"]!{
                        self.seasons.append(SeasonMinimal(json:season)!)
                        self.cachedEvents[self.seasons.last!.year] = []
                        self.hasSeasons = true
                    }
                    
                    
                }
                
                AsyncGroup?.leave()
            }
            task.resume()
            
        }
        AsyncGroup?.wait()
    }
    
    func getGPsForSeason(_ season: SeasonMinimal) -> [EventMinimal]{
        
        if(!season.hasContent){ return [] }
        let group = DispatchGroup()
        
        let url = "https://f1tv.formula1.com/\(season.this)?fields=eventoccurrence_urls,eventoccurrence_urls__self,eventoccurrence_urls__official_name,eventoccurrence_urls__start_date&fields_to_expand=eventoccurrence_urls";
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("en-en", forHTTPHeaderField: "accept-language")
        group.enter()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                print(error.debugDescription)
                group.leave()
            }
            guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else{
                group.leave()
                return;
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                
                for jsEvent in (json["eventoccurrence_urls"] as? [[String:Any]])!{
                    let Event = EventMinimal(json: jsEvent)!
                    if Event.date < Date(){
                        self.cachedEvents[season.year]!.append(Event)
                    }
                    
                }
            }
            group.leave()
            
        }
        task.resume()
        
        group.wait()
        delegate?.onSeasonLoaded(self.cachedEvents[season.year]!)
        
        return self.cachedEvents[season.year]!
    }
    
    
}

struct EventMinimal{
    
    init?(json: [String:Any]){
        guard
            let this = json["self"] as? String,
            let name = json["official_name"] as? String
            else{
                return;
        }
        
        let date = json["start_date"] as? String ?? String("1970-01-01")
        self.this = this
        self.name = name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.date = dateFormatter.date(from: date as String)!
        
    }
    
    var this = String()
    var date = Date()
    var name = String()
}

struct SeasonMinimal{
    
    
    init?(json: [String:Any]){
        
        guard
            let this = json["self"] as? String,
            let year = json["year"] as? Int,
            let hasContent = json["has_content"] as? Bool,
            let name = json["name"] as? String
            else {
                return;
        }
        
        self.this = this;
        self.year = year;
        self.hasContent = hasContent;
        self.name = name;
        
    }
    
    
    
    var this = String();
    var year = 0;
    var hasContent = false;
    var name = String();
    
}

protocol GPEventDelegate{
    func onGPLoaded()
}

struct GPEvents{
    
    static var shared = GPEvents()
    var delegate:GPEventDelegate?
    var grandPrix = String()
    var startDate = Date(timeIntervalSince1970: 0)
    var name = String()
    var episodes: [VideoFile] = []
    
    mutating func getEvents(eventStr: String){
        episodes.removeAll()
        DispatchQueue.global().async{
            let url = "https://f1tv.formula1.com/\(eventStr)?fields=official_name,name,sessionoccurrence_urls,sessionoccurrence_urls,sessionoccurrence_urls__content_urls,sessionoccurrence_urls__image_urls,sessionoccurrence_urls__channel_urls,sessionoccurrence_urls__content_urls__items,sessionoccurrence_urls__content_urls__title,sessionoccurrence_url__content_urls__created,start_date,sessionoccurrence_urls__image_urls__url,sessionoccurrence_urls__content_urls__created,sessionoccurrence_urls__start_time,sessionoccurrence_urls__content_urls__image_urls,sessionoccurrence_urls__content_urls__image_urls__url,sessionoccurrence_urls__session_name,sessionoccurrence_urls__status,sessionoccurrence_urls__name,sessionoccurrence_urls__channel_urls__name,sessionoccurrence_urls__channel_urls__self&fields_to_expand=sessionoccurrence_urls,sessionoccurrence_urls__content_urls,sessionoccurrence_urls__image_urls,sessionoccurrence_urls__content_urls__image_urls,sessionoccurrence_urls__channel_urls"
            
            var request = URLRequest(url: URL(string: url)!)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("en-en", forHTTPHeaderField: "accept-language")
            if LoginManager.shared.loggedIn() {
                request.addValue(LoginManager.shared.cookie, forHTTPHeaderField: "cookie")
            }
            let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
                if(error != nil){
                    print(error.debugDescription)
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else{
                        return;
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                    guard let name = json["name"] as? String,
                        let grandPrix = json["official_name"] as? String,
                        let sessions = json["sessionoccurrence_urls"] as? [[String:Any]]
                        else{
                            return;
                    }
                    let date = json["start_date"] as? String ?? "1970-01-01"
                    GPEvents.shared.name = name
                    GPEvents.shared.grandPrix = grandPrix
                    let formatter = DateFormatter()
                    formatter.dateFormat = "YYYY-MM-dd"
                    GPEvents.shared.startDate = formatter.date(from: date)!
                    
                    for session in sessions{
                        let clearedSession = VODSession(json: session, grandPrix: GPEvents.shared.grandPrix)
                        if clearedSession!.status == "expired" { continue }
                        if clearedSession!.replay == nil && clearedSession?.videos.count == 0 { continue }
                        if clearedSession!.replay != nil { GPEvents.shared.episodes.append(clearedSession!.replay!) }
                        
                        GPEvents.shared.episodes.append(contentsOf: clearedSession!.videos)
                    }
                    GPEvents.shared.delegate?.onGPLoaded()
                    
                }
                
            }
            task.resume()
        }
    }
    
    
    
    
    
}




struct VODSession{
    
    init?(json: [String:Any], grandPrix: String = ""){
 
        
        let videoContainers = json["content_urls"] as? [[String:Any]] ?? []
        let replayChannels = json["channel_urls"] as? [[String:String]] ?? []
        
        
        let name = json["session_name"] as? String ?? json["name"] as? String
        let startTime = json["start_time"] as? String ?? "1972-01-01T01:01:00+00:00"
        let status = json["status"] as? String ?? "Legacy"
        
        if let urls = json["image_urls"] as? [[String:String]]{
            if(urls.count > 0){
                self.image = urls.first!["url"]!
            }
        }
        
        
        self.name = name!
        self.status = status
        let formatter = ISO8601DateFormatter()
        self.sessionTime = formatter.date(from: startTime)!
        self.grandPrix = grandPrix
        
        if self.status == "expired"{
            return;
        }
        
        if(self.status == "replay"){
            self.replay = VideoFile(title: self.name + " Replay", thumbnail: self.image, assetType: "Replay", assetId: "", channels: replayChannels, date: sessionTime, grandPrix: grandPrix)
        }
        
        for video in videoContainers{
            guard let videoTitle = video["title"] as? String,
            let thumbnails = video["image_urls"] as? [[String:String]],
            let thumbnail = thumbnails.first?["url"],
            let assets = video["items"] as? [String],
            let asset = assets.first
                else{
                    continue
            }
            

            let stringDate = video["created"] as? String ?? "1970-01-01T01:01:01+00:00"
            
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
    var replay: VideoFile? = nil
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
        // Live, Replay, VOD
        
        self.assetId = assetId
        self.channels = channels
        self.date = date
        self.grandPrix = grandPrix
    }
    
    init?(json: [String:Any], grandPrix: String){
        guard
            let title = json["title"] as? String,
            let date = json["created"] as? String,
            let items = json["items"] as? [String],
            let asset = items.first,
            let images = json["image_urls"] as? [[String:String]],
            let thumbnail = images.first!["url"]
            else{
                return;
    }
        
        self.title = title;
        self.assetId = asset;
        self.thumbnail = thumbnail;
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        self.date = formatter.date(from: date)!
        
    }
    
    init(title: String, assetType: String, channels: [[String:String]]){
        self.title = title
        self.assetType = assetType
        self.channels = channels
    }
    
    init(){
        
    }
    
    var title: String = String()
    var thumbnail: String = String()
    var assetType: String = String()
    var assetId: String = String()
    var channels: [[String:String]] = []
    var date: Date = Date()
    var grandPrix: String = String()
    
}
