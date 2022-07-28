//
//  AddMapLocationVC.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class AddMapLocation:UIViewController, MKMapViewDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var setStudentLinkTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    let locationManager = CLLocationManager()
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var location = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
        mapLoading(true)
        getUserCoordinate(addressString: mapString) { mapLocation, error in
            if error == nil {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: mapLocation.latitude, longitude: mapLocation.longitude)
                self.mapView.addAnnotation(annotation)
                self.mapLoading(false)
            }else{
                self.mapLoading(true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotification()
    }
    
    @IBAction func postPinButton(_ sender: Any) {
        mapLoading(true)
        getUserData(completionHandler: handleGetUserData(success:error:))
    }
    
    func getUserData(completionHandler:@escaping(Bool, Error?)->Void){
        UdacityClient.getUserData { userData, error in
            if let userData = userData {
                self.uniqueKey = userData.key
                self.firstName = userData.firstName
                self.lastName = userData.lastName
                completionHandler(true, nil)
            }else{
                self.showGetUserError(message: error?.localizedDescription ?? "")
                completionHandler(false, error)
            }
        }
    }
    
    func handleGetUserData(success:Bool, error:Error?){
        if success{
            ParseClient.postStudentLocation(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURl: self.setStudentLinkTextField.text ?? "", latiude: location.coordinate.latitude, longitude: location.coordinate.longitude, completionHandler: handlePostStudentLocation(success:error:))
        }
    }
    
    func handlePostStudentLocation(success:Bool, error:Error?){
        if error != nil{
            showPostStudentFailure(message: error?.localizedDescription ?? "")
        }else{
            print("firsName: \(firstName), lastName:\(lastName)  and mapstring:\(mapString)")
            let controller = self.navigationController?.viewControllers[0]
            _ = self.navigationController?.popToViewController(controller!, animated: true)
        }
    }
    
    func getUserCoordinate(addressString:String, completionHandler:@escaping (CLLocationCoordinate2D, Error?)->Void){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            if error == nil{
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    self.location = location
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.50, longitudeDelta: 0.50)
                    let cordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let region = MKCoordinateRegion(center: cordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            self.geocodingError()
            self.dismiss(animated: true, completion: nil)
            completionHandler(kCLLocationCoordinate2DInvalid, error)
        }
    }
    
    func showPostStudentFailure(message:String){
        //This is optional because the users cannot encounter this kind of error. It is only provided for other developers in case the developer supplies an incorrect encodable object model to the postStudentlocation method.
        let alertVC = UIAlertController(title: "Error posting student Location", message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "Try Again", style: UIAlertAction.Style.destructive)
        alertVC.addAction(alertAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func geocodingError() {
        let alertVC = UIAlertController(title: "Error", message: "Error finding location", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Enter another location", style: UIAlertAction.Style.default) { action in
            if let navController = self.navigationController{
                navController.popViewController(animated: true)
            }
        }
        alertVC.addAction(alertAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    
    func mapLoading(_ geocoding:Bool){
        if geocoding{
            loadingIndicator.startAnimating()
        }else{
            loadingIndicator.stopAnimating()
        }
        submitButton.isEnabled = !geocoding
    }
    
    func showGetUserError(message:String){
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action  in
            self.mapLoading(false)
        })
        alertVC.addAction(alertAction)
        present(alertVC, animated: true, completion: nil)
    }
}

extension AddMapLocation: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func getKeyboardHeight(_ notification : Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardHeight = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardHeight.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        if setStudentLinkTextField.isFirstResponder{
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
