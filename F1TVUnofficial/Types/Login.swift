//
//  File.swift
//  F1TVUnofficial
//
//  Created by Markus Ort on 25.09.19.
//  Copyright © 2019 Markus Ort. All rights reserved.
//

import Foundation

protocol loginDelegate{
    func onLoginError(_ message: String)
    func onLoginSuccess()
}

class LoginManager{
    
    static let shared = LoginManager()
    
    var delegate:loginDelegate?
    var successDelegate:loginDelegate?
    
    func loggedIn() -> Bool{
        if isLoggedIn{
            return isLoggedIn
        }
        if hasSavedData(){
            loginFromSave()
            return isLoggedIn
        }
        return false
        
    }
    
    
    
    func hasSavedData() -> Bool {
        return UserDefaults.standard.object(forKey: "user") != nil && UserDefaults.standard.object(forKey: "pass") != nil
    }
    
    func loginWithCreds(user: String, pass: String){
        var request = URLRequest(url: URL(string: url)!)
        let body = "{\"Login\": \"\(user)\", \"Password\": \"\(pass)\"}"
        request.httpBody = body.data(using: .utf8)
        self.user = user
        self.pass = pass
        self.loginGroup.enter()
        loginTask(request: request)
        self.loginGroup.wait()
        
    }
    
    
    func loginTask(request: URLRequest){
        var request = request
        request.addValue("AH5B283RFx1K2AfT6z99ndGE7L2VZL62", forHTTPHeaderField: "apiKey");
        request.addValue("60a9ad84-e93d-480f-80d6-af37494f2e22", forHTTPHeaderField: "CD-SystemId");
        request.addValue("en-US", forHTTPHeaderField: "CD-Language")
        request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("PostmanRuntime/7.17.1", forHTTPHeaderField: "User-Agent")
        request.addValue("api.formula1.com", forHTTPHeaderField: "Host")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.timeoutInterval = 10000
        self.loginGroup.enter()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                print(error.debugDescription)
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    self.loginGroup.leave()
                    return;
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                guard let Fault = json["Fault"] as? [String:Any]
                    else{
                        var subscriptionStatus = ""
                        var subscriptionToken = ""
                        if let data = json["data"] as? [String:String]{
                            subscriptionToken = data["subscriptionToken"]!
                            subscriptionStatus = data["subscriptionStatus"]!
                        }
                        var subId = ""
                        var country = ""
                        var firstName = ""
                        if let data = json["SessionSummary"] as? [String:Any]{
                            subId = String(data["SubscriberId"] as! Int32)
                            country = data["HomeCountry"] as! String
                            firstName = data["FirstName"] as! String
                        }
                        
                        
                        self.cookie = "account-info:{\"data\": {\"subscriptionStatus\": \"\(subscriptionStatus)\", \"subscriptionToken\": \"\(subscriptionToken)\"},\"profile\": {\"SubscriberId\":\"\(subId)\",\"country\":\"\(country)\",\"firstName\":\"\(firstName)\"}}"
                        
                        self.isLoggedIn = true;
                        self.firstName = firstName
                        if self.user != "" && self.pass != "" {
                            UserDefaults.standard.setValue(self.user, forKey: "user")
                            UserDefaults.standard.setValue(self.pass, forKey: "pass")
                        }
                        
                        self.delegate?.onLoginSuccess()
                        self.loginGroup.leave()
                        return;
                       

                }
                self.loginGroup.leave()
                self.delegate?.onLoginError(Fault["Message"] as! String)
                
            }
            
        }
        task.resume()
        self.loginGroup.leave()
    }
    
    func loginFromSave(){
        
        if UserDefaults.standard.object(forKey: "user") == nil || UserDefaults.standard.object(forKey: "pass") == nil{
            
            return;
        }
        
        let body = "{\"Login\": \"\(UserDefaults.standard.string(forKey: "user")!)\", \"Password\": \"\(UserDefaults.standard.string(forKey: "pass")!)\"}"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpBody = body.data(using: .utf8)
        self.loginGroup.enter()
        loginTask(request: request)
        self.loginGroup.wait()
        
    }
    
    func logout(){
        cookie = String()
        isLoggedIn = false
        firstName = "Login"
        user = String()
        pass = String()
        UserDefaults.standard.setValue(nil, forKey: "user")
        UserDefaults.standard.setValue(nil, forKey: "pass")
    }
    
    public var cookie: String = String()
    private var isLoggedIn: Bool = false
    public var firstName: String = "Login"
    private var user: String = String()
    private var pass: String = String()
    private let url = "https://api.formula1.com/v1/account/Subscriber/CreateSession"
    let loginGroup = DispatchGroup()
}
