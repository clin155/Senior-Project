//
//  deleteAccountViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/16/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
class DeleteAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var errorLabel: UITextView!
    
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetView()
        blurView.bounds = self.view.bounds
        popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: self.view.bounds.height*0.2)
        //hiding keyboard
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.showPopUp()
        return true
    }
    func validateFields() -> String? {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please Fill in All Fields"
        }
            
        
        return nil
    }
    
    
    func resetView() {
        activityInd.stopAnimating()
        submitButton.isEnabled = true
        errorLabel.alpha = 0
        self.isModalInPresentation = false

    }
    func showError(_ message:String) {
        resetView()
        errorLabel.text = message
        errorLabel.alpha = 1
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
    
    @IBAction func yesButton(_ sender: Any) {
        errorLabel.alpha = 0
        activityInd.startAnimating()
        submitButton.isEnabled = false
        self.isModalInPresentation = true
        animateOut(blurView)
        animateOut(popUpView)
        var postsDocID = Array<Array<String>>()
        let db = Firestore.firestore()
        db.collection("posts").whereField("uid", isEqualTo: Global.uid).getDocuments { (snapshot, err) in
            if err != nil {
                print(err!)
            } else {
                for document in snapshot!.documents {
                    let postID = document.get("randomID")
                    let type = document.get("type")
                    postsDocID.append([document.documentID, postID as! String, type as! String])
                    
                }
            }
        }
            

        let storageRef = Storage.storage().reference()
        // Create a reference to the file to delete
        let desertRef = storageRef.child(Global.profilePath)

        // Delete the file
        desertRef.delete { error in
            if error != nil {
                print(error!)
          } else {
                let seconds: Double = 5.0
                DispatchQueue.global().async {
                    let dispatchTime: DispatchTime = DispatchTime.now() + seconds
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        DispatchQueue.main.async {
                            let batch = db.batch()
                                for id in postsDocID {
                                    let yeet = id[0] as String
                                    let postID = id[1] as String
                                    let type = id[2] as String
                                    if type == "photo" {
                                        let ref = storageRef.child("images").child("posts").child(postID + ".jpeg")
                                        ref.delete { (error) in
                                            if error != nil {
                                                print(error!)
                                            }
                                        
                                        }
                                    }
                                    batch.deleteDocument(db.collection("posts").document(yeet))

                                }
                            batch.deleteDocument(db.collection("users").document(Global.uid))
                            batch.commit(completion: { (error) in
                                if error != nil {
                                    print(error!)
                                }
                                else {
                                    let seconds: Double = 5.0
                                    DispatchQueue.global().async {
                                        let dispatchTime: DispatchTime = DispatchTime.now() + seconds
                                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                            DispatchQueue.main.async {
                                                do {
                                                    let user = Auth.auth().currentUser
                                                    try Auth.auth().signOut()
                                                    user?.delete { error in
                                                      if error != nil {
                                                        // An error happened.
                                                        print(error!)
                                                      } else {
                                                        self.activityInd.stopAnimating()
                                                        let yeetVC = UIStoryboard(name:
                                                        "main", bundle: nil).instantiateViewController(withIdentifier: "homeVC")

                                                        self.view.window?.rootViewController = yeetVC
                                                        self.view.window?.makeKeyAndVisible()
                                                      }
                                                    }

                                                } catch let signOutError as NSError {
                                                    print ("Error signing out: %@", signOutError)
                                                }
                                            }
                                        }
                                    }
                                    print("Batch write succeeded.")
                                }
                            })
                        }
                    }
                }
                    

                
          }
        }
    }
    
    
    @IBAction func noButton(_ sender: Any) {
        animateOut(blurView)
        animateOut(popUpView)
    }
    @IBAction func submitTapped(_ sender: Any) {
        self.view.endEditing(true)
        showPopUp()
    }
    
    func showPopUp() {
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
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if email == Global.email {
                if password == Global.password {
                    credential = EmailAuthProvider.credential(withEmail: email, password: password)
                    user?.reauthenticate(with: credential, completion: { (result, error) in
                        if error != nil {
                            print(error!)
                        } else {
                            self.resetView()
                            self.animateIn(self.blurView)
                            self.animateIn(self.popUpView)
                        }
                    })
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
