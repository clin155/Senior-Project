//
//  TextPostViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/13/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class TextPostViewController: UIViewController {

    @IBOutlet weak var textPostTextView: UITextView!
    
    @IBOutlet weak var errorLabel: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = true
        let lightBlueUI = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        Utilities.styleFilledButton(submitButton, lightBlueUI, UIColor.white)
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    func showError(_ message:String) {
        self.resetView()
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func printAndShowError(_ error: Error?,_ errorType: String) {
        print(error!)
        print(errorType)
        showError("Error Uploading Post, Please Try Again")
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        if textPostTextView.text == "" {
            showError("Please Fill in Text")
        }
        
        else if textPostTextView.text.count > 250 {
            showError("Post Must be <= 250 chars")
         }
        else {
            activityInd.startAnimating()
            errorLabel.alpha = 0
            self.submitButton.isEnabled = false
            addToPostsCollection(textPostTextView.text)
            //write to database
        }
    }
    func resetView() {
        self.activityInd.stopAnimating()
        self.submitButton.isEnabled = true
    }
    func addToPostsCollection(_ textPost: String) {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        let time = NSDate(timeIntervalSince1970: TimeInterval(timestamp))

        db.collection("posts").addDocument(data: ["type": "text","uid": uid!, "textPost": textPost, "serverTimeStamp":time, "username": Global.username, "profilePath": "/images/profile photos/"+uid!+".jpeg", "randomID": "yeet!"]) { (error) in
                if error != nil {
                    self.printAndShowError(error, "error writing to database text post")
                    
                }
                else {
                    self.showError("Success!")
                    self.submitButton.isEnabled = false
                    let seconds: Double = 0.2
                    DispatchQueue.global().async {
                        let dispatchTime: DispatchTime = DispatchTime.now() + seconds
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            DispatchQueue.main.async {
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

}
