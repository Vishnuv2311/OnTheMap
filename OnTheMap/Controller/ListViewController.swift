//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Vishnu V on 29/07/22.
//

import Foundation

import UIKit

class ListViewController:UIViewController{
    
    
    @IBOutlet var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        getStudentLocation()
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        getStudentLocation()
    }
    
    @IBAction func logout(_ sender: Any) {
        self.tabBarController?.dismiss(animated: true)
    }
    
    @IBAction func postStudentLocation(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = true
        performSegue(withIdentifier: "tableStudentPin", sender: nil)
    }
    
    func getStudentLocation(){
        ParseClient.getStudentLocation { students, error in
            if error == nil{
                StudentModel.iOSNDStudent = students
                self.tableView.reloadData()
            }else{
                self.getStudentLocationError(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func getStudentLocationError(message:String){
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alertVC.addAction(alertAction)
        present(alertVC, animated: true, completion: nil)
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.iOSNDStudent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")!
        let student = StudentModel.iOSNDStudent[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = UIImage(named: "icon_pin")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentModel.iOSNDStudent[(indexPath as NSIndexPath).row]
        if student.mediaURL.hasPrefix("https://") || student.mediaURL.hasPrefix("http://"){
            let url = URL(string: student.mediaURL)
            if let url = url{
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }else{
            let urlString = "https://\(student.mediaURL)"
            let url = URL(string: urlString)
            if let url = url{
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
    }
}
