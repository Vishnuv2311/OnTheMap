//
//  UdacityError.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation

struct UdacityError: Codable{
    let status: Int
    let error: String
}

extension UdacityError: LocalizedError{
    var errorDescription: String?{
        return error
    }
}
