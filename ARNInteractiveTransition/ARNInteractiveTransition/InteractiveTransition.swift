//
//  InteractiveTransition.swift
//  ARNInteractiveTransition
//
//  Created by xxxAIRINxxx on 2017/09/07.
//  Copyright © 2017 xxxAIRINxxx. All rights reserved.
//

import Foundation
import ARNTransitionAnimator

final class InteractiveTransition : TransitionAnimatable {
    
    fileprivate weak var rootVC: ViewController!
    fileprivate weak var modalVC: ModalViewController!
    
    fileprivate var endOriginY: CGFloat = 0
    
    init(rootVC: ViewController, modalVC: ModalViewController) {
        self.rootVC = rootVC
        self.modalVC = modalVC
        
        self.modalVC.modalPresentationStyle = .overFullScreen
    }
    
    func prepareContainer(_ transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController) {
        if transitionType.isPresenting {
            containerView.addSubview(toVC.view)
            containerView.addSubview(fromVC.view)
        } else {
            containerView.addSubview(fromVC.view)
            containerView.addSubview(toVC.view)
        }
        fromVC.view.setNeedsLayout()
        fromVC.view.layoutIfNeeded()
        toVC.view.setNeedsLayout()
        toVC.view.layoutIfNeeded()
    }
    
    func willAnimation(_ transitionType: TransitionType, containerView: UIView) {
        self.rootVC.tableView.bounces = false
        endOriginY = containerView.bounds.height - 50
        
        if transitionType.isPresenting {
            rootVC.tableView.setContentOffset(rootVC.tableView.contentOffset, animated: false)
            modalVC.view.alpha = 0.0
        } else {
            self.modalVC.view.frame.origin.y = 0
            
        }
    }
    
    func updateAnimation(_ transitionType: TransitionType, percentComplete: CGFloat) {
        if transitionType.isPresenting {
            rootVC.view.frame.origin.y = endOriginY * percentComplete
            if rootVC.view.frame.origin.y < 0.0 {
                rootVC.view.frame.origin.y = 0.0
            }
            modalVC.view.alpha = 1.0 * percentComplete
        } else {
            rootVC.view.frame.origin.y = endOriginY - (endOriginY * percentComplete)
            if rootVC.view.frame.origin.y < 0.0 {
                rootVC.view.frame.origin.y = 0.0
            }
            modalVC.view.alpha = 1.0 - (1.0 * percentComplete)
        }
    }
    
    func finishAnimation(_ transitionType: TransitionType, didComplete: Bool) {
        self.setTransitionFinishSetting()
        self.rootVC.tableView.bounces = true
        
        if transitionType.isPresenting {
            if didComplete {
                rootVC.view.isUserInteractionEnabled = false
            } else {
                rootVC.view.isUserInteractionEnabled = true
            }
            UIApplication.shared.keyWindow?.addSubview(self.rootVC.view)
        } else {
            if didComplete {
                rootVC.view.isUserInteractionEnabled = true
                UIApplication.shared.keyWindow?.addSubview(self.rootVC.view)
            } else {
                UIApplication.shared.keyWindow?.addSubview(self.rootVC.view)
            }
        }
    }
    
    fileprivate func setTransitionStartSetting() {
        self.rootVC.tableView.isScrollEnabled = false
        self.rootVC.tableView.bounces = false
    }
    
    fileprivate func setTransitionFinishSetting() {
        self.rootVC.tableView.isScrollEnabled = true
        self.rootVC.tableView.bounces = true
    }
}

extension InteractiveTransition {
    
    func sourceVC() -> UIViewController { return self.rootVC }
    
    func destVC() -> UIViewController { return self.modalVC }
}


