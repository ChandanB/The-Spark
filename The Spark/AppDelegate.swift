//
//  AppDelegate.swift
//  Match
//
//  Created by Chandan Brown on 1/30/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
        return handled
    }
    
    func checkIfUserIsLoggedIn() {
        // If user is logged in
        window = UIWindow(frame: UIScreen.main.bounds)
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.window!.rootViewController = ContainerViewController()
                self.window!.makeKeyAndVisible()
            } else {
                self.window!.rootViewController = LoginViewController()
                self.window!.makeKeyAndVisible()
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Use Firebase library to configure APIs
        FIRApp.configure()
        
        checkIfUserIsLoggedIn()
        
        // get rid of black bar underneath navbar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UIApplication.shared.statusBarStyle = .lightContent
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
        //    statusBar.backgroundColor = UIColor.rgbLessAlpha(0, green: 0, blue: 0)
        }
        
        let statusBarBackgroundView = UIView()
        window?.addSubview(statusBarBackgroundView)
       
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        //        guard let viewController = window?.rootViewController as? ViewController, let interaction = userActivity.interaction else {
        //            return false
        //        }
        //
        //        var personHandle: INPersonHandle?
        //
        //        if let startVideoCallIntent = interaction.intent as? INStartVideoCallIntent {
        //            personHandle = startVideoCallIntent.contacts?[0].personHandle
        //        } else if let startAudioCallIntent = interaction.intent as? INStartAudioCallIntent {
        //            personHandle = startAudioCallIntent.contacts?[0].personHandle
        //        }
        //
        //        if let personHandle = personHandle {
        //            viewController.performStartCallAction(uuid: UUID(), roomName: personHandle.value)
        //        }
        //
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

