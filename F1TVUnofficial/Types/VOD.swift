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
                    }
                    
                    self.hasSeasons = self.seasons.count > 0
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
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:[[String:String]]]{
                for jsEvent in json["eventoccurrence_urls"]!{
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
    
    init?(json: [String:String]){
        guard
            let this = json["self"],
            let date = json["start_date"],
            let name = json["official_name"]
            else{
                return;
        }
        
        self.this = this
        self.name = name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.date = dateFormatter.date(from: date) ?? Date(timeIntervalSince1970: 0)
        
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
            self.replay = VideoFile(title: self.name + " Replay", thumbnail: self.image, assetType: "Replay", assetId: "", channels: replayChannels, date: sessionTime, grandPrix: grandPrix)
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
        // Live, Replay, VOD
        if(assetType == "Replay")
        {
            self.title = grandPrix + " " + self.title
        }
        self.assetId = assetId
        self.channels = channels
        self.date = date
        self.grandPrix = grandPrix
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
