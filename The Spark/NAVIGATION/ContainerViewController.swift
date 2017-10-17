//
//  ContainerViewController.swift
//  SnapchatSwipeView
//
//  Created by Chandan Brown on 8/9/15.
//  Copyright (c) 2016 Gaming Recess. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import NVActivityIndicatorView

protocol ContainerViewControllerDelegate {
    func outerScrollViewShouldScroll() -> Bool
}

class ContainerViewController: UIViewController, UIScrollViewDelegate, NVActivityIndicatorViewable {
    var startColor: UIColor = .clear
    var context = CIContext(options: nil)
    var loading: NVActivityIndicatorView?
    var searching: SearchingEnum?
    
    lazy var loadingView: UIView = {
        let load = UIView()
        load.translatesAutoresizingMaskIntoConstraints = false
        return load
    }()
    
    var topVc = ProfileViewController()
    var middleVc = ChatViewController()
    var bottomVc = ProfileViewController()
    var leftVc = ProfileViewController()
    var rightVc = MatchesViewController()
    let viewController = LoginViewController()
    
    var directionLockDisabled: Bool!
    
    var horizontalViews = [UIViewController]()
    var veritcalViews = [UIViewController]()
    
    var initialContentOffset = CGPoint() // scrollView initial offset
    var middleVertScrollVc: VerticalScrollViewController!
    var scrollView: UIScrollView!
    var delegate: ContainerViewControllerDelegate?
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
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
        label.font = UIFont(name: "Allura-Regular", size: 32)
        return label
    }()
    
    lazy var beginSearchLabel: UILabel = {
        let label = UILabel()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startSearching))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Begin Search"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 42)
        return label
    }()
    
    lazy var searchingLabel: UILabel = {
        let label = UILabel()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startSearching))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Searching"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 42)
        label.isHidden = true
        return label
    }()
    
    let backButton: UIButton = {
        let imageView = UIButton(type: .custom)
        let image = UIImage(named: "Back Button")
        imageView.setImage(image, for: .normal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let settingsButton: UIButton = {
        let imageView = UIButton(type: .custom)
        let image = UIImage(named: "Settings Image Shape")
        imageView.setImage(image, for: .normal)
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
    
    let topLineView: UIView = {
        let view = UIView()
        // UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.10)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let allViewsView: UIView = {
        let view = UIView()
        // UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let messageImageIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Messaging Image Shape")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var profileImageIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Profile Image Shape")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var screenSize: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = self.navigationController?.navigationBar
        NotificationCenter.default.addObserver(self, selector:#selector(self.refreshView), name:NSNotification.Name.UIApplicationWillEnterForeground, object:UIApplication.shared)
        self.screenSize = UIScreen.main.bounds
        self.profileImageIcon.alpha = 0
        self.messageImageIcon.alpha = 0
        searching = SearchingEnum.notSearching
        setupVerticalScrollView()
        setupHorizontalScrollView()
        navBar?.isHidden = true
        addViewstoView()
        setupBackgroundView()
        makeLoadingView()
        setupbeginSearchLabel()
        setupMessageImageIcon()
    }
    
    @objc func refreshView() {
        print("View refreshed")
        self.view.setNeedsDisplay()
    }
    
    class func containerViewWith(_ leftVC: UIViewController,
                                 middleVC: UIViewController,
                                 rightVC: UIViewController,
                                 topVC: UIViewController?=nil,
                                 bottomVC: UIViewController?=nil,
                                 directionLockDisabled: Bool?=false) -> ContainerViewController {
        let container = ContainerViewController()
        
        container.directionLockDisabled = directionLockDisabled
        
        container.topVc = topVC as! ProfileViewController
        container.leftVc = leftVC as! ProfileViewController
        container.middleVc = middleVC as! ChatViewController
        container.rightVc = rightVC as! MatchesViewController
        container.bottomVc = bottomVC as! ProfileViewController
        return container
    }
    
    func setupBackgroundView() {
        view.addSubview(videoView)
        view.sendSubview(toBack: videoView)
    }
    
    @objc func startSearching() {
        if searching == .notSearching {
            searching = .isSearching
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.loading?.startAnimating()
            }
            UIView.transition(with: beginSearchLabel, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                self.setupCancelLabel()
                self.beginSearchLabel.text = "Cancel"
                self.beginSearchLabel.textColor = .red
                self.beginSearchLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 28)
            }, completion:nil)
        } else if self.beginSearchLabel.text == "Cancel" || searching == .isSearching {
            self.searchingLabel.isHidden = true
            self.loading?.stopAnimating()
            self.setupbeginSearchLabel()
            searching = .notSearching
            UIView.transition(with: beginSearchLabel, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                self.beginSearchLabel.text = "Begin Search"
                self.beginSearchLabel.textColor = .white
                self.beginSearchLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 42)
            }, completion:nil)
        }
    }
    
    func setupCancelLabel(){
        self.view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIView.animate(withDuration: 0.5, animations: {
                self.searchingLabel.isHidden = false
                self.searchingLabelBottomAnchor?.constant = -120
                self.view.layoutIfNeeded()
            })
        }
        self.beginSearchLabelBottomAnchor?.isActive = false
        UIView.animate(withDuration: 1, animations: {
            self.beginSearchLabelBottomAnchor?.constant = 210
            self.beginSearchLabelBottomAnchor?.isActive = true
            self.view.layoutIfNeeded()
        })
    }
    
    var beginSearchLabelBottomAnchor: NSLayoutConstraint?
    var beginSearchLeftAnchor: NSLayoutConstraint?
    
    var searchingLabelBottomAnchor: NSLayoutConstraint?
    var searchingLabelLeftAnchor: NSLayoutConstraint?
    
    var profileImageLeftAnchor: NSLayoutConstraint?
    var messageImageLeftAnchor: NSLayoutConstraint?
    var loadingViewLeftAnchor: NSLayoutConstraint?
    var matchesTextLeftAnchor: NSLayoutConstraint?
    var matchesTextBottomAnchor: NSLayoutConstraint?
    
    func addViewstoView() {
        allViewsView.addSubview(loadingView)
        allViewsView.addSubview(searchingLabel)
        allViewsView.addSubview(topView)
        allViewsView.addSubview(topLineView)
    }
    
    func setupbeginSearchLabel() {
        view.addSubview(beginSearchLabel)
        loadingView.addSubview(loading!)
        scrollView.addSubview(allViewsView)
        scrollView.sendSubview(toBack: allViewsView)
        scrollView.addSubview(matchesTextLabel)
        scrollView.sendSubview(toBack: matchesTextLabel)
        topView.addSubview(profileImageIcon)
        topView.addSubview(messageImageIcon)
        topView.addSubview(settingsButton)
        settingsButton.isHidden = true
        
        // x, y, width, height
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1, animations: {
            
            self.loadingViewLeftAnchor = self.loadingView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 430)
            self.loadingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            self.loadingView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            self.loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
            self.topView.heightAnchor.constraint(equalToConstant: 44).isActive = true
            self.topView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            self.topView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 320).isActive = true
            
            self.matchesTextLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
            self.matchesTextLabel.widthAnchor.constraint(equalTo: self.topView.widthAnchor).isActive = true
            self.matchesTextBottomAnchor = self.matchesTextLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            self.matchesTextLeftAnchor = self.matchesTextLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor)
            self.matchesTextBottomAnchor?.isActive = true
            self.matchesTextLeftAnchor?.isActive = true
            
            self.topLineView.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 1).isActive = true
            self.topLineView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 320).isActive = true
            self.topLineView.widthAnchor.constraint(equalToConstant: 1280).isActive = true
            self.topLineView.heightAnchor.constraint(equalToConstant: 0.45).isActive = true
            
            self.profileImageLeftAnchor = self.profileImageIcon.leftAnchor.constraint(equalTo: self.view.leftAnchor)
            self.profileImageIcon.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: -10).isActive = true
            self.profileImageIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
            self.profileImageIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
            self.profileImageLeftAnchor?.isActive = true
            
            self.settingsButton.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: -10).isActive = true
            self.settingsButton.centerXAnchor.constraint(equalTo: self.topView.centerXAnchor, constant: -460).isActive = true
            self.settingsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            self.settingsButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            
            self.beginSearchLabelBottomAnchor = self.beginSearchLabel.bottomAnchor.constraint(equalTo: (self.loadingView.bottomAnchor), constant: -10)
            self.beginSearchLeftAnchor = self.beginSearchLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 380)
            self.beginSearchLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.beginSearchLabel.widthAnchor.constraint(equalToConstant: 316).isActive = true
            self.beginSearchLabel.heightAnchor.constraint(equalToConstant: 61.39).isActive = true
            self.beginSearchLabelBottomAnchor?.isActive = true
            
            self.searchingLabelBottomAnchor = self.searchingLabel.bottomAnchor.constraint(equalTo: (self.loadingView.bottomAnchor), constant: 0)
            self.searchingLabelLeftAnchor = self.searchingLabel.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 320)
            self.searchingLabel.widthAnchor.constraint(equalToConstant: 316).isActive = true
            self.searchingLabel.heightAnchor.constraint(equalToConstant: 61.39).isActive = true
            self.searchingLabel.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor).isActive = true
            self.searchingLabelBottomAnchor?.isActive = true
            
            self.view.layoutIfNeeded()
        })
    }
    
    func makeLoadingView() {
        self.loading = NVActivityIndicatorView(frame: CGRect(x: self.loadingView.frame.midX, y: self.loadingView.frame.midY, width: 100, height: 100), type: NVActivityIndicatorType.lineScalePulseOut, color: .white, padding: NVActivityIndicatorView.DEFAULT_PADDING)
    }
    
    func setupMessageImageIcon() {
        self.messageImageLeftAnchor = self.messageImageIcon.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor)
        self.messageImageIcon.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: -10).isActive = true
        self.messageImageIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.messageImageIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.messageImageLeftAnchor?.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
                self.videoView.addBlurEffect()
            }
        }
    }
    
    
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
    
    func goToSettings() {
        
    }
    
    func setupVerticalScrollView() {
        middleVertScrollVc = VerticalScrollViewController.verticalScrollVcWith(middleVc: middleVc,
                                                                               topVc: topVc,
                                                                               bottomVc: bottomVc)
        delegate = middleVertScrollVc
    }
    
    func setupHorizontalScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        
        scrollView.frame = CGRect(x: view.x,
                                  y: view.y,
                                  width: view.width,
                                  height: view.height
        )
        
        self.view.addSubview(scrollView)
        
        let scrollWidth  = 3 * view.width
        let scrollHeight  = view.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        
        leftVc.view.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.width,
                                   height: view.height
        )
        
        middleVertScrollVc.view.frame = CGRect(x: view.width,
                                               y: 0,
                                               width: view.width,
                                               height: view.height
        )
        
        rightVc.view.frame = CGRect(x: 2 * view.width,
                                    y: 0,
                                    width: view.width,
                                    height: view.height
        )
        
        addChildViewController(leftVc)
        addChildViewController(middleVertScrollVc)
        addChildViewController(rightVc)
        
        scrollView.addSubview(leftVc.view)
        scrollView.addSubview(middleVertScrollVc.view)
        scrollView.addSubview(rightVc.view)
        
        leftVc.didMove(toParentViewController: self)
        middleVertScrollVc.didMove(toParentViewController: self)
        rightVc.didMove(toParentViewController: self)
        
        scrollView.contentOffset.x = middleVertScrollVc.view.frame.origin.x
        scrollView.delegate = self
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.initialContentOffset = scrollView.contentOffset
    }
    
    func fadeFromColor(toColor: UIColor, fromColor: UIColor, withPercentage: CGFloat) -> UIColor {
        
        var fromRed: CGFloat = 0.0
        var fromGreen: CGFloat = 0.0
        var fromBlue: CGFloat = 0.0
        var fromAlpha: CGFloat = 0.0
        
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        var toRed: CGFloat = 0.0
        var toGreen: CGFloat = 0.0
        var toBlue: CGFloat = 0.0
        var toAlpha: CGFloat = 0.0
        
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        //calculate the actual RGBA values of the fade colour
        let red = (toRed - fromRed) * withPercentage + fromRed;
        let green = (toGreen - fromGreen) * withPercentage + fromGreen;
        let blue = (toBlue - fromBlue) * withPercentage + fromBlue;
        let alpha = (toAlpha - fromAlpha) * withPercentage + fromAlpha;
        
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func blend(from: UIColor, to: UIColor, percent: Double) -> UIColor {
        var fR : CGFloat = 0.0
        var fG : CGFloat = 0.0
        var fB : CGFloat = 0.0
        var tR : CGFloat = 0.0
        var tG : CGFloat = 0.0
        var tB : CGFloat = 0.0
        
        from.getRed(&fR, green: &fG, blue: &fB, alpha: nil)
        to.getRed(&tR, green: &tG, blue: &tB, alpha: nil)
        
        let dR = tR - fR
        let dG = tG - fG
        let dB = tB - fB
        
        let rR = fR + dR * CGFloat(percent)
        let rG = fG + dG * CGFloat(percent)
        let rB = fB + dB * CGFloat(percent)
        
        return UIColor(red: rR, green: rG, blue: rB, alpha: 1.0)
    }
    
    // Pass in the scroll percentage to get the appropriate color
    func scrollColor(percent: Double, startColor: UIColor) -> UIColor {
        var start : UIColor
        var end : UIColor
        var perc = percent
        if percent < 0.5 {
            // If the scroll percentage is 0.0..<0.5 blend between yellow and green
            start = startColor
            end = UIColor.black
        } else {
            // If the scroll percentage is 0.5..1.0 blend between clear to black
            start = startColor
            end = UIColor.black
            perc -= 0.5
        }
        
        return blend(from: start, to: end, percent: perc * 2.0)
    }
    var colorArray = [UIColor.black, UIColor.clear, UIColor.white]
    var firstNumber: Int?
    var secondNumber: Int?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maximumHorizontalOffset = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset = scrollView.contentOffset.x
        let percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset
        
        if percentageHorizontalOffset >= 0.45 && percentageHorizontalOffset < 6.0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.beginSearchLabel.alpha = 0
            })
        }
        
        if percentageHorizontalOffset < 0.45 {
            self.searchingLabel.alpha = percentageHorizontalOffset * 2
        }
        
        if percentageHorizontalOffset == 0.5 {
            UIView.animate(withDuration: 0.2, animations: {
                self.beginSearchLabel.alpha = 1
            })
        }
        
        if percentageHorizontalOffset < 0.5 {
            UIView.animate(withDuration: 0.2, animations: {
                self.beginSearchLabel.alpha = 0
            })
            self.scrollView.backgroundColor = self.fadeFromColor(toColor: self.colorArray[1], fromColor: self.colorArray[0], withPercentage: percentageHorizontalOffset * 3)
            
            self.profileImageLeftAnchor?.constant = currentHorizontalOffset + UIScreen.main.bounds.width / 2.2
            
            self.searchingLabelLeftAnchor?.constant =  currentHorizontalOffset
            self.loadingViewLeftAnchor?.constant = currentHorizontalOffset + UIScreen.main.bounds.width / 2.2
            self.profileImageIcon.alpha = 0.09 / (percentageHorizontalOffset / 2)
            self.topLineView.alpha = percentageHorizontalOffset
            self.searchingLabel.alpha = percentageHorizontalOffset * 2
        }
        
        if percentageHorizontalOffset >= 0.5 {
            self.messageImageIcon.alpha = percentageHorizontalOffset
            self.profileImageIcon.alpha = percentageHorizontalOffset - 1
            self.messageImageLeftAnchor?.constant = currentHorizontalOffset + UIScreen.main.bounds.width / 2.2
        }
        
        if percentageHorizontalOffset < 0.7 && percentageHorizontalOffset >= 0.5 {
            self.messageImageIcon.alpha = percentageHorizontalOffset - 0.5
        }
        
        if percentageHorizontalOffset > 0.666667 {
            UIView.animate(withDuration: 0.05, animations: {
                self.profileImageIcon.alpha = 0
            })
            
            self.topLineView.backgroundColor = self.scrollColor(percent: Double(percentageHorizontalOffset), startColor: .white)
            self.scrollView.backgroundColor  = self.fadeFromColor(toColor: self.colorArray[0], fromColor: self.colorArray[1], withPercentage: (percentageHorizontalOffset - 0.666667) * 3)
        }
        
        if delegate != nil && !delegate!.outerScrollViewShouldScroll() && !directionLockDisabled {
            let newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
            self.scrollView!.setContentOffset(newOffset, animated:  false)
        }
    }
}
