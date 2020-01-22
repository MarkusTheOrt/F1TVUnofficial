//
//  Season.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 21.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation

fileprivate var SeasonSession = URLSession(configuration: URLSessionConfiguration.default)

struct Season{
    
    var name: String = ""
    var this: String = ""
    var hasContent: Bool = false
    var year: Int = 0
    var events: [Event] = []
    
    private init(){}
    
    init(_ apiUrl: String, completion: @escaping (Season) -> ()){
        var request = URLRequest(url: URL(string: "https://f1tv-api.formula1.com\(apiUrl)?fields=name,self,has_content,year,eventoccurrence_urls")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        var season = Season()
        let task = SeasonSession.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let name = json["name"] as? String {
                    season.name = name
                }
                if let year = json["year"] as? Int {
                    season.year = year
                }
                if let hasContent = json["has_content"] as? Bool {
                    season.hasContent = hasContent
                }
                if let this = json["self"] as? String {
                    season.this = this
                }
                
                if let events = json["eventoccurrence_urls"] as? [String] {
                    events.forEach({(url) -> Void in
                        season.events.append(Event(url))
                    })
                }
                completion(season)
            }
            
        }
        task.resume()
    }
    
}
