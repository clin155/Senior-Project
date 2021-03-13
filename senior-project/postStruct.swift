//
//  postStruct.swift
//  senior-project
//
//  Created by Chris Lin on 5/14/20.
//  Copyright © 2020 Chris Lin. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class yeetPost  {
    var username: String = ""
    var caption: String = ""
    var textPost: String = ""
    var profilePath: String = ""
    var postImageURL: String = ""
    var type: String = ""
    var time: Date = NSDate(timeIntervalSince1970: TimeInterval(NSDate().timeIntervalSince1970)) as Date
    var fieldsFinished: Bool = false
    var docID:String = ""
    var postImagePath: String = ""
    
    //text post, username, type, time, userimage
    //username, caption, userImage, postImage, type, time
    public func getTypeFromDataBase(_ document: DocumentSnapshot) -> Bool{
        self.docID = document.documentID

        let type = document.get("type")
        if type != nil {
            self.type = type! as! String
            return true
        }
        else {
            return false
        }
    }
    public func fillInVars(_ document: DocumentSnapshot) -> Bool{
        let username = document.get("username")
        if username == nil {
            return false
        }
        let yeet = document.get("randomID")
        if yeet == nil {
            return false
        }
        let oh = yeet as! String
        self.postImagePath = "/images/posts/" + oh + ".jpeg"
        self.username = username as! String
        let profilePath = document.get("profilePath")
        if profilePath == nil {
            return false
        }
        self.profilePath = profilePath as! String
        
        let time = document.get("serverTimeStamp")
        if time == nil {
            return false
        }
        self.time = (time as! Timestamp).dateValue()
        if self.type == "text" {
            return fillInTextVars(document)
        }
        else if self.type == "photo" {
            return fillInPhotoVars(document)
        }
        else {
            print(self.type, "YESY ES YES")
            return false
        }
    }
    
    func fillInTextVars(_ document: DocumentSnapshot) -> Bool {
        let textPost = document.get("textPost")
        
        if textPost == nil  {
            return false
        }
        else {
            self.textPost = textPost! as! String
            return true
        }
    }
    func fillInPhotoVars(_ document: DocumentSnapshot) -> Bool {
        let postImageURL = document.get("postImageURL")
        if postImageURL == nil {
            return false
        }
        self.postImageURL = postImageURL! as! String
        let caption = document.get("caption")
        
        if caption == nil  {
            return false
        }
        else {
            self.caption = caption! as! String
            return true
        }
    
    }
}
