//
//  PhotoPostViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/13/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class PhotoPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var chooseFromLibButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var errorLabel: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    var imagePicker = UIImagePickerController()
    private var hasChangedPhoto: Bool = false
    var randomID:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitButton.isEnabled = true
        self.chooseFromLibButton.isEnabled = true
        imagePicker.delegate = self
        let lightBlueUI = UIColor.init(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        Utilities.styleFilledButton(chooseFromLibButton, lightBlueUI, UIColor.white)
        Utilities.styleFilledButton(submitButton, lightBlueUI, UIColor.white)
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    func resetView() {
        self.activityInd.stopAnimating()
        self.submitButton.isEnabled = true
        self.chooseFromLibButton.isEnabled = true
        self.isModalInPresentation = false

    }
    @IBAction func chooseFromLibTapped(_ sender: Any) {
                
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender as? UIView
            alert.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }

    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }

    func printAndShowError(_ error: Error?,_ errorType: String) {
        print(error!)
        print(errorType)
        showError("Error Uploading Post, Please Try Again")
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        self.activityInd.startAnimating()
        self.errorLabel.alpha = 0
        self.submitButton.isEnabled = false
        self.chooseFromLibButton.isEnabled = false
        self.isModalInPresentation = true
        if self.hasChangedPhoto {
            if captionTextView.text.count < 150 {
                if captionTextView.text.count > 0 {
                    //write to database
                    self.uploadToDatabase(photoImageView.image, captionTextView.text)
                }
                else {
                    showError("Please Fill in Caption")
                }
            }

            else {
                showError("Caption Must Be <= 150 Characters")
                
            }
        }
        else{
            showError("Please Attach A Photo")
        }
        
    }

    func showError(_ message:String) {
        self.resetView()
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func uploadToDatabase(_ image: UIImage?, _ caption: String) {
        self.randomID = UUID.init().uuidString

        guard let imageData = image?.jpeg(.low) else {return}
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let storageRef = Storage.storage().reference().child("images").child("posts").child(self.randomID + ".jpeg")
        storageRef.putData(imageData, metadata: metadata) { (yeetdata, error) in
            if error != nil {
                print(error!)
            }
            guard yeetdata != nil else {
                self.printAndShowError(error, "error storing photo post in storage")
                return
          }
        storageRef.downloadURL { (url, error) in
          guard let downloadURL = url else {
              self.printAndShowError(error, "error getting download URL for photo post")
              return
          }
            self.addToPostsCollection(downloadURL.absoluteString, caption)
            }
        }
    }
    
    func addToPostsCollection(_ url: String, _ caption: String) {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        let time = NSDate(timeIntervalSince1970: TimeInterval(timestamp))

        db.collection("posts").addDocument(data: ["type": "photo","uid":uid!, "postImageURL": url, "caption": caption, "serverTimeStamp":time, "username": Global.username, "profilePath":"/images/profile photos/"+uid!+".jpeg", "randomID":self.randomID]) { (error) in
                if error != nil {
                    self.printAndShowError(error, "error writing to database photo post")
                    
                }
                else {
                    self.showError("Success!")
                    self.submitButton.isEnabled = false
                    self.chooseFromLibButton.isEnabled = false
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
    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoImageView.image = pickedImage
            self.hasChangedPhoto = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
