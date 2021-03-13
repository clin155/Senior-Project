//
//  Login.swift
//  senior-project
//
//  Created by Chris Lin on 5/12/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var forgotPass: UIButton!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UITextView!
    override func viewDidLoad() {
        self.loginButton.isEnabled = true
        super.viewDidLoad()
        let lightBlue = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1).cgColor
        let lightBlueUI = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        Utilities.styleFilledButton(loginButton, lightBlueUI, UIColor.white)
        Utilities.styleTextField(passwordTextField, lightBlue)
        Utilities.styleTextField(emailTextField, lightBlue)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.white])
        //hiding keyboard
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.doLogin()
        return true
    }
    
    func resetView() {
        self.activityInd.stopAnimating()
        self.loginButton.isEnabled = true
    }
    func showError(_ message:String) {
        self.resetView()
        self.forgotPass.isEnabled = true
        self.forgotPass.isHidden = false
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func validateFields() -> String? {
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please Fill in All Fields"
        }
            
        
        return nil
    }
    
    @IBAction func forgotPassTapped(_ sender: Any) {
    }
    @IBAction func loginTapped(_ sender: Any) {
        self.doLogin()
    }
    func doLogin() {
        self.activityInd.startAnimating()
        self.loginButton.isEnabled = false
        self.view.endEditing(true)
        let error = validateFields()

        if error != nil {
            showError(error!)
        }
        else {
        // Create cleaned versions of the text field
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                // Couldn't sign in
                self.showError(error!.localizedDescription)
            }
            else{
                if Auth.auth().currentUser?.isEmailVerified == false {
                    let yeetVC = UIStoryboard(name:
                    "main", bundle: nil).instantiateViewController(withIdentifier: "verifyVC")

                    self.view.window?.rootViewController = yeetVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                else {
                  //transition
                    let db = Firestore.firestore()
                    let uid = Auth.auth().currentUser?.uid
                    db.collection("users").document(uid!).getDocument() { (document, error) in
                        if let document = document, document.exists {
                            let username = document.get("username")
                            let email = document.get("email")
                            let password = document.get("password")
                            let profilePath = document.get("profilePath")
                            Global.email = email as! String
                            Global.username = username as! String
                            Global.uid = uid!
                            Global.password = password as! String
                            Global.profilePath = profilePath as! String
                        }
                    if error != nil {
                        print("error")
                        self.resetView()
                    }
                    }
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
}
