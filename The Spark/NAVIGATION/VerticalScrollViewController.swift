//
//  MiddleScrollViewController.swift
//  SnapchatSwipeView
//
//  Created by Chandan Brown on 1/30/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit

class VerticalScrollViewController: UIViewController, ContainerViewControllerDelegate {
    
    var middleVc = ChatViewController()
    var scrollView: UIScrollView!
    
    class func verticalScrollVcWith(middleVc: UIViewController,
                                    topVc: UIViewController?=nil,
                                    bottomVc: UIViewController?=nil) -> VerticalScrollViewController {
        let middleScrollVc = VerticalScrollViewController()
        
        middleScrollVc.middleVc = middleVc as! ChatViewController
        
        return middleScrollVc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        
        scrollView.frame = CGRect(x: view.x, y: view.y, width: view.width, height: view.height)
        self.view.addSubview(scrollView)
        
        let scrollWidth: CGFloat  = view.width
        var scrollHeight: CGFloat
        
            scrollHeight  = view.height
            middleVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            
            addChildViewController(middleVc)
            scrollView.addSubview(middleVc.view)
            middleVc.didMove(toParentViewController: self)
        
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
    }

    // MARK: - SnapContainerViewControllerDelegate Methods
    
    func outerScrollViewShouldScroll() -> Bool {
        if scrollView.contentOffset.y < middleVc.view.frame.origin.y || scrollView.contentOffset.y > 2*middleVc.view.frame.origin.y {
            return false
        } else {
            return true
        }
    }
    
}
