//
//  GPHeader.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 20.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import Foundation


struct HomeContent{
    
    init(completion: @escaping (Event) -> ()){
        
        var request = URLRequest(url: URL(string: url)!);
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("en-en", forHTTPHeaderField: "accept-language")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                //print(error.debugDescription)
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else{
                    completion(Event())
                    return;
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:[[String:Any]]]{
                
                if let items = json["objects"]?.first!["items"] as? [[String:Any]]{
                    if let item = items.first!["content_url"] as? [String:Any]{
                        completion(Event(json: item)!)
                    }
                    
                }
            }
            
        }
        task.resume()
    }
    
    //private let url = "https://f1tv.formula1.com/api/sets/?set_type_slug=grand-prix-header&fields=items,items__content_url,items__content__url_self&fields_to_expand=items__content_url"
    private let url = "https://f1tv.formula1.com/api/sets/?set_type_slug=grand-prix-header&fields_to_expand=items__content_url,items__content_url__sessionoccurrence_urls,items__content_url__image_urls,items__content_url__sessionoccurrence_urls__channel_urls&fields=content_url,items,items__content_url,items__content_url__sessionoccurrence_urls,items__content_url__name,items__content_url__official_name,items__content_url__sessionoccurrence_urls__status,items__content_url__sessionoccurrence_urls__slug,items__content_url__sessionoccurrence_urls__self,items__content_url__self,items__content_url__sessionoccurrence_urls__content_urls,items__content_url__sessionoccurrence_urls__channel_urls,items__content_url__sessionoccurrence_urls__start_time,items__race_season,items__content_url__sessionoccurrence_urls__name,items__content_url__image_urls,items__content_url__image_urls__url,items__content_url__sessionoccurrence_urls__channel_urls__self,items__content_url__sessionoccurrence_urls__channel_urls__name"
}

