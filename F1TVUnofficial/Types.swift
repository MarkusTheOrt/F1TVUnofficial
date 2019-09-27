//
//  Types.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 17.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import Foundation


struct ContentUrl{
    init?(json: [String: Any]){
        self.init()
        guard let uid = json["uid"] as? String,
            let setTypeSlug = json["set_type_slug"] as? String,
            let items = json["items"] as? [Any]
            else{
                return nil
        }
        
        var tempArray : [ContentUrlItem] = []
        for case let item as [String:Any] in items{
            tempArray.append(ContentUrlItem(json: item)!)
        }
        self.contentUrl = tempArray
        self.setTypeSlug = setTypeSlug
        self.uid = uid
    }
    
    init(){
        contentUrl = []
        uid = ""
        setTypeSlug = ""
        contentType = ""
        initialized = false
    }
    
    var contentUrl: [ContentUrlItem]
    var uid: String
    var setTypeSlug: String
    var contentType: String
    var initialized: Bool
}

struct ContentUrlItem{
    
    init?(json: [String: Any]){
        self.init()
        guard let contentType = json["content_type"] as? String,
            let container = json["content_url"] as? [String:String],
            let uid = container["uid"]
            else{
                return nil;
        }
        self.contentType = contentType
        self.uid = uid
        self.initialized = true
        
    }
    
    
    init(){
        contentType = ""
        uid = ""
        initialized = false
    }
    
    var contentType: String
    var uid: String
    var initialized: Bool
}



struct SetItem{
    
    init?(json: [String: Any]){
        self.init()
        guard let position = json["position"] as? Int,
            let contentUrl = json["content_url"] as? [String: Any],
            let contentType = json["content_type"] as? String
            else{
                return nil
        }
        
        self.position = position
        self.contentUrl = ContentUrl(json: contentUrl)!
        self.contentType = contentType
        initialized = true
    }
    
    
    init(){
        position = 0
        contentUrl = ContentUrl()
        contentType = ""
        initialized = false
    }
    
    var position: Int
    var contentUrl: ContentUrl
    var contentType: String
    var initialized: Bool
}







struct APIImage{
    
    
    init?(url: String, completion: @escaping (_ image: APIImage) -> ()){
        self.init()
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com" + url)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) {(data, respone, error) -> Void in
            if(error != nil){
                print(error.debugDescription)
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                completion(APIImage(json: json as! [String:Any])!)
            }
            
            
        }
        task.resume()
        
    }
    
    init?(json: [String:Any]){
        self.init()
        guard let uid = json["uid"] as? String,
            let scheduleUrls = json["schedule_urls"] as? [String],
            //let height = json["height"] as? Int,
            //let width = json["width"] as? Int,
            let imageTypeUrl = json["image_type_url"] as? String,
            let title = json["title"] as? String,
            let imageType = json["image_type"] as? String,
            let this = json["self"] as? String,
            //let contentObject = json["content_object"],
            let dataSourceFields = json["data_source_fields"] as? [String],
            let description = json["description"] as? String,
            let contentUrl = json["content_url"] as? String,
            let uploadImageUrl = json["upload_image_url"] as? String,
            //let lastDataIngest = json["last_data_ingest"] as? String,
            let language = json["language"] as? String,
            let created = json["created"] as? String,
            let url = json["url"] as? String,
            let align = json["align"] as? String,
            let modified = json["modified"] as? String,
            let position = json["position"] as? Int,
            let editability = json["editability"] as? String
            else{
                return nil
        }
        print("APIImage Done")
        
        self.uid = uid
        self.scheduleUrls = scheduleUrls
        // height
        // Width
        self.imageTypeUrl = imageTypeUrl
        self.title = title
        self.imageType = imageType
        self.this = this
        // sourceId
        self.dataSourceFields = dataSourceFields
        self.description = description
        self.contentUrl = contentUrl
        self.uploadImageUrl = uploadImageUrl
        self.language = language
        self.created = created
        self.url = url
        self.align = align
        self.modified = modified
        self.position = position
        self.editability = editability
        self.initialized = true
    }
    
    init(){
        uid = ""
        scheduleUrls = []
        height = 0
        width = 0
        imageTypeUrl = ""
        title = ""
        imageType = ""
        this = ""
        contentObject = 0
        dataSourceFields = []
        description = ""
        contentUrl = ""
        uploadImageUrl = ""
        language = ""
        created = ""
        url = ""
        align = ""
        modified = ""
        position = 0
        editability = ""
        initialized = false
    }
    
    var uid: String
    var scheduleUrls: [String]
    var height: Any
    var width: Any
    var imageTypeUrl: String
    var title: String
    var imageType: String
    var this: String
    var contentObject: Any
    var dataSourceFields: [String]
    var description: String
    var contentUrl: String
    var uploadImageUrl: String
    var language: String
    var created: String
    var url: String
    var align: String
    var modified: String
    var position: Int
    var editability: String
    var initialized: Bool
}

struct Schedule{
    
    init?(url: String, completion: @escaping (_ schedule: Schedule) -> ()){
        self.init()
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com" + url)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                print(error.debugDescription)
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                completion(Schedule(json: json as! [String:Any])!)
            }
        }
        task.resume()
    }
    
    init?(json: [String:Any]){
        self.init()
        
        guard let status = json["status"] as? String,
            let localeUrls = json["locale_urls"] as? [String],
            let ends = json["ends"],
            let affiliateUrls = json["affiliate_urls"] as? [String],
            let uid = json["uid"] as? String,
            let customerTypeUrls = json["customer_type_urls"] as? [String],
            let rights = json["rights"] as? Bool,
            let languageUrls = json["language_urls"] as? [String],
            let starts = json["starts"] as? String,
            let this = json["self"] as? String,
            let title = json["title"] as? String,
            let modified = json["modified"] as? String,
            let slug = json["slug"] as? String,
            let created = json["created"] as? String,
            let lastDataIngest = json["last_data_ingest"],
            let regionUrls = json["region_urls"] as? [String],
            let deviceTypeUrls = json["device_type_urls"] as? [String],
            let editability = json["editability"] as? String,
            let dataSourceId = json["data_source_id"] as? String,
            let reusable = json["reusable"] as? Bool
            else{
                return nil
        }
        
        self.status = status
        self.localeUrls = localeUrls
        self.ends = ends
        self.affiliateUrls = affiliateUrls
        self.uid = uid
        self.customerTypeUrls = customerTypeUrls
        self.rights = rights
        self.languageUrls = languageUrls
        self.starts = starts
        self.this = this
        self.title = title
        self.modified = modified
        self.slug = slug
        self.created = created
        self.lastDataIngest = lastDataIngest
        self.regionUrls = regionUrls
        self.deviceTypeUrls = deviceTypeUrls
        self.editability = editability
        self.dataSourceId = dataSourceId
        self.reusable = reusable
        self.initialized = true
        
        
    }
    
    init(){
        status = ""
        localeUrls = []
        ends = ""
        affiliateUrls = []
        uid = ""
        customerTypeUrls = []
        rights = false
        languageUrls = []
        starts = ""
        this = ""
        title = ""
        modified = ""
        slug = ""
        created = ""
        lastDataIngest = ""
        regionUrls = []
        deviceTypeUrls = []
        editability = ""
        dataSourceId = ""
        reusable = false
        initialized = false
    }
    
    // Current = Next
    var status: String
    var localeUrls: [String]
    var ends: Any
    var affiliateUrls: [String]
    var uid: String
    var customerTypeUrls: [String]
    var rights: Bool
    var languageUrls: [String]
    var starts: String
    var this: String
    var title: String
    var modified: String
    var slug: String
    var created: String
    var lastDataIngest: Any
    var regionUrls: [String]
    var deviceTypeUrls: [String]
    var editability: String
    var dataSourceId: String
    var reusable: Bool
    var initialized: Bool
}





struct Channel{
    
    
    
    
}

struct EventVideosOnly{
    
    init?(url: String, completion: @escaping (EventVideosOnly) -> ()){
        let fields = "?fields=name,official_name,sessionoccurrence_urls"
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/" + url + fields)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                print(error.debugDescription)
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                completion(EventVideosOnly(json: json)!)
            }
        }
        task.resume()
    }
    
    init?(json: [String:Any]){
        guard let name = json["name"] as? String,
            let officialName = json["official_name"] as? String,
            let sessions = json["sessionoccurrence_urls"] as? [String]
            else{
                return nil
        }
        
        self.name = name
        self.officialName = officialName
        self.sessions = sessions
        
    }
    
    init(){
        
    }
    
    var name: String = ""
    var officialName: String = ""
    var sessions: [String] = []
    
}

struct RaceSeasonMinimal{
    
    init?(url: String, completion: @escaping (_ seasonMinimal: RaceSeasonMinimal) -> ()){
        let fields = "?fields=name,self,has_content,year,eventoccurrence_urls,uid"
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/" + url + fields)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                print(error.debugDescription)
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                completion(RaceSeasonMinimal(json: json)!)
            }
        }
        task.resume()
        
    }
    
    init?(json: [String:Any]){
        guard let uid = json["uid"] as? String,
            let this = json["self"] as? String,
            let hasContent = json["has_content"] as? Bool,
            let year = json["year"] as? Int,
            let events = json["eventoccurrence_urls"] as? [String],
            let name = json["name"] as? String
            else{
                return nil
        }
        
        self.uid = uid
        self.this = this
        self.hasContent = hasContent
        self.year = year
        self.events = events
        self.name = name
        
    }
    
    init(){
        
    }
    
    var uid: String = ""
    var this: String = ""
    var hasContent: Bool = false
    var year: Int = 0
    var events: [String] = []
    var name: String = ""
    
    
}

struct ExtendedEpisode{

    init?(url: String, completion: @escaping (ExtendedEpisode) -> ()){
        
        // Extend image urls
        let fields = "?fields=title,items,image_urls,created&fields_to_expand=image_urls"
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/" + url + fields)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                print(error.debugDescription)
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                completion(ExtendedEpisode(json: json)!)
            }
        }
        task.resume()
        
    }
    
    init?(json: [String:Any]){
        guard let items = json["items"] as? [String],
            let title = json["title"] as? String,
            let imageUrls = json["image_urls"] as? [[String:Any]],
            let imageUrl = imageUrls.first!["url"] as? String,
            let date = json["created"] as? String
            else{
                return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        self.items = items
        self.title = title
        self.imageUrl = imageUrl
       
        self.date = formatter.date(from: date)!
        
    }
    
    init(){
        
    }
    
    var items: [String] = []
    var title: String = ""
    var imageUrl: String = ""
    var date: Date = Date(timeIntervalSince1970: 0)
    
}
