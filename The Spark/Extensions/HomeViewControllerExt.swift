//
//  HomeViewControllerExt.swift
//  Match
//
//  Created by Chandan Brown on 1/30/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
//import EZSwipeController

//extension HomeViewController: EZSwipeControllerDataSource {
//    func viewControllerData() -> [UIViewController] {
//        let profileVC = ProfileViewController()
//        
//        let searchVC = SearchViewController()
//        
//        let matchesVC = MatchesViewController()
//        
//        return [profileVC, searchVC, matchesVC]
//    }
//    
//    //    func titlesForPages() -> [String] {
//    //        return ["Profile", "Search", "Messages"]
//    //    }
//    
//    func indexOfStartingPage() -> Int {
//        return 1 // Starts from the first, search page (Middle Page)
//    }
//    
//    //    func changedToPageIndex(_ index: Int) {
//    //        // You can do anything from here, for now we'll just print the new index
//    //        print(index)
//    //    }
//    
//    func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar {
//        var title = ""
//        
//        if index == 0 {
//            title = ""
//        } else if index == 1 {
//            title = ""
//        } else if index == 2 {
//            title = ""
//        }
//        
//        let navigationBar = UINavigationBar()
//        navigationBar.barStyle = UIBarStyle.default
//        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
//        
//        let navigationItem = UINavigationItem(title: title)
//        navigationItem.hidesBackButton = true
//        
//        if index == 0 {
//            let homeButtonImage = UIImage(named: "Profile Image Shape")
//            let imageView = UIImageView(image: homeButtonImage)
//            let middleView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//            imageView.frame = CGRect(x: 0, y: 0, width: middleView.frame.width, height: middleView.frame.height)
//            middleView.addSubview(imageView)
//            navigationItem.titleView = middleView
//            
//        } else if index == 1 {
//        
//            let messageButtonImage = UIImage(named: "Tinted Messaging Image Shape")
//            let rightButtonItem = UIBarButtonItem(image: messageButtonImage, style: .plain, target: self, action: #selector(goToMessage))
//            rightButtonItem.tintColor = .white
//            rightButtonItem.imageInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 5)
//            
//            let profileButtonImage = UIImage(named: "Tinted Profile Image Shape")
//            let leftButtonItem = UIBarButtonItem(image: profileButtonImage, style: .plain, target: self, action: #selector(goToProfile))
//            leftButtonItem.tintColor = .white
//            leftButtonItem.imageInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//            
//            navigationBar.barTintColor = .black
//            navigationItem.leftBarButtonItem = leftButtonItem
//            navigationItem.rightBarButtonItem = rightButtonItem
//            
//        } else if index == 2 {
//            let homeButtonImage = UIImage(named: "Messaging Image Shape")
//            let imageView = UIImageView(image: homeButtonImage)
//            let middleView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//            imageView.frame = CGRect(x: 0, y: 0, width: middleView.frame.width, height: middleView.frame.height)
//            middleView.addSubview(imageView)
//            navigationItem.titleView = middleView
//        }
//        
//        navigationBar.pushItem(navigationItem, animated: true)
//        return navigationBar
//    }
//    
//    func disableSwipingForLeftButtonAtPageIndex(_ index: Int) -> Bool {
//        if index == 2 {
//            return true
//        }
//        return false
//    }
//    
//    func clickedLeftButtonFromPageIndex(_ index: Int) {
//        if index == 2 {
//            goToProfile()
//        }
//    }
//    
//    func disableSwipingForRightButtonAtPageIndex(_ index: Int) -> Bool {
//        if index == 0 {
//            return true
//        }
//        return false
//    }
//    
//    func clickedRightButtonFromPageIndex(_ index: Int) {
//        if index == 0 {
//            goToMessage()
//        }
//    }
//
//    
//    func goToProfile() {
//        self.moveToPage(0, animated: true)
//    }
//    
//    func goToSearch() {
//        self.moveToPage(1, animated: true)
//    }
//    
//    func goToMessage() {
//        self.moveToPage(2, animated: true)
//    }
//}
