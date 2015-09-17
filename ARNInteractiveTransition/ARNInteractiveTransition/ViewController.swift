//
//  ViewController.swift
//  ARNInteractiveTransition
//
//  Created by xxxAIRINxxx on 2015/02/28.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    var animator : ARNTransitionAnimator!
    var modalVC : ModalViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 8.0
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.modalVC = storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as? ModalViewController
        self.modalVC.modalPresentationStyle = .Custom
        self.modalVC.tapCloseButtonActionHandler = { [weak self] in
            self!.animator.interactiveType = .None
        }
        
        self.setupAnimator()
    }
    
    @IBAction func tapMenuButton() {
        if self.presentedViewController == nil {
            self.animator.interactiveType = .None
            self.presentViewController(self.modalVC, animated: true, completion: nil)
        }
    }
    
    func setupAnimator() {
        self.animator = ARNTransitionAnimator(operationType: .Present, fromVC: self, toVC: modalVC!)
        self.animator.gestureTargetView = self.view
        self.animator.interactiveType = .Present
        self.animator.contentScrollView = self.tableView
        
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
                self!.view.frame.origin.y = endOriginY * percentComplete
                if self!.view.frame.origin.y < 0.0 {
                    self!.view.frame.origin.y = 0.0
                }
                self!.modalVC.view.alpha = 1.0 * percentComplete
            }
            
            self!.animator.presentationCompletionHandler = {(containerView: UIView, completeTransition: Bool) in
                UIApplication.sharedApplication().keyWindow!.addSubview(self!.view)
                if completeTransition {
                    self!.animator.interactiveType = .Dismiss
                    self!.tableView.panGestureRecognizer.state = .Cancelled
                    self!.tableView.userInteractionEnabled = false
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
                self!.view.frame.origin.y = endOriginY - (endOriginY * percentComplete)
                if self!.view.frame.origin.y < 0.0 {
                    self!.view.frame.origin.y = 0.0
                }
                self!.modalVC.view.alpha = 1.0 - (1.0 * percentComplete)
            }
        }
        
        self.animator.dismissalCompletionHandler = { [weak self] (containerView: UIView, completeTransition: Bool) in
            UIApplication.sharedApplication().keyWindow!.addSubview(self!.view)
            if completeTransition {
                self!.animator.interactiveType = .Present
                self!.tableView.userInteractionEnabled = true
                self!.animator.contentScrollView = self!.tableView
            }
        }
        
        modalVC.transitioningDelegate = self.animator
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        return cell
    }
}

