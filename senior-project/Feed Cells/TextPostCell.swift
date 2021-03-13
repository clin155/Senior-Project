//
//  TextPostCell.swift
//  senior-project
//
//  Created by Chris Lin on 5/14/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage
import Firebase

class TextPostCell: UITableViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var textPostTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    
    static let identifier = "TextPostCell"
    var docID:String = ""
    
    static func nib() -> UINib{
        return UINib(nibName: "TextPostCell", bundle: nil)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func deleteTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deletePost()
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
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

        topController.present(alert, animated: true, completion: nil)
        
    }
    }
    private func deletePost() {
        let db = Firestore.firestore()
        if self.docID == "" {
            print("errer in doc id")
        }
        else {
            db.collection("posts").document(self.docID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
    func configure(with model: yeetPost) {
        self.docID = "\(model.docID)"
        self.textPostTextView.text = "\(model.textPost)"
        self.usernameLabel.text = "\(model.username)"
        let storeRef = Storage.storage().reference().child("\(model.profilePath)")
        storeRef.downloadURL(completion: { (url, error) in
            if error != nil {
                print("bad")
            }
            else {
                if let image = Global.nsCache.object(forKey: url!.absoluteString as NSString) {
                    self.userImageView.image = image

                }
                else {
                    storeRef.getData(maxSize: 20 * 1024 * 1024) { data, error in
                        if error != nil {
                        // Uh-oh, an error occurred!
                      } else {
                        // Data for "images/island.jpg" is returned
                            let image = UIImage(data: data!)
                            self.userImageView.image = image
                            Global.nsCache.setObject(image!, forKey: url!.absoluteString as NSString)
                        }
                    }
                }
            }
        }
        )
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        let date = Date()
        let calendar = Calendar.current
        if calendar.component(.day, from: date) == calendar.component(.day, from: model.time) {
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.none //Set date style
        }
        else {
            dateFormatter.timeStyle = DateFormatter.Style.none
            dateFormatter.dateStyle = DateFormatter.Style.short
        }
        let localDate = dateFormatter.string(from: model.time)

        self.dateLabel.text = localDate
        
    }
    func hideDelete() {
        self.deleteButton.isHidden = true
        self.deleteButton.isEnabled = false
    }
}
