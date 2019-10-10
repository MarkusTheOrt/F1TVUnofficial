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
    func onNoConnection()
}

class LoginManager{
    
    static let shared = LoginManager();
    var delegate:loginDelegate?;
    private var user: String = String();
    private var pass: String = String();
    private var subscriptionToken = String();
    private var identityProvider = String();
    public var authToken = String();
    private var isLoggedIn: Bool = false;
    public var cookie: String = String();
    public var firstName: String = "Login";
    
    
    let loginGroup = DispatchGroup();
    
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
    
    /**
     * Logging in using the view controller (no saved data)
     */
    func loginWithCreds(user: String, pass: String){
        if isLoggedIn { return; }
        var request = URLRequest(url: URL(string: "https://api.formula1.com/v1/account/Subscriber/CreateSession")!)
        let body = "{\"Login\": \"\(user)\", \"Password\": \"\(pass)\"}"
        request.httpBody = body.data(using: .utf8)
        self.user = user
        self.pass = pass
        loginTask(request: request)
        
    }
    
    /**
     * Gets Session cookie from the api over at account.formula1.com
     */
    func loginTask(request: URLRequest){
        var request = request
        request.addValue("AH5B283RFx1K2AfT6z99ndGE7L2VZL62", forHTTPHeaderField: "apiKey");
        request.addValue("60a9ad84-e93d-480f-80d6-af37494f2e22", forHTTPHeaderField: "CD-SystemId");
        request.addValue("en-US", forHTTPHeaderField: "CD-Language")
        request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("api.formula1.com", forHTTPHeaderField: "Host")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.timeoutInterval = 10000
        self.loginGroup.enter()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                if let nserror = error as NSError?{
                    if nserror.code == NSURLErrorNotConnectedToInternet{
                        self.loginGroup.leave()
                        self.delegate?.onNoConnection();
                    }
                }
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
                        
                        
                        self.cookie = "account-info:{\"data\":{\"subscriptionStatus\":\"\(subscriptionStatus)\",\"subscriptionToken\":\"\(subscriptionToken)\"},\"profile\":{\"SubscriberId\":\"\(subId)\",\"country\":\"\(country)\",\"firstName\":\"\(firstName)\"}}"
                        
                        self.isLoggedIn = true;
                        self.firstName = firstName;
                        self.subscriptionToken = subscriptionToken;
                        if self.user != "" && self.pass != "" {
                            UserDefaults.standard.setValue(self.user, forKey: "user")
                            UserDefaults.standard.setValue(self.pass, forKey: "pass")
                        }
                        
                        self.delegate?.onLoginSuccess()
                        self.loginGroup.leave()
                        return;
                       

                }
                
                self.delegate?.onLoginError(Fault["Message"] as! String)
                self.loginGroup.leave()
            }
            
        }
        task.resume()
        self.loginGroup.wait();
        GetIdentityProvider();
    }
    
    /**
     * logging in using saved data
     */
    func loginFromSave(){
        if(isLoggedIn) { return; }
        if UserDefaults.standard.object(forKey: "user") == nil
        || UserDefaults.standard.object(forKey: "pass") == nil {
            return;
        }
        
        let body = "{\"Login\": \"\(UserDefaults.standard.string(forKey: "user")!)\", \"Password\": \"\(UserDefaults.standard.string(forKey: "pass")!)\"}"
        var request = URLRequest(url: URL(string: "https://api.formula1.com/v1/account/Subscriber/CreateSession")!)
        request.httpBody = body.data(using: .utf8)
        loginTask(request: request)
    }
    
    
    /**
     * Retrieves the users Identity provider.
     */
    func GetIdentityProvider() {
        if !self.isLoggedIn {
            return;
        }
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/identity-providers/?name=dlbi")!);
        request.addValue("application/json", forHTTPHeaderField: "Accept");
        request.addValue("en-EN", forHTTPHeaderField: "accept-language");
        request.addValue(self.cookie, forHTTPHeaderField: "cookie");
        self.loginGroup.enter()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if error != nil {
                print(error.debugDescription);
                self.loginGroup.enter();
                return;
            }
           
            guard let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) else {
                print("Identity Error");
                    self.loginGroup.leave();
                    return;
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                guard let objects = json["objects"] as? [[String:Any]],
                    let identityProvider = objects.first!["self"] as? String
                    else {
                        print("Error Retrieveing Identity Provider.");
                        self.loginGroup.leave();
                        return;
                }
                self.identityProvider = identityProvider;
            }
            self.loginGroup.leave();
        }
        task.resume();
        self.loginGroup.wait()
        GetApiToken();
    }
    
    /**
     * Retrieves the JWT Token from the API. Requires to be logged in successfully.
     */
    func GetApiToken(){
        if(!isLoggedIn) { return; }
        var request = URLRequest(url: URL(string: "https://f1tv.formula1.com/api/social-authenticate/")!);
        request.addValue("application/json", forHTTPHeaderField: "Accept");
        request.addValue("en-EN", forHTTPHeaderField: "accept-language");
        request.httpMethod = "POST";
        let httpBody = "{\"identity_provider_url\": \"\(self.identityProvider)\", \"access_token\":\"\(self.subscriptionToken)\"}";
        request.httpBody = httpBody.data(using: .utf8);
        self.loginGroup.enter();
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if error != nil {
                print(error.debugDescription);
                self.loginGroup.enter();
                return;
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) else {
                print("Identity Error");
                    self.loginGroup.leave();
                    return;
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:String]{
                guard let token = json["token"]
                    else {
                        print("Error Receiving JWT Token");
                        self.loginGroup.leave()
                        return;
                }
                self.authToken = token;
            }
            self.loginGroup.leave();
        }
        task.resume()
        self.loginGroup.wait();
        
    }
    
    /**
     * Removes saved login information. removes all session info.
     */
    func logout(){
        cookie = String()
        isLoggedIn = false
        firstName = "Login"
        user = String()
        pass = String()
        UserDefaults.standard.setValue(nil, forKey: "user")
        UserDefaults.standard.setValue(nil, forKey: "pass")
    }
    

}
