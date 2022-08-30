//
//  GetUserVC.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation
import UIKit

class GetUSerVC: UIViewController, ViewDelegate{
   
    @IBOutlet weak var userLocationTextField: UITextField!
    
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotification()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postStudentLocation"{
            let controller = segue.destination as! AddMapLocation
            controller.mapString = self.userLocationTextField.text ?? ""
            controller.viewDelegate = self
        }
    }
    
    func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    @IBAction func findUserOnMap(_ sender: Any) {
        self.performSegue(withIdentifier: "postStudentLocation", sender: nil)
    }
}

extension GetUSerVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == ""{
            textField.text = "Enter Your Location Here (City, State)"
        }
        return true
    }
    
    func getKeyboardHeight(_ notification : Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardHeight = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardHeight.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        if userLocationTextField.isFirstResponder && view.frame.origin.y == 0{
            view.frame.origin.y == 0
        }
    }
    
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        if view.frame.origin.y != 0{
            view.frame.origin.y = 0
        }
    }
}
