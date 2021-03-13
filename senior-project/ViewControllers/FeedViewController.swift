//
//  FeedViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/12/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
//import FirebaseStorage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var feedTableView: UITableView!

    var posts = [yeetPost]()
    var hasDocument:Bool = false


    override func viewDidLoad() {

        super.viewDidLoad()
        feedTableView.register(PhotoPostCell.nib(), forCellReuseIdentifier: PhotoPostCell.identifier)
        feedTableView.register(TextPostCell.nib(), forCellReuseIdentifier: TextPostCell.identifier)
        feedTableView.delegate = self
        feedTableView.dataSource = self
        self.getPostsFromDatabase()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        if #available(iOS 10.0, *) {
            feedTableView.refreshControl = refreshControl
        } else {
            feedTableView.backgroundView = refreshControl
        }
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        self.posts = [yeetPost]()
        self.getPostsFromDatabase()
        refreshControl.endRefreshing()
    }
    func getYeetPost(_ arr:Array<String>) -> yeetPost {
        let ye = yeetPost()
        ye.username = arr[0]
        ye.type = arr[1]
        ye.textPost = arr[2]
        return ye
    }
    func getPostsFromDatabase() {
        let db = Firestore.firestore()
        let postsCol = db.collection("posts")
        self.hasDocument = false
        postsCol.order(by: "serverTimeStamp", descending: true).getDocuments { (snapshot, error) in
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
                            self.feedTableView.reloadData()
                        }
                        else {
                            print("error creating post obh")
                        }
                    }
                    else {
                        print("error creating post obj")
                    }
                }
                if self.hasDocument == false {
                    print("no posts")
                    self.feedTableView.reloadData()
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
