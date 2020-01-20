//
//  Asset.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 19.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation

fileprivate let assetSession = URLSession(configuration: URLSessionConfiguration.default)

struct Asset{
    var title: String = ""
    var this: String = ""
    var duration: Int = 0
    var subtitles: Bool = false
    var slug: String = ""
    
    
    private init(){}
    
    init(_ apiUrl: String){
        let group = DispatchGroup()
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com\(apiUrl)?fields=title,self,duration_in_seconds,subtitles,slug")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        group.enter()
        var asset: Asset = Asset()
        let task = assetSession.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                group.leave()
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let thy = json["self"] as? String{
                    asset.this = thy
                }
                if let dur = json["duration_in_seconds"] as? Int{
                    asset.duration = dur
                }
                if let title = json["title"] as? String{
                    asset.title = title
                }
                if let slug = json["slug"] as? String{
                    asset.slug = slug
                }
                if let subtitles = json["subtitles"] as? Bool{
                    asset.subtitles = subtitles
                }
            }
            group.leave()
        }
        task.resume()
        group.wait()
        self = asset
    }
    
    
}
