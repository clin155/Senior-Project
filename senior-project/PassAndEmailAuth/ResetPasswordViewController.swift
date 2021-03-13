//
//  resetPasswordViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/16/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        if self.emailTextField.text != "" {
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!) { error in
                if error != nil {
                    print(error!)
                    
                }
                }
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            
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
