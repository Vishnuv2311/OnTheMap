//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation
import UIKit

class UdacityClient{
    
    struct UserDetails{
        static var userId = ""
        static var sessionId = ""
    }
    
    enum Endpoints{
        case login
        case getPublicUserData
        case signup
        case logout
 
        var stringValue: String{
            switch self {
            case .login: return
                "https://onthemap-api.udacity.com/v1/session"
            case .getPublicUserData: return "https://onthemap-api.udacity.com/v1/users/\(UserDetails.userId)"
            case .signup: return "https://auth.udacity.com/sign-up"
            case .logout: return "https://onthemap-api.udacity.com/v1/session"
            }
        }
        
        var url:URL{
            return URL(string: stringValue)!
        }
    }

    class func loginRequest(username:String, password:String, completionHandler:@escaping (Bool, Error?)->Void){
        
        let subBody = UdacitySession(username: username, password: password)
        let body = Loginrequest(udacity: subBody)
        
        taskForPostRequest(url: Endpoints.login.url, response: UdacityResponse.self, requestBody: body) { response, error in
            if let response = response {
                UserDetails.userId = response.account.key
                UserDetails.sessionId = response.session.id
                
                completionHandler(true, nil)
                
                print(response.account.registered)
                print(response.account.key)
                print(response.session.expiration)
                print(response.session.id)
            }else{
                completionHandler(false, error)
            }
        }

    }
    
    class func getUserData(completionHandler:@escaping (GetUserData?, Error?)->Void){
        
        taskForGetRequest(url: Endpoints.getPublicUserData.url, response: GetUserData.self) { response, error in
            if let response = response {
                completionHandler(response, nil)
            }else{
                completionHandler(nil, error)
            }
        }
    }
    
    class func logoutSession(completionHandler:@escaping()->Void){
        taskForDeleteRequest(url: Endpoints.logout.url, response: UdacityDeleteResponse.self) { response, error in
            if let response = response {
                UserDetails.sessionId = response.session.id
                print(response.session.id)
                print("the session has expired on \(response.session.expiration)")
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url:URL, response:ResponseType.Type, completionHandler:@escaping (ResponseType?, Error?)->Void){
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let dataCount = data.count
            let range = (5..<dataCount)
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForPostRequest<ResponseType:Decodable, RequestType:Encodable>(url:URL, response:ResponseType.Type, requestBody:RequestType, completionHandler:@escaping (ResponseType?, Error?)->Void){
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = requestBody
        let encoder = JSONEncoder()
        do{
            let postObject = try encoder.encode(body)
            request.httpBody = postObject
        }catch{
            print(error)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                    print(error!)
                }
                return
            }
            
            let dataCount = data.count
            let range = (5..<dataCount)
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            do{
                let responseobject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completionHandler(responseobject, nil)
                }
            }catch{
                do{
                    let errorObject = try decoder.decode(UdacityError.self, from: newData)
                    print(errorObject)
                    DispatchQueue.main.async {
                        completionHandler(nil, errorObject)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func taskForDeleteRequest<ResponseType:Decodable>(url:URL, response:ResponseType.Type, completionHandler:@escaping (ResponseType?, Error?)->Void){
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                return
            }
            let dataCount = data.count
            let range = (5..<dataCount)
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                completionHandler(responseObject, nil)
            }catch{
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
}
