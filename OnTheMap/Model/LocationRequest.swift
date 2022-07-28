//
//  LocationRequest.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation

struct LocationRequest: Codable{
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
