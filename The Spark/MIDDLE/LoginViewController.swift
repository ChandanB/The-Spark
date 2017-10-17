//
//  ViewController.swift
//  FirebaseSocialLogin
//
//  Created by Chandan on 10/21/16.
//  Copyright © 2016 Lets Build That App. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import AVFoundation

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var snapController: ContainerViewController?
    
    lazy var facebookLoginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        return button
    }()
    
    var user = User(dictionary: [:])
    
    lazy var videoView: UIView = {
        let view = UIView()
        view.frame = self.view.bounds
        return view
    }()
    
    lazy var matchesTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Match"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Allura-Regular", size: 78)
        return label
    }()
    
    lazy var matchesTextLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Match"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Allura-Regular", size: 78)
        return label
    }()
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["email", "public_profile", "user_friends"]
        
        setupLoginRegisterButton()
        setupBackgroundView()
        
        //add our custom fb login button here
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = .blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom FB Login here", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.setTitleColor(.white, for: .normal)
        //   view.addSubview(customFBButton)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    func setupBackgroundView() {
        view.addSubview(videoView)
        view.sendSubview(toBack: videoView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //add AVCaptureVideoPreviewLayer as sublayer of self.view.layer
        videoPreviewLayer?.frame = self.videoView.bounds
        self.session!.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup camera
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
        let devices = videoDeviceDiscoverySession.devices
        // let device  = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        var frontCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        for element in devices {
            let element = element
            if element.position == AVCaptureDevice.Position.front {
                frontCamera = element
                break
            }
        }
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: frontCamera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            // ...
            stillImageOutput = AVCapturePhotoOutput()
            
            if session!.canAddOutput(stillImageOutput!) {
                session!.addOutput(stillImageOutput!)
                // ...
                // Configure the Live Preview
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                self.videoView.layer.addSublayer(videoPreviewLayer!)
                self.videoView.addLightBlurEffect()
            }
        }
    }
    
    func setupLoginRegisterButton() {
        view.addSubview(facebookLoginButton)
        view.addSubview(matchesTextLabel)
        view.addSubview(matchesTextLabel2)
        //need x, y, width, height constraints
        facebookLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookLoginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:5).isActive = true
        facebookLoginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        facebookLoginButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        
        matchesTextLabel.bottomAnchor.constraint(equalTo: facebookLoginButton.topAnchor, constant: -15).isActive = true
        matchesTextLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        matchesTextLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        
        matchesTextLabel2.topAnchor.constraint(equalTo: facebookLoginButton.bottomAnchor, constant: 20).isActive = true
        matchesTextLabel2.heightAnchor.constraint(equalToConstant: 80).isActive = true
        matchesTextLabel2.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
    }
    
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err as Any)
                return
            }
            self.showEmailAddress()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        showEmailAddress()
    }
    
    var resultdict: NSDictionary? = [:]
    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            print("Successfully logged in with our user: ", user ?? "")
            if let user = user {
                self.handleFacebookRegister(email: self.user.email!, name: self.user.name!, profileImageUrl: self.user.profileImageUrl!, uid: (user.uid), gender: self.user.gender!)
            }
        })
        
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, gender, name, email, picture.type(large)"]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            
            print(result ?? "")
            connection?.start()
            
            if let dictionary = result as? [String: AnyObject] {
                if (dictionary["email"] as? String) != nil {
                    // access individual value in dictionary
                    print ("This is the entire Dictionary: \(dictionary)")
                    self.user.gender = dictionary["gender"]! as? String
                    self.user.email = dictionary["email"]! as? String
                    self.user.id = dictionary["id"]! as? String
                    self.user.name = dictionary["name"]! as? String
                    
                    if let user_picture = dictionary["picture"] as? [String: AnyObject] {
                        if let data = user_picture["data"] as? [String: AnyObject] {
                            self.user.profileImageUrl = data["url"]! as? String
                        }
                    }
                }
                
                //                for (key, value) in dictionary {
                //                    // access all key / value pairs in dictionary
                //                }
                //
                //                if let nestedDictionary = dictionary["anotherKey"] as? [String: Any] {
                //                    // access nested dictionary values by key
                //                }
            }
            
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                return
            }
            
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                    self.user.setValuesForKeys(dictionary)
                    
                }
            }, withCancel: nil)
            
        }
        self.session?.stopRunning()
    }
}

