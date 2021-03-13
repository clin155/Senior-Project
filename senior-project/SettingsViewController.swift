//
//  settingsViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/16/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class SettingsViewController: UIViewController {

    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var resetEmailButton: UIButton!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var deleteAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView.bounds = self.view.bounds
        popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height*0.3)
        Utilities.styleHollowButton(resetPasswordButton, UIColor.red, UIColor.red, UIColor.white)
        Utilities.styleHollowButton(resetEmailButton, UIColor.red, UIColor.red, UIColor.white)
        Utilities.styleHollowButton(deleteAccountButton, UIColor.red, UIColor.red, UIColor.white)
        // Do any additional setup after loading the view.
    }
    func animateIn(_ desiredView: UIView) {
        let backgroundView = self.view!
        backgroundView.addSubview(desiredView)
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
            desiredView.center = backgroundView.center
        })
    }
    func animateOut(_ desiredView: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            desiredView.alpha = 0
        }, completion: { _ in
            desiredView.removeFromSuperview()
        })
    }
    @IBAction func resetPasswordTapped(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: Global.email) { error in
            if error != nil {
                print(error!)

            }
            }
        animateIn(blurView)
        animateIn(popUpView)
    }
    @IBAction func resetEmailTapped(_ sender: Any) {
    }
    @IBAction func deleteAccountTapped(_ sender: Any) {
    }
    @IBAction func okTapped(_ sender: Any) {
        animateOut(blurView)
        animateOut(popUpView)
    }
    
}
