//
//  ShareInviteCodeVC.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 9/9/21.
//

import UIKit

class ShareInviteCodeVC: UIViewController {

    @IBOutlet weak var groupCode: UILabel!
    var group: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        groupCode.text = group
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        let url = URL(string: "https://saahilsukhija.github.io/bikingbuds/redirect.html?id=\(group ?? "unknowngroup")")
        let activityController = UIActivityViewController(activityItems: ["Join my BikingBuds group! Here's the link: \(url!)"], applicationActivities: nil)

        activityController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityController, animated: true)
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
