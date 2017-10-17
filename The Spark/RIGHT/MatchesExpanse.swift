//
//  MatchesExpanse.swift
//  Link
//
//  Created by Chandan Brown on 3/27/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import Firebase

class MatchesViewController: UIViewController {
    
    var viewController = MessagesTableViewController()
    
    let messageImageIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Messages Image Shape")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let topView: UIView = {
        let view = UIView()
        // UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(viewController)
        view.backgroundColor = .clear
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.layer.cornerRadius = 18
        setupViewControllerView()
    }
    
    func setupViewControllerView() {
        view.addSubview(viewController.view)
        view.addSubview(topView)
        view.addSubview(messageImageIcon)
        
        viewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        viewController.view.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -34).isActive = true
        viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        topView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        messageImageIcon.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        messageImageIcon.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        messageImageIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        messageImageIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
