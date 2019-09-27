//
//  Episode.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 20.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import Foundation

struct Episode{
    
    //"https://f1tv.formula1.com/api/episodes/epis_b0877ca4d9164c09a3f96f3e9133dd3d/?fields=items,title,driver_urls,slug,created,self,uid"
    
    init?(url: String, completion: @escaping (_ episode: Episode) -> ()){
        let fields = "?fields=items,title,slug,created,self,uid,driver_urls"
        
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/" + url + fields)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                print(error.debugDescription)
            }
            if let httpResponse = response as? HTTPURLResponse{
                if(httpResponse.statusCode == 200){
                    
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                        completion(Episode(json: json)!)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    init?(json: [String:Any]){
        guard let uid = json["uid"] as? String,
            let created = json["created"] as? String,
            let items = json["items"] as? [String],
            let this = json["self"] as? String,
            let slug = json["slug"] as? String,
            let driverUrls = json["driver_urls"] as? [String]
            else{
                return nil
        }
        
        self.uid = uid
        self.created = created
        self.items = items
        self.this = this
        self.slug = slug
        self.driverUrls = driverUrls
    }
    
    var uid: String = ""
    var created: String = ""
    var items: [String] = []
    var this: String = ""
    var slug: String = ""
    var driverUrls: [String] = []

}
