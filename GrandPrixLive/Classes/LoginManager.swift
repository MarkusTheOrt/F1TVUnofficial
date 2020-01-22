//
//  LoginManager.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 12.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation
import UIKit

enum authURLs : String{
    case login = "https://api.formula1.com/v2/account/subscriber/authenticate/by-password"
    case registerDevice = "https://api.formula1.com/v1/account/Subscriber/RegisterDevice"
    case socialAuth = "https://f1tv-api.formula1.com/api/social-authenticate/"
    case syncSubscriptions = "https://f1tv-api.formula1.com/api/external/csg/sync-subscriptions/"
    case plans = "https://f1tv-api.formula1.com"
}

enum loginStates{
    case none // Not logged in at all
    case loggedIn // Authorized by password
    case registered // Device succesfully registered
    case apiAuth // Received JWT Token
    case subs // Synched Plans
    case plans // Received all plans
}

struct LoginData{
    
    var mail: String
    var pass: String
    var sessionId: String
    var subscriptionToken: String
    var JWT: String
    var activeSubscription: Bool
    var firstName: String
    var lastName: String
    var deviceAuthKey: String
    let deviceType: Int = 10
    var loginState: loginStates = .none
    
    init(){
        self.mail = ""
        self.pass = ""
        self.sessionId = ""
        self.subscriptionToken = ""
        self.JWT = ""
        self.activeSubscription = false
        self.firstName = ""
        self.lastName = ""
        self.deviceAuthKey = ""
    }
    
}

// Globally shared accessor for login data
var userData: LoginData = LoginData();

protocol loginDelegate{
    func loginSuccessful()
    func loginError(string: String?)
    func loginFinished()
}

protocol viewDelegate{
    func nowLoginView()
}

class LoginManager{
    
    public var delegate: loginDelegate? = nil
    public var vdelegate: viewDelegate? = nil
    public static let shared = LoginManager()
    
    // Load what we have from the vault
    init(){
        loadData()
    }
    
    private func parseLoginBody(mail: String, pass: String) -> String{
        return "{\"Language\":\"en-US\",\"Password\":\"\(pass)\",\"Login\":\"\(mail)\",\"DeviceType\":10}"
    }
    
    
    /**
     * Authenticates using email and password, retrieveing Subscription Token (and other Subscriber related stuff)
     */
    func Login(mail: String, pass: String){
        loadData()
        // Skip if user is already logged in
        if userData.subscriptionToken.count > 0{
            return
        }
        var request = URLRequest(url: URL(string: authURLs.login.rawValue)!)
        
        
        request.setValue("vKAAdZuLAuGEWd1BQhtsSNAazGXAych3", forHTTPHeaderField: "apikey")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip;q=1.0, compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "POST"
        request.httpBody = parseLoginBody(mail: mail, pass: pass).data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                if let nsError = error as NSError?{
                    if nsError.code == NSURLErrorNotConnectedToInternet{
                        self.delegate?.loginError(string: "No Internet Connection")
                        return
                    }
                }
                self.delegate?.loginError(string: nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let subscriber = json["Subscriber"] as? [String:Any]{
                    userData.mail = subscriber["Email"] as? String ?? ""
                    userData.firstName = subscriber["FirstName"] as? String ?? ""
                    userData.lastName = subscriber["LastName"] as? String ?? ""
                    userData.loginState = .loggedIn
                }
                if let sessionId = json["SessionId"] as? String{
                    userData.sessionId = sessionId
                }
                if let subData = json["data"] as? [String:String]{
                    userData.activeSubscription = subData["subscriptionStatus"] == "active"
                    userData.subscriptionToken = subData["subscriptionToken"] ?? ""
                }
                
                self.registerDevice()
            }
            
            
        }
        task.resume()
    }
    
    private func buildDeviceBody() -> String{
        return "{\"AllowPinlessPurchase\":true,\"PhysicalDevice\":{\"DeviceTypeCode\":10,\"DeviceId\":\"\(UIDevice.current.identifierForVendor?.uuidString ?? "GPLive-TVOS")\",\"PhysicalDeviceTypeCode\":1002},\"CreateSession\":true}"
    }
    
    /**
     * Registers current device onto the users F1 Account, there is a max of 6 devices that can be active at once.
     */
    private func registerDevice(){
        var request = URLRequest(url: URL(string: authURLs.registerDevice.rawValue)!)
        
        request.setValue("oKEI0KAvcOEU58zqCjlDK0zj7GOiPkou", forHTTPHeaderField: "apikey")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        request.setValue("10", forHTTPHeaderField: "CD-DeviceType")
        request.setValue("60a9ad84-e93d-480f-80d6-af37494f2e22", forHTTPHeaderField: "CD-SystemId")
        request.setValue(userData.sessionId, forHTTPHeaderField: "CD-SessionId")
        request.httpMethod = "POST"
        request.httpBody = buildDeviceBody().data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                if let nsError = error as NSError?{
                    if nsError.code == NSURLErrorNotConnectedToInternet{
                        self.delegate?.loginError(string: "No Internet Connection")
                        return
                    }
                }
                self.delegate?.loginError(string: nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let physDevice = json["PhysicalDevice"] as? [String:Any]{
                    userData.loginState = .registered
                    userData.deviceAuthKey = physDevice["AuthenticationKey"] as? String ?? ""
                }
            }
            self.socialAuth()
        }
        task.resume()
    }
    
    /**
     * Makes the Auth HTTP Body as String
     */
    private func buildAuthBody() -> String{
        return "{\"identity_provider_url\":\"/api/identity-providers/iden_732298a17f9c458890a1877880d140f3/\",\"access_token\":\"\(userData.subscriptionToken)\"}"
    }
    
    /**
     * Authorizes using Subscription Token and receiving a valid JWT Token
     */
    func socialAuth(){
        var request = URLRequest(url: URL(string: authURLs.socialAuth.rawValue)!)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "POST"
        request.httpBody = buildAuthBody().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                if let nsError = error as NSError?{
                    if nsError.code == NSURLErrorNotConnectedToInternet{
                        self.delegate?.loginError(string: "No Internet Connection")
                        return
                    }
                }
                self.delegate?.loginError(string: nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let token = json["token"] as? String{
                    userData.JWT = token
                    userData.loginState = .apiAuth
                }
            }
            self.synchTest()
        }
        task.resume()
    }
    
    
    func synchTest(){
        var request = URLRequest(url: URL(string: authURLs.syncSubscriptions.rawValue)!)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        request.setValue("JWT \(userData.JWT)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                if let nsError = error as NSError?{
                    if nsError.code == NSURLErrorNotConnectedToInternet{
                        self.delegate?.loginError(string: "No Internet Connection")
                        return
                    }
                }
                self.delegate?.loginError(string: nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let plans = json["plan_urls"] as? [String]{
                    if(plans.count > 0){
                        userData.loginState = .plans
                        userData.activeSubscription = true
                        self.delegate?.loginFinished()
                        self.vdelegate?.nowLoginView()
                        self.saveData()
                    }
                }
            }
        }
        task.resume()
    }
    
    /**
     * Returns the current Plan on the same thread
     */
    func getPlanDataSynch(plan: String) -> String{
        let taskGroup = DispatchGroup()
        var retString = ""
        var request = URLRequest(url: URL(string: "\(authURLs.plans.rawValue)\(plan)")!)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FOM/1.7.2 (com.formula1.ott; build:3445; iOS 13.3.0) Alamofire/4.4.0", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        
        taskGroup.enter()
        let task = URLSession.shared.dataTask(with: request){(data, response, error) -> Void in
            if(error != nil){
                if let nsError = error as NSError?{
                    if nsError.code == NSURLErrorNotConnectedToInternet{
                        self.delegate?.loginError(string: "No Internet Connection")
                        taskGroup.leave()
                        return
                    }
                }
                self.delegate?.loginError(string: nil)
                taskGroup.leave()
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]{
                if let plan = json["name"] as? String{
                    retString = plan
                }
            }
            
            taskGroup.leave()
            
        }
        task.resume()
        taskGroup.wait()
        return retString
    }
    
    
    /**
     * Save neccessary user data to authenticate in further attempts
     */
    func saveData(){
        UserDefaults.standard.set(userData.subscriptionToken, forKey: "subToken")
        UserDefaults.standard.set(userData.firstName, forKey: "firstName")
        UserDefaults.standard.set(userData.lastName, forKey: "lastName")
        UserDefaults.standard.set(userData.mail, forKey: "mail")
    }
    
    /**
     * Load data to reauthenticate using the subtoken
     */
    func loadData(){
        userData.subscriptionToken = UserDefaults.standard.string(forKey: "subToken") ?? ""
        userData.firstName = UserDefaults.standard.string(forKey: "firstName") ?? ""
        userData.lastName = UserDefaults.standard.string(forKey: "lastName") ?? ""
        userData.mail = UserDefaults.standard.string(forKey: "mail") ?? ""
        if(userData.subscriptionToken.count > 0 && userData.JWT.count == 0){
            socialAuth()
        }
        
    }
    
}
