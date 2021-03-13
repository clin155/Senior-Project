//
//  resetEmailViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/16/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChangeUsername: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var currEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newUsernameTextField: UITextField!
    @IBOutlet weak var errorLabel: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    var postDocID = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        submitButton.isEnabled = true
        //keyboard
        self.passwordTextField.delegate = self
        self.currEmailTextField.delegate = self
        self.newUsernameTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doReset()
        return true
    }
    @IBAction func submitTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.submitButton.isEnabled = false
        activityInd.startAnimating()
        self.errorLabel.alpha = 0
        doReset()
    }
    func doReset() {
        let user = Auth.auth().currentUser
        let credential: AuthCredential
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            
            // There's something wrong with the fields, show error message
            showError(error!)
        }
        else {
            
            // Create cleaned versions of the data
            let currEmail = currEmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let newUsername = newUsernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if currEmail == Global.email {
                if password == Global.password {
                    credential = EmailAuthProvider.credential(withEmail: currEmail, password: password)
                    user?.reauthenticate(with: credential, completion: { (result, error) in
                        if error != nil {
                            print(error!)
                        } else {
                            let db = Firestore.firestore()
                            db.collection("posts").whereField("uid", isEqualTo: Global.uid).getDocuments { (snapshot, err) in
                                if err != nil {
                                    print(err!)
                                } else {
                                    for document in snapshot!.documents {
                                        self.postDocID.append(document.documentID)
                                        
                                    }
                                }
                            }
                            let seconds: Double = 1.0
                            DispatchQueue.global().async {
                                let dispatchTime: DispatchTime = DispatchTime.now() + seconds
                                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                    DispatchQueue.main.async {
                                        let db = Firestore.firestore()
                                        for id in self.postDocID {
                                            db.collection("posts").document(id).setData(["username":newUsername], merge: true)
                                        }
                                    }
                                }
                            }
                            DispatchQueue.global().async {
                                let dispatchTime: DispatchTime = DispatchTime.now() + seconds
                                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                    DispatchQueue.main.async {
                                        let db = Firestore.firestore()
                                        db.collection("users").document(Global.uid).setData(["username":newUsername], merge: true)
                                        self.activityInd.stopAnimating()
                                        self.showError("Success!")
                                    }
                                }
                            }
                                }
                            }
                    
                    )
                }
                else {
                    showError("Incorrect Password")
                }
            }
            else {
                showError("Incorrect Email")
            }
        }
        
    }
    func validateFields() -> String? {
        if currEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            newUsernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please Fill in All Fields"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        activityInd.stopAnimating()
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
        


}
