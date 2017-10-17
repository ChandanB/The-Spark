//
//  Users.swift
//  Lit
//
//  Created by Chandan Brown on 7/24/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import Firebase
import UIKit

class User: NSObject {
    var profileImageUrl : String?
    var email : String?
    var name  : String?
    var id    : String?
    var gender : String?
    var followersCount : String?
    var friendsCount : String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        profileImageUrl = dictionary["profileImageUrl"] as? String
        email = dictionary["email"] as? String
        name  = dictionary["name"] as? String
        id    = dictionary["id"] as? String
        
    }
}
