//
//  ProfileViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/13/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseUI


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    var imagePicker = UIImagePickerController()
    var posts = [yeetPost]()
    var hasDocument:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //formatting
        imagePicker.delegate = self
        profilePic.layer.masksToBounds = true
        profilePic.layer.cornerRadius = profilePic.bounds.width / 2
        profilePic.contentMode = .scaleAspectFill
        //setName and profile Pic
        self.setUsername()
        self.getPP()
        //registerfeed
        profileTableView.register(PhotoPostCell.nib(), forCellReuseIdentifier: PhotoPostCell.identifier)
        profileTableView.register(TextPostCell.nib(), forCellReuseIdentifier: TextPostCell.identifier)
        profileTableView.delegate = self
        profileTableView.dataSource = self
        self.getPostsFromDatabase()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        if #available(iOS 10.0, *) {
            profileTableView.refreshControl = refreshControl
        } else {
            profileTableView.backgroundView = refreshControl
        }
    }
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        self.posts = [yeetPost]()
        self.getPostsFromDatabase()
        refreshControl.endRefreshing()
    }
    
    func getPostsFromDatabase() {
        self.hasDocument = false
        let db = Firestore.firestore()
        let postsCol = db.collection("posts")
        postsCol.whereField("uid", isEqualTo: Global.uid).order(by: "serverTimeStamp", descending: true).getDocuments { (snapshot, error) in
             if error != nil {
                 print(error!, "error getting documents")
             }
             else if snapshot != nil {
                 for document in snapshot!.documents {
                    self.hasDocument = true
                     let post = yeetPost()
                     if post.getTypeFromDataBase(document) {
                         if post.fillInVars(document) {
                             self.posts.append(post)
                             self.profileTableView.reloadData()
                         }
                         else {
                             print("error creating post obh")
                            return
                         }
                     }
                     else {
                         print("error creating post obj")
                     }
                 }
                if self.hasDocument == false {
                    print("no posts")
                    self.profileTableView.reloadData()
                }

             }
         }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if posts.count > 0 {
            if posts[indexPath.row].type == "photo" {
                let cell = tableView.dequeueReusableCell(withIdentifier: PhotoPostCell.identifier, for: indexPath) as! PhotoPostCell
                cell.configure(with: posts[indexPath.row])
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell

                cell.configure(with: posts[indexPath.row])
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
        

    }
    
    func addTopBorder() {
       let thickness: CGFloat = 2.0
       let topBorder = CALayer()
       topBorder.frame = CGRect(x: 0.0, y: 0.0, width: profileTableView.frame.size.width, height: thickness)
       topBorder.backgroundColor = UIColor.black.cgColor

       profileTableView.layer.addSublayer(topBorder)
    }
    func setUsername() {
        let uid = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid!)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let username = document.get("username")
                if username != nil{
                    self.nameTextField.text = username! as? String
                }

            } else {
                print("Document does not exist for getting username")
            }
        }
    }
    
    func getPP() {
        let uid = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid!)
        docRef.getDocument { (document, err) in
            if let document = document, document.exists {
                let profilePath = document.get("profilePath")
                if profilePath != nil {
                    // Load the image using SDWebImage
                    let profRef = Storage.storage().reference().child(profilePath as! String)
                    profRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("bad")
                        }
                        else {
                            if let image = Global.nsCache.object(forKey: url!.absoluteString as NSString) {
                                self.profilePic.image = image
                                print(url!.absoluteString)
                            }
                            else {
                                profRef.getData(maxSize: 20 * 1024 * 1024) { (data, error) in
                                    if error != nil {
                                    // Uh-oh, an error occurred!
                                  } else {
                                    // Data for "images/island.jpg" is returned
                                        let image = UIImage(data: data!)
                                        self.profilePic.image = image
                                        Global.nsCache.setObject(image!, forKey: url!.absoluteString as NSString)
                                    }
                                }
                            }
                        }
                    }
                    )
            } else {
                    self.printError(err, "Error Doc does not exist for gettting profile image")
            }
            }
        }
    }

    
    func printError(_ error: Error?,_ message: String?) {
        if error != nil {
            print(error!)
        }
        if message != nil {
            print(message!)
        }

    }
    
    func showAlert(_ error: Error?,_ message: String?, _ alert: String) {
        self.printError(error, message)
        let yeetVC = UIStoryboard(name: "tabBar", bundle: nil).instantiateViewController(withIdentifier: "profilePicPopUpID") as! popUpViewController
        yeetVC.errorStr = alert
        
        self.view.window?.rootViewController = yeetVC
        self.view.window?.makeKeyAndVisible()
        
        
    }
    func updatePP(_ image: UIImage?) {
        let uid = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid!)
        let storageRef = Storage.storage().reference()
        docRef.getDocument { (document, err) in
            if let document = document, document.exists {
                let profilePath = document.get("profilePath")
                if profilePath != nil {
                    let reference = storageRef.child(profilePath! as! String)
                    guard let imageData = image?.jpegData(compressionQuality: 0.25) else {
                        self.showAlert(nil, "Error getting Jpeg Data for Updated Prof pic", "Error Changing Profile Pic Please Try Again")
                        return
                    }
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    reference.putData(imageData, metadata: metadata) { (yeetdata, error) in
                        guard yeetdata != nil else {
                        self.showAlert(error,"Error puting immage data in database for updated prof pic", "Error Changing Profile Pic Please Try Again")
                        return
                      }
                    reference.downloadURL { (url, error) in
                      guard let downloadURL = url else {
                        self.showAlert(error,"Error getting download url for updated prof pic", "Error Changing Profile Pic Please Try Again")
                        return
                        }
                        db.collection("users").document(uid!).setData(["profileURL": downloadURL.absoluteString], merge: true) { (error) in
                        if error != nil {
                              // Show error message
                            self.showAlert(error,"Error sending prof pic to database for updated prof pic", "Error Changing Profile Pic Please Try Again")
                                        }
                                    }
                              }
                          }
                      }
            }
            else {
                self.showAlert(err, "Document doesn't exist for updating prof pic", "Error Changing Profile Pic Please Try Again")
            }
        }
    }

    
    func openCamera() {
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
    //logout function
    @IBAction func logOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
        let yeetVC = UIStoryboard(name: "main", bundle: nil).instantiateViewController(withIdentifier: "homeVC")
        
        self.view.window?.rootViewController = yeetVC
        self.view.window?.makeKeyAndVisible()
        }
    
    
    @IBAction func editPP(_ sender: Any) {
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
    
    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.updatePP(pickedImage as UIImage?)
            let seconds: Double = 3.0
            DispatchQueue.global().async {
                let dispatchTime: DispatchTime = DispatchTime.now() + seconds
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    DispatchQueue.main.async {
                        self.getPP()
                }
            }
            }
            self.profilePic.image = pickedImage
    
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

