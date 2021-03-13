
//
//  popUpViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/14/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit

class popUpViewController: UIViewController {

    @IBOutlet weak var errorTextView: UITextView!
    var errorStr = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextView.centerVertically()
        errorTextView.text = errorStr
        // Do any additional setup after loading the view.
    }
    
    @IBAction func okTapped(_ sender: Any) {
        let yeetVC = UIStoryboard(name:
        "tabBar", bundle: nil).instantiateViewController(withIdentifier: "tabBarID")
        
        self.view.window?.rootViewController = yeetVC
        self.view.window?.makeKeyAndVisible()
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

