//
//  HomeViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/12/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
class HomeViewController: UIViewController {

    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let lightBlueUI = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        Utilities.styleFilledButton(loginButton, lightBlueUI, UIColor.white)
        Utilities.styleFilledButton(signUpButton, lightBlueUI, UIColor.white)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser!.isEmailVerified == false {
                 let yeetVC = UIStoryboard(name:
                 "main", bundle: nil).instantiateViewController(withIdentifier: "verifyVC")

                 self.view.window?.rootViewController = yeetVC
                 self.view.window?.makeKeyAndVisible()
                 
             }
            else {
                let db = Firestore.firestore()
                let uid = Auth.auth().currentUser?.uid
                db.collection("users").document(uid!).getDocument() { (document, error) in
                    if let document = document, document.exists {
                        let username = document.get("username")
                        let email = document.get("email")
                        let password = document.get("password")
                        let pathStr = document.get("profilePath")
                        Global.email = email as! String
                        Global.username = username as! String
                        Global.uid = uid!
                        Global.password = password as! String
                        Global.profilePath = pathStr as! String

                }
            if error != nil {
                print("error")
            }
            }
            //transition
              let yeetVC = UIStoryboard(name:
                "tabBar", bundle: nil).instantiateViewController(withIdentifier: "tabBarID")
              
              self.view.window?.rootViewController = yeetVC
              self.view.window?.makeKeyAndVisible()
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
