//
//  Event.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 21.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation

fileprivate var sessionURLSession = URLSession(configuration: URLSessionConfiguration.default)
fileprivate var eventSession = URLSession(configuration: URLSessionConfiguration.default)
fileprivate var channelSession = URLSession(configuration: URLSessionConfiguration.default)

enum SessionStatus{
    case none
    case replay
    case live
    case expired
}

enum SessionType: String{
    case none = "unspecified"
    case quali = "Qualifying"
    case practice1 = "Practice 1"
    case practice2 = "Practice 2"
    case practice3 = "Practice 3"
    case test = "High Speed Test"
    case race = "Race"
}

struct Event{
    
    var officialName: String = ""
    var name: String = ""
    var date: Date = Date(timeIntervalSince1970: 0)
    var sessions: [Session] = []
    var images: [Image] = []
    var this: String = ""
    
    private init(){}
    
    init(_ apiUrl: String){
        let group = DispatchGroup()
        var request = URLRequest(url: URL(string: "https://f1tv-api.formula1.com\(apiUrl)?fields=self,official_name,sessionoccurrence_urls,start_date,image_urls,name")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        var event = Event()
        group.enter()
        let sess = URLSession(configuration: URLSessionConfiguration.default)
        let task = sess.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                group.leave()
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let name = json["name"] as? String {
                    event.name = name
                }
                if let officialName = json["official_name"] as? String {
                    event.officialName = officialName
                }
                if let this = json["self"] as? String {
                    event.this = this
                }
                if let images = json["image_urls"] as? [String]{
                    images.forEach({(url) -> Void in
                        event.images.append(Image(url))
                    })
                }
                if let sessions = json["sessionoccurrence_urls"] as? [String]{
                    sessions.forEach({(url) -> Void in
                        event.sessions.append(Session(url))
                    })
                    
                    
                }
                if let date = json["start_date"] as? String{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    event.date = dateFormatter.date(from: date) ?? Date(timeIntervalSince1970: 0)
                }
            }
            group.leave()
        }
        task.resume()
        group.wait()
        self = event
    }
    

    
}

class Session{
    
    var status: SessionStatus = .none
    var this: String = ""
    var type: SessionType = .none
    var name: String = ""
    var startTime: Date = Date(timeIntervalSince1970: 0)
    var slug: String = ""
    var images: [Image] = []
    var episodes: [Episode] = []
    var channel: [Channel] = []
    private var url: String = ""
    private init(){}
    
    
    
    func resolve(){
        let group = DispatchGroup()
        var request = URLRequest(url: URL(string: "https://f1tv-api.formula1.com\(url)")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        
        group.enter()
        let task = sessionURLSession.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                group.leave()
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let status = json["status"] as? String {
                    switch status {
                    case "replay":
                        self.status = .replay
                        break
                    case "expired":
                        self.status = .expired
                        break
                    case "live":
                        self.status = .live
                        break
                    default:
                        self.status = .none
                    }
                }
                if let name = json["session_name"] as? String {
                    self.name = name
                }
                if let type = json["name"] as? String {
                    print(type)
                    switch type {
                    case "Qualifying":
                        self.type = .quali
                        break
                    case "Practice 1":
                        self.type = .practice1
                        break
                    case "Practice 2":
                        self.type = .practice2
                        break
                    case "Practice 3":
                        self.type = .practice3
                        break
                    case "Race":
                        self.type = .race
                        break
                    case "High Speed Track Test":
                        self.type = .test
                        break
                    default:
                        self.type = .none
                    }
                }
                if let slug = json["slug"] as? String {
                    self.slug = slug
                }
                if let this = json["this"] as? String {
                    self.this = this
                }
                if let images = json["image_urls"] as? [String] {
                    images.forEach({(url) -> Void in
                        self.images.append(Image(url))
                    })
                }
                if let contents = json["content_urls"] as? [String] {
                    contents.forEach({(url) -> Void in
                        self.episodes.append(Episode(url))
                    })
                }
                //if let channels = json["channel_urls"] as? [String] {
                    //channels.forEach({(url) -> Void in
                        //session.channel.append(Channel(url))
                    //})
                //}
                if let date = json["start_time"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    self.startTime = dateFormatter.date(from: date) ?? Date(timeIntervalSince1970: 0)
                }
            }
            group.leave()
        }
        task.resume()
        group.wait()
    }
    
    init(_ apiUrl: String){
        url = apiUrl
        
    }
    
    
}

struct Channel{
    var name: String = ""
    var this: String = ""
    
    private init(){}
    
    init(_ apiUrl: String){
        let group = DispatchGroup()
        var request = URLRequest(url: URL(string: "https://f1tv-api.formula1.com\(apiUrl)?fields=name,self")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        var channel = Channel()
        group.enter()
        let task = channelSession.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                group.leave()
                return;
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let this = json["self"] as? String{
                    channel.this = this
                }
                if let name = json["name"] as? String{
                    channel.name = name
                }
            }
            group.leave()
        }
        task.resume()
        group.wait()
        self = channel
    }
    
}
