//
//  MapTypeSelectVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/19/24.
//

import UIKit
import MapKit
class MapTypeSelectVC: UIViewController {

    static let identifier = "MapTypeSelectScreen"
    
    @IBOutlet weak var standardView: UIView!
    @IBOutlet weak var hybridView: UIView!
    @IBOutlet weak var satelliteView: UIView!
    
    @IBOutlet weak var standardMapView: UIImageView!
    @IBOutlet weak var hybridMapView: UIImageView!
    @IBOutlet weak var satelliteMapView: UIImageView!
    
    @IBOutlet weak var standardCheckboxImageView: UIImageView!
    @IBOutlet weak var hybridCheckboxImageView: UIImageView!
    @IBOutlet weak var satelliteCheckboxImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        standardView.isUserInteractionEnabled = true
        hybridView.isUserInteractionEnabled = true
        satelliteView.isUserInteractionEnabled = true
        
        standardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(standardViewClicked)))
        hybridView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hybridViewClicked)))
        satelliteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(satelliteViewClicked)))
        
        
        if UserSettings.shared.mapType == .standard {
            standardViewClicked()
        } else if UserSettings.shared.mapType == .hybrid {
            hybridViewClicked()
        } else {
            satelliteViewClicked()
        }
        
        //self.navigationController?.navigationBar.topItem?.title = "Choose Icon Type"
        navigationController?.navigationItem.title = "Choose Map Type"
        self.title = "Choose Map Type"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    @objc func standardViewClicked() {
        standardCheckboxImageView.image = UIImage(systemName: "checkmark.circle.fill")
        hybridCheckboxImageView.image = UIImage(systemName: "circle")
        satelliteCheckboxImageView.image = UIImage(systemName: "circle")
        UserSettings.shared.changeMapType(.standard)
        NotificationCenter.default.post(name: .mapTypePreferenceChanged, object: nil)
        
    }
    
    @objc func hybridViewClicked() {
        hybridCheckboxImageView.image = UIImage(systemName: "checkmark.circle.fill")
        standardCheckboxImageView.image = UIImage(systemName: "circle")
        satelliteCheckboxImageView.image = UIImage(systemName: "circle")
        UserSettings.shared.changeMapType(.hybrid)
        NotificationCenter.default.post(name: .mapTypePreferenceChanged, object: nil)
        
    }
    
    @objc func satelliteViewClicked() {
        satelliteCheckboxImageView.image = UIImage(systemName: "checkmark.circle.fill")
        hybridCheckboxImageView.image = UIImage(systemName: "circle")
        standardCheckboxImageView.image = UIImage(systemName: "circle")
        UserSettings.shared.changeMapType(.satellite)
        NotificationCenter.default.post(name: .mapTypePreferenceChanged, object: nil)
        
    }
    
    
    
    

}
