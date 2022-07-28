//
//  GetUserData.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation


struct GetUserData: Codable{
    let firstName: String
    let lastName: String
    let bio: String?
    let registered: Bool
    let linkedIn: String?
    let location: String?
    let key: String
    let imageUrl: String?
    let nickname: String?
    let website: String?
    let occupation: String?
        
        
        
    enum CodingKeys: String, CodingKey {
        case bio
        case registered = "_registered"
        case linkedIn = "linkedin_url"
        case imageUrl = "_image_url"
        case key
        case location
        case nickname
        case website = "website_url"
        case occupation
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
    
