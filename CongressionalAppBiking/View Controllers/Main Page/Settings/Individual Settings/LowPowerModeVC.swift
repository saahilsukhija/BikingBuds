//
//  LowPowerModeVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 7/18/24.
//

import UIKit

class LowPowerModeVC: UIViewController {
    
    static let identifier = "LowPowerModeScreen"
    
    @IBOutlet weak var powerSwitch: UISwitch!
    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backView.layer.cornerRadius = 10
        backView.dropShadow()
        
        navigationController?.navigationItem.title = "Low Power Mode"
        self.title = "Low Power Mode"
        
        setupSwitch()
        
        
    }
    
    func setupSwitch() {
        if UserSettings.shared.lowPowerModeEnabled {
            powerSwitch.isOn = true
        } else {
            powerSwitch.isOn = false
        }
    }
    
    @IBAction func switchClicked(_ sender: Any) {

        if powerSwitch.isOn {
            //will be enabled
            UserSettings.shared.enableLowPowerMode()
        }
        else {
            //will be disabled
            UserSettings.shared.enableLowPowerMode(false)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
