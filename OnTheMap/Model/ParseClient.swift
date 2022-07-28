//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation

class ParseClient{
    
    struct Auth{
        static var objectId = ""
        static var createdAt = ""
        static var updatedAt = ""
    }
    
    enum Endpoints{
        case getStudentLocation
        case postStudentLocation
        case putStudentLocation
        
        var stringValue: String{
            switch self {
            case .getStudentLocation: return "https://onthemap-api.udacity.com/v1/StudentLocation?limit=100&order=-updatedAt"
            case .postStudentLocation: return "https://onthemap-api.udacity.com/v1/StudentLocation"
            case .putStudentLocation: return
                "https://onthemap-api.udacity.com/v1/StudentLocation/\(Auth.objectId)"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    
    class func getStudentLocation(completionHandler:@escaping ([Student], Error?)->Void){
        
        taskForGetRequest(url: Endpoints.getStudentLocation.url, response: StudentLocationResponse.self) { response, error in
            if let response = response {
                completionHandler(response.results, nil)
            }else{
                completionHandler([], error)
            }
        }
    }
    
    class func postStudentLocation(uniqueKey:String, firstName:String, lastName:String, mapString:String, mediaURl:String, latiude:Double, longitude:Double, completionHandler:@escaping (Bool, Error?)->Void){
        
        let body = LocationRequest(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURl, latitude: latiude, longitude: longitude)

        
        taskForPostRequest(url: Endpoints.postStudentLocation.url, response: PostStudentResponse.self, requestBody: body) { response, error in
            if let response = response {
                Auth.objectId = response.objectId
                Auth.createdAt = response.createdAt
                completionHandler(true, nil)
            }else{
                completionHandler(false, error)
            }
        }
    }
    
    
    class func taskForGetRequest<ResponseType: Decodable>(url:URL, response: ResponseType.Type, completionHandler:@escaping (ResponseType?, Error?)->Void){
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
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
    
    class func taskForPostRequest<ResponseType:Decodable, RequestType:Encodable>(url:URL, response: ResponseType.Type, requestBody: RequestType, completionHandler:@escaping (ResponseType?, Error?)->Void){
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = requestBody
        
        let encoder = JSONEncoder()
        do{
            let postObject = try encoder.encode(body)
            request.httpBody = postObject
        }catch{
            print(error.localizedDescription)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            }catch{
                do{
                    let errorObject = try decoder.decode(PostStudentError.self, from: data)
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
    
}
