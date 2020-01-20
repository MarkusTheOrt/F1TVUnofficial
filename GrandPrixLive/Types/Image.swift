//
//  Image.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 19.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation


fileprivate let imageSession = URLSession(configuration: URLSessionConfiguration.default)

struct Image{
    var this: String = ""
    var url: String = ""
    
    private init(){
        
    }
    
    init(_ apiUrl: String){
        let group = DispatchGroup()
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com\(apiUrl)?fields=self,url")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        group.enter()
        var image: Image = Image()
        let task = imageSession.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                group.leave()
                return;
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                
                if let uri = json["url"] as? String{
                    image.url = uri
                }
                if let thy = json["self"] as? String{
                    image.this = thy
                }
            }
            group.leave()
        }
        task.resume()
        group.wait()
        self = image
    }
    
}
