//
//  EventOccurrence.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 20.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import Foundation


struct EventOccurrence{

    var name : String = ""
    var officialName : String = ""
    var startDate : String = ""
    var uid : String = ""
    var slug : String = ""
    var raceSeason : Int = 0
    var endDate : String = ""
    var imageUrls: [(url: String, type: String)] = []
    var circuitUrl: String = ""
    var sessionOccurrenceUrls: [(status: String, url: String, startTime: String)] = []
    
}


struct Event{
    
    init?(json: [String:Any]){
        guard
            let this = json["self"] as? String,
            let officialName = json["official_name"] as? String,
            let name = json["name"] as? String,
            let sessions = json["sessionoccurrence_urls"] as? [[String:Any]]
            else{
                return nil
        }
        self.this = this
        self.officialName = officialName
        self.name = name
        
        for session in sessions{
            self.sessions.append(Session(json: session, gpName: name)!)
        }
    }
    
    init(){
        
    }
    
    var this: String = ""
    var officialName: String = ""
    var name: String = ""
    var sessions: [Session] = []
}


struct Session{
    
    init(){
        
    }
    
    init?(json: [String:Any], gpName: String){
        guard
            let status = json["status"] as? String,
            let this = json["self"] as? String,
            let slug = json["slug"] as? String,
            let episodes = json["content_urls"] as? [String],
            let replays = json["channel_urls"] as? [String],
            let date = json["start_time"] as? String,
            let name = json["name"] as? String
            else{
                return nil
        }
        
        self.status = status
        self.this = this
        self.slug = slug
        self.episodes = episodes
        self.replays = replays
        let formatter = ISO8601DateFormatter()
        self.startTime = formatter.date(from: date)!
        self.name = name
        self.GPName = gpName
    }
    
    var status: String = ""
    var this: String = ""
    var slug: String = ""
    var startTime: Date = Date()
    var episodes: [String] = []
    var replays: [String] = []
    var name: String = ""
    var GPName: String = ""
}
