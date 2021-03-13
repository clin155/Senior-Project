//
//  newPostViewController.swift
//  senior-project
//
//  Created by Chris Lin on 5/14/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit

class newPostViewController: UIViewController {

    @IBOutlet weak var textPostButton: UIButton!
    @IBOutlet weak var photoPostButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        textPostButton.backgroundColor = UIColor.init(red: 0/255, green: 204/255, blue: 0/255, alpha: 1.0)
        photoPostButton.backgroundColor = UIColor.init(red: 0/255, green: 204/255, blue: 0/255, alpha: 1.0)

        // Do any additional setup after loading the view.
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
