//
//  ViewController.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signupButton: UIButton!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
     //   self.toolbar.isHidden = true
        setLoggingIn(false)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotification()
    }
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        setLoggingIn(true)
        UdacityClient.loginRequest(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completionHandler: handleLoginRequest(success:error:))
    }
    
    @IBAction func signupButton(_ sender: Any) {
        UIApplication.shared.open(UdacityClient.Endpoints.signup.url, options: [:], completionHandler: nil)
    }
    
    @IBAction func facebookLoginButton(_ sender: Any) {
    }
    
    
    func handleLoginRequest(success:Bool, error:Error?){
        if success{
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
            
        }else{
            setLoggingIn(false)
            showLoginFaliure(message: error?.localizedDescription ?? "")
        }
    }
    
    func showLoginFaliure(message: String){
        let alertVC = UIAlertController(title: "Login failed", message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "try again", style: UIAlertAction.Style.default)
        alertVC.addAction(alertAction)
        show(alertVC, sender: nil)
    }
    
    func setLoggingIn(_ loggingIn:Bool){
        if loggingIn{
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signupButton.isEnabled = !loggingIn
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func getKeyboardHeight(_ notification : Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardHeight = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardHeight.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        if passwordTextField.isFirstResponder && view.frame.origin.y == 0{
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
