//
//  DetailedViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/17/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class DetailedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var profileTableView: UITableView!
    var posts = [yeetPost]()
    var hasDocument:Bool = false
    var uid:String = ""
    var username:String = ""
    var arrayYeet: Array<String> = [] {
        didSet {
          configureView()
        }
      }


    override func viewDidLoad() {
        super.viewDidLoad()
        if configureView() {
            //setName and profile Pic
            self.setUsername()
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
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        self.posts = [yeetPost]()
        self.getPostsFromDatabase()
        refreshControl.endRefreshing()
    }
        
        // Do any additional setup after loading the view.
    func configureView() -> Bool{
        if self.arrayYeet != [] {
            self.uid = self.arrayYeet[1]
            self.username = self.arrayYeet[0]
            return true
        }
        return false
    }
    func setUsername() {
        navItem.title = self.username
    }
//    func loadProfilePic() {
//        let storageRef = Storage.storage().reference().child("images").child("profile photos").child(self.uid + "jpeg")
//        storageRef.downloadURL(completion: { (url, error) in
//            if error != nil {
//                print("bad")
//            }
//            else {
//                if let image = Global.nsCache.object(forKey: url!.absoluteString as NSString) {
//                    self.profilePIc.image = image
//
//                }
//                else {
//                    storageRef.getData(maxSize: 20 * 1024 * 1024) { data, error in
//                        if error != nil {
//                            // Uh-oh, an error occurred!
//                        } else {
//                            // Data for "images/island.jpg" is returned
//                            let image = UIImage(data: data!)
//                            self.profilePIc.image = image
//                            Global.nsCache.setObject(image!, forKey: url!.absoluteString as NSString)
//                        }
//                    }
//                }
//            }
//        })
//
//
//    }
    func getPostsFromDatabase() {
        self.hasDocument = false
        let db = Firestore.firestore()
        let postsCol = db.collection("posts")

        postsCol.whereField("uid", isEqualTo: self.uid).order(by: "serverTimeStamp", descending: true).getDocuments { (snapshot, error) in
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
                cell.hideDelete()
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell

                cell.configure(with: posts[indexPath.row])
                cell.hideDelete()
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }

    }

}
