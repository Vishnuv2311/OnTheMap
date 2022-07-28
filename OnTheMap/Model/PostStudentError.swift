//
//  PostStudentError.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation

struct PostStudentError: Codable{
    let code: Int
    let error: String
}

extension PostStudentError: LocalizedError{
    var errorDescription: String?{
        return error
    }
}
