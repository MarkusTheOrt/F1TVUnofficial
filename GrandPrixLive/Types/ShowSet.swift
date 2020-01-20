//
//  ShowSet.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 19.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation


fileprivate let showSession = URLSession(configuration: URLSessionConfiguration.default)
fileprivate let episodeSession = URLSession(configuration: URLSessionConfiguration.default)

struct Show{
    var title: String = ""
    var slug: String = ""
    var this: String = ""
    var Episodes: [Episode] = []
    
    private init(){}
    
    init(_ slug: String, success: @escaping (Show) -> Void){
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/sets/?slug=\(slug)&fields=title,slug,self,items,items__content_url")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        var show = Show()
        let task = showSession.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                return;
            }
            
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                
                if let object = json["objects"] as? [[String:Any]] {
                    let obj = object.first!
                    
                    if let title = obj["title"] as? String {
                        show.title = title
                    }
                    if let slug = obj["slug"] as? String {
                        show.slug = slug
                    }
                    if let this = obj["self"] as? String {
                        show.this = this
                    }
                    if let episodes = obj["items"] as? [[String:String]]{
                        episodes.forEach({(item) -> Void in
                            show.Episodes.append(Episode(item["content_url"]!))
                        })
                    }
                    
                    DispatchQueue.main.sync{
                        success(show)
                    }
                    
                }
                
            }
            
        
        }
        task.resume()

    }
    
}

struct Episode{
    var title: String = ""
    var synopsis: String = ""
    var slug: String = ""
    var this: String = ""
    var items: [Asset] = []
    var sessions: [String] = []
    var images: [Image] = []
    
    private init(){}
    
 
    
    init(_ apiUrl: String){
        
        let group = DispatchGroup()
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com\(apiUrl)?fields=title,self,items,image_urls,slug,synopsis")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        var epis = Episode()
        group.enter()

        let task = episodeSession.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                group.leave()
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                
                if let title = json["title"] as? String{
                    epis.title = title
                }
                if let slug = json["slug"] as? String{
                    epis.slug = slug
                }
                if let this = json["self"] as? String{
                    epis.this = this
                }
                if let synopsis = json["synopsis"] as? String{
                    epis.synopsis = synopsis
                }
                if let items = json["items"] as? [String]{
                    items.forEach({(item) -> Void in
                        epis.items.append(Asset(item))
                    })
                }
                if let images = json["image_urls"] as? [String]{
                    images.forEach({(image) -> Void in
                        epis.images.append(Image(image))
                        
                    })
                }
            }
            group.leave()
        }
        task.resume()
        group.wait()
        self = epis
    }
    
}


