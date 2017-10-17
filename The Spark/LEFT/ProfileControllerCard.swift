//
//  RedViewController.swift
//  Match
//
//  Created by Chandan Brown on 1/30/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

class ProfileControllerCard: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let viewController = LoginViewController()
        viewController.snapController = ContainerViewController()
        let navController = UINavigationController(rootViewController: viewController)
        present(navController, animated: true, completion: nil)
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 130, height: 130))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = (imageView.frame.size.height/2)
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var imageViewBackground: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tintColor = .white
        label.text = self.user.name
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue", size: 30)
        return label
    }()
    
    lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is a one sentence summary about me hopefully this isn't too much"
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Light", size: 16)
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "San Francisco, California"
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-LightOblique", size: 16)
        return label
    }()
    
    var bioLabelHeightAnchor: NSLayoutConstraint?
    var url: String?
    var user = User(dictionary: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if FIRAuth.auth()?.currentUser != nil {
                guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                    return
                }
                
                FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.user = User(dictionary: dictionary)
                        self.setupUser()
                    }
                }, withCancel: nil)
            }
        }
    }
    
    func setupUser() {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        self.imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        
        self.view.addSubview((self.imageViewBackground))
        self.view.addSubview(self.usernameLabel)
        //  self.view.addSubview(self.bioLabel)
        self.view.addSubview(self.locationLabel)
        self.view.addSubview(self.profileImageView)
        
        self.view.sendSubview(toBack: (self.imageViewBackground))
        self.setupUsernameLabel()
        self.setupBioLabel()
        self.setupProfileImageView()
        
        if let profileImageUrl = user.profileImageUrl {
            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            updateImageViewBackground()
        }
        
        self.imageViewBackground.addBlurEffect()
        self.view.layer.cornerRadius = 18
    }
    
    func updateImageViewBackground() {
        if let profileImageUrl = user.profileImageUrl {
            self.imageViewBackground.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
    }
    
    func setupBioLabel() {
        // x, y, width, height
        locationLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        locationLabel.widthAnchor.constraint(equalTo:   view.widthAnchor, constant: -64).isActive = true
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 18)
    }
    
    func setupProfileImageView() {
        // x, y, width, height
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        profileImageView.bottomAnchor.constraint(equalTo: usernameLabel.topAnchor, constant: -42).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
    }
    
    func setupUsernameLabel() {
        // x, y, width, height
        
        usernameLabel.bottomAnchor.constraint(equalTo: locationLabel.topAnchor, constant: -4).isActive = true
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 31.39).isActive = true
    }
}
