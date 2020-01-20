//
//  ContentManager.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 13.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation


enum VideoType{
    case none
    case VOD
    case Live
    case Replay
}

struct ContentViewData{
    var title: String = ""
    var imageUrl: String = ""
    var assetUrl: String = ""
    var type: VideoType = .none
}

protocol HeroDelegate{
    func onHeroLoaded(data: HeroData)
}

class ContentManager{
    
    public static let shared = ContentManager()
    
    public var heroDelegate: HeroDelegate?
    
    private let userAgent: String = "FOM/1.7.3 (com.formula1.ott; build:11; iOS 13.3.0) Alamofire/4.9.0"
    
    func loadHero(){
        var request = URLRequest(url: URL(string: contentUrls.hero.rawValue)!)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let objects = json["objects"] as? [[String:Any]]{
                    if let items = objects.first?["items"] as? [[String:Any]]{
                        if let hero = items.first?["content_url"] as? [String:Any]{
                            var data: HeroData = HeroData()
                            data.slug = hero["slug"] as? String ?? ""
                            data.this = hero["self"] as? String ?? ""
                            data.title = hero["title"] as? String ?? ""
                            data.items = hero["items"] as? [String] ?? []
                            self.getMoreHero(epis: data.this, data: data)
                        }
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func getMoreHero(epis: String, data: HeroData){
        var final: HeroData = data
        var request = URLRequest(url: URL(string: "https://f1tv-api.formula1.com\(epis)?fields=subtitle,self,title,slug,synopsis,language,image_urls,items,image_urls__url&fields_to_expand=image_urls")!)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                final.title = json["title"] as? String ?? ""
                final.synopsis = json["synopsis"] as? String ?? ""
                if let imageSet = json["image_urls"] as? [[String:String]]{
                    if let image = imageSet.first?["url"]{
                        final.imageUrl = image
                        heroData = final
                    }
                }
            }
            self.heroDelegate?.onHeroLoaded(data: final)
        }
        task.resume()
    }
    
    
    
}
