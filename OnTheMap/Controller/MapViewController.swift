//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var results : [Student] = StudentModel.iOSNDStudent
    var annotations = [MKPointAnnotation]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        getStudentPin()
    }
   
    @IBAction func postStudentLocation(_ sender: Any) {
    //    self.tabBarController?.tabBar.isHidden = true
        performSegue(withIdentifier: "mapStudentPin", sender: nil)
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        getStudentPin()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.tabBarController?.dismiss(animated: true)
    }
    
    func getStudentPin(){
        ParseClient.getStudentLocation { students, error in
            if error == nil{
                self.results = students
                self.placeStudentPin()
            }else{
                self.getStudentLocationError(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func placeStudentPin(){
        for dictionary in results {
            let lat = CLLocationDegrees(dictionary.latitude)
            let lon = CLLocationDegrees(dictionary.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let firstName = dictionary.firstName
            let lastName = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    func getStudentLocationError(message:String){
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alertVC.addAction(alertAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if pinView == nil{
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.markerTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!{
                if toOpen.hasPrefix("https://") || toOpen.hasPrefix("http://"){
                    let url = URL(string: toOpen)!
                    app.open(url, options: [:], completionHandler: nil)
                }else{
                    let urlString = "https://\(toOpen)"
                    let url = URL(string: urlString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
                app.open(URL(string: toOpen)!)
            }
        }
    }
}
