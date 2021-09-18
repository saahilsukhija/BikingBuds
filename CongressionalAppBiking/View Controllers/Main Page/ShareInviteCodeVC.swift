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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
