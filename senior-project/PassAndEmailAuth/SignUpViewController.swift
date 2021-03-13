//
//  SignUp.swift
//  senior-project
//
//  Created by Chris Lin on 5/12/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UITextView!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signUpButton.isEnabled = true
        //CSS
        let lightBlue = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1).cgColor
        let lightBlueUI = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        Utilities.styleFilledButton(signUpButton, lightBlueUI, UIColor.white)
        Utilities.styleTextField(passwordTextField, lightBlue)
        Utilities.styleTextField(emailTextField, lightBlue)
        Utilities.styleTextField(usernameTextField, lightBlue)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.white])
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.white])
        //tap keyboard
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
        self.usernameTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doSignUp()
        return true
    }
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    func validateFields() -> String? {
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please Fill in All Fields"
        }
            
        
        return nil
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
        self.doSignUp()
    }
    
    func doSignUp() {
        self.errorLabel.alpha = 0
        self.signUpButton.isEnabled = false
        activityInd.startAnimating()
        self.view.endEditing(true)
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            
            // There's something wrong with the fields, show error message
            showError(error!)
        }
        else {
            
            // Create cleaned versions of the data
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    
                    // There was an error creating the user
                    self.showError(err!.localizedDescription)
                }
                else {
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if error != nil {
                            print(error!)
                        }
                    }
                    Global.password = password
                    Global.email = email
                    let uid = Auth.auth().currentUser?.uid
                    Global.uid = uid!
                    Global.username = username
                    self.resetView()
                    self.performSegue(withIdentifier: "yeetSegue", sender: nil)
                    }
                    
                    }

        }
    }
    }

