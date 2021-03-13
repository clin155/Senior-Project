//
//  VerifyViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/16/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class VerifyViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.signUpButton.isEnabled = true
        //CSS

        let lightBlueUI = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        Utilities.styleFilledButton(signUpButton, lightBlueUI, UIColor.white)


        // Do any additional setup after loading the view.
    }
    @IBAction func resendEmail(_ sender: Any) {
        Auth.auth().currentUser!.sendEmailVerification { (error) in
            if error != nil {
                print(error!)
            }
        }
    }
    @IBAction func cancelTapped(_ sender: Any) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: Global.email, password: Global.password)
        user?.reauthenticate(with: credential, completion: { (result, error) in
            if error != nil {
                print(error!)
            }
        })
        user?.delete { error in
            if error != nil {
                print(error!)
          } else {
                Global.email = ""
                Global.password = ""
                Global.uid = ""
                Global.username = ""
                let yeetVC = UIStoryboard(name:
                "main", bundle: nil).instantiateViewController(withIdentifier: "homeVC")

                self.view.window?.rootViewController = yeetVC
                self.view.window?.makeKeyAndVisible()
          }
        }
    }
    func resetView() {
        self.activityInd.stopAnimating()
        self.signUpButton.isEnabled = true
    }
    func showError(_ message:String) {
        resetView()
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func showErrorAndDeAuthenticate(_ error: Error?, _ message:String) {
        print(error!)
        print(message)
        showError("There Was An Error. Please Try Again.")
        //add deauthenticate
        do {
            try Auth.auth().signOut()
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
        }
    @IBAction func signUpTapped(_ sender: Any) {
        self.activityInd.startAnimating()
        errorLabel.alpha = 0
        let seconds: Double = 2.0
        DispatchQueue.global().async {
            let dispatchTime: DispatchTime = DispatchTime.now() + seconds
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                DispatchQueue.main.async {
                    Auth.auth().currentUser!.reload { (error) in
                        if error != nil {
                            print(error!)
                        }
                    }
                    if Auth.auth().currentUser!.isEmailVerified == true{
                        let db = Firestore.firestore()
                        let defaultProf = UIImage(named: "blankProfile")
                            
                        guard let imageData = defaultProf?.jpegData(compressionQuality: 0.75) else {return}
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        let storageRef = Storage.storage().reference().child("images").child("profile photos").child(Global.uid + ".jpeg")
                        storageRef.putData(imageData, metadata: metadata) { (yeetdata, error) in
                            guard yeetdata != nil else {
                                self.showErrorAndDeAuthenticate(error, "error sending img data to storage")
                                return
                          }
                    
                          storageRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                self.showErrorAndDeAuthenticate(error, "error getting download URL")
                                return
                            }
                            let pathStr = "/images/profile photos/" + Global.uid + ".jpeg"
                            db.collection("users").document(Global.uid).setData(["username":Global.username, "email":Global.email,"password":Global.password,"uid": Global.uid, "profileURL": downloadURL.absoluteString , "profilePath": pathStr]) { (error) in
                                if error != nil {
                                    self.showErrorAndDeAuthenticate(error, "error writing to database")
                    
                                }
                                else{
                                    Global.profilePath = pathStr
                                    self.resetView()
                                    let yeetVC = UIStoryboard(name:
                                    "tabBar", bundle: nil).instantiateViewController(withIdentifier: "tabBarID")
                    
                                    self.view.window?.rootViewController = yeetVC
                                    self.view.window?.makeKeyAndVisible()
                                }
                            }
                    
                            }
                          }
                    }
                    else {
                        self.showError("Email Address is not verified")
                    }
            }
        }
    }
    }

}

