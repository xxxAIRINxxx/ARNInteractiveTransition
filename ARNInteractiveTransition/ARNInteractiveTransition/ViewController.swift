//
//  ViewController.swift
//  ARNInteractiveTransition
//
//  Created by xxxAIRINxxx on 2015/02/28.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    weak var targetTableView : UITableView!
    
    var animator : ARNTransitionAnimator!
    var modalVC : ModalViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 8.0
        
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.modalVC = storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as? ModalViewController
        self.modalVC.modalPresentationStyle = .Custom
        self.modalVC.tapCloseButtonActionHandler = { [weak self] in
            self!.animator.interactiveType = .None
        }
        
        self.collectionView.registerNib(UINib(nibName: "MainCell", bundle: nil), forCellWithReuseIdentifier: "MainCell")
        
        self.setupAnimator()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateAnimationHandlers()
    }
    
    @IBAction func tapMenuButton() {
        if self.presentedViewController == nil {
            self.animator.interactiveType = .None
            self.presentViewController(self.modalVC, animated: true, completion: nil)
        }
    }
    
    func setupAnimator() {
        self.animator = ARNTransitionAnimator(operationType: .Present, fromVC: self, toVC: modalVC!)
        self.animator.usingSpringWithDamping = 0.8
        self.animator.gestureTargetView = self.view
        self.animator.interactiveType = .Present
        
        modalVC.transitioningDelegate = self.animator
    }
    
    func updateAnimationHandlers() {
        self.animator.interactiveType = .Present
        for cell in self.collectionView.visibleCells() {
            self.targetTableView = cell.tableView
            self.animator.contentScrollView = self.targetTableView
        }
        
        // Present
        
        self.animator.presentationBeforeHandler = { [weak self] (containerView: UIView, transitionContext:
            UIViewControllerContextTransitioning) in
            self!.animator.direction = .Bottom
            
            containerView.addSubview(self!.modalVC.view)
            containerView.addSubview(self!.view)
            
            self!.modalVC.view.layoutIfNeeded()
            
            let endOriginY = CGRectGetHeight(containerView.bounds) - 50
            self!.modalVC.view.alpha = 0.0
            
            self!.animator.presentationCancelAnimationHandler = { (containerView: UIView) in
                self!.view.frame.origin.y = 0.0
                self!.modalVC.view.alpha = 0.0
            }
            
            self!.animator.presentationAnimationHandler = { [weak self] (containerView: UIView, percentComplete: CGFloat) in
                let _percentComplete = percentComplete >= 0 ? percentComplete : 0
                self!.view.frame.origin.y = endOriginY * _percentComplete
                if self!.view.frame.origin.y < 0.0 {
                    self!.view.frame.origin.y = 0.0
                }
                self!.modalVC.view.alpha = 1.0 * _percentComplete
            }
            
            self!.animator.presentationCompletionHandler = {(containerView: UIView, completeTransition: Bool) in
                UIApplication.sharedApplication().keyWindow!.addSubview(self!.view)
                if completeTransition {
                    self!.animator.interactiveType = .Dismiss
                    self!.targetTableView.panGestureRecognizer.state = .Cancelled
                    self!.collectionView.userInteractionEnabled = false
                    self!.animator.contentScrollView = nil
                }
            }
        }
        
        // Dismiss
        
        self.animator.dismissalBeforeHandler = { [weak self] (containerView: UIView, transitionContext: UIViewControllerContextTransitioning) in
            self!.animator.direction = .Top
            let endOriginY = CGRectGetHeight(containerView.bounds) - 50
            self!.modalVC.view.alpha = 1.0
            
            self!.animator.dismissalCancelAnimationHandler = { (containerView: UIView) in
                self!.view.frame.origin.y = endOriginY
                self!.modalVC.view.alpha = 1.0
            }
            
            self!.animator.dismissalAnimationHandler = {(containerView: UIView, percentComplete: CGFloat) in
                let _percentComplete = percentComplete >= 0 ? percentComplete : 0
                self!.view.frame.origin.y = endOriginY - (endOriginY * _percentComplete)
                if self!.view.frame.origin.y < 0.0 {
                    self!.view.frame.origin.y = 0.0
                }
                self!.modalVC.view.alpha = 1.0 - (1.0 * _percentComplete)
            }
        }
        
        self.animator.dismissalCompletionHandler = { [weak self] (containerView: UIView, completeTransition: Bool) in
            UIApplication.sharedApplication().keyWindow!.addSubview(self!.view)
            if completeTransition {
                self!.animator.interactiveType = .Present
                self!.collectionView.userInteractionEnabled = true
                self!.animator.contentScrollView = self!.targetTableView
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MainCell", forIndexPath: indexPath) as! MainCell
        
        cell.tableView.setContentOffset(CGPointZero, animated: false)
        self.updateAnimationHandlers()
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if  scrollView == self.collectionView {
            self.targetTableView.scrollEnabled = false
            self.animator.interactiveType = .None
        } else if scrollView == self.targetTableView {
            self.collectionView.scrollEnabled = false
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.collectionView.scrollEnabled = true
        self.targetTableView.scrollEnabled = true
    }
}

