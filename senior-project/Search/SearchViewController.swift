//
//  Search.swift
//  senior-project
//
//  Created by Chris Lin on 5/12/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UITabBarControllerDelegate {


    
    @IBOutlet weak var tableView: UITableView!
    var users = Array<Array<String>>()
    var filteredUsers = Array<Array<String>>()
    let searchController = UISearchController(searchResultsController: nil)
    let getUsers:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search Usernames"
        // 4
        navigationItem.searchController = searchController
        // 5
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        self.getFromDatabase(firstRun: true)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    func getFromDatabase(firstRun:Bool = false) {
        self.users = Array<Array<String>>()
        self.filteredUsers = Array<Array<String>>()
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snapshot, error) in
            if error != nil {
                print(error!)
            } else {
                for document in snapshot!.documents {
                    let uid = document.get("uid")
                    let username = document.get("username")
                    self.users.append([username as! String,uid as! String])
                    
                }
                if firstRun {
                    self.tableView.reloadData()
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
          segue.identifier == "detailSegue",
          let indexPath = tableView.indexPathForSelectedRow,
          let detailViewController = segue.destination as? DetailedViewController
          else {
            return
        }
        let yeet:Array<String>
        if isFiltering {
            yeet = filteredUsers[indexPath.row]
        } else {
            yeet = users[indexPath.row]
        }
        detailViewController.arrayYeet = yeet
    }
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    func filterContentForSearchText(_ searchText: String) {
        filteredUsers = Array<Array<String>>()
        for user in users {
            if user[0].lowercased().starts(with: (searchText.lowercased()))
             {
                filteredUsers.append(user)
            }
        for user in users {
            if user[0].lowercased().contains(searchText.lowercased()) {
                if filteredUsers.contains(user) == false {
                    filteredUsers.append(user)
                }

            }
        }
      tableView.reloadData()
    }
    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredUsers.count
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if isFiltering {
            cell.textLabel?.text = filteredUsers[indexPath.row][0]
        } else {
            cell.textLabel?.text = users[indexPath.row][0]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: nil)
    }
}
