//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by Created by Vishnu V on 29/07/22.
//

import Foundation
import UIKit

extension UIViewController{
    @IBAction func logoutButton(_ sender: UIBarButtonItem){
        UdacityClient.logoutSession {
            print("Session with the sessionID \(UdacityClient.UserDetails.sessionId) has expired")
            self.dismiss(animated: true, completion: nil)
        }
    }
}
