//
//  ViewController.swift
//  ARNInteractiveTransition
//
//  Created by xxxAIRINxxx on 2015/02/28.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!
    
    var animator : ARNTransitionAnimator!
    var modalVC : ModalViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.layer.cornerRadius = 8.0
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "ModalViewController") as? ModalViewController
        self.modalVC.modalPresentationStyle = .overCurrentContext
        self.modalVC.tapCloseButtonActionHandler = { [weak self] in
            self?.modalVC.dismiss(animated: true, completion: nil)
        }
        
        self.setupAnimator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController viewWillDisappear")
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return false
    }
    
    @IBAction func tapMenuButton() {
        if self.presentedViewController == nil {
            self.present(self.modalVC, animated: true, completion: nil)
        }
    }
    
    func setupAnimator() {
        let animation = InteractiveTransition(rootVC: self, modalVC: self.modalVC)
        
        let gestureHandler = TransitionGestureHandler(targetView: self.tableView, direction: .bottom)
        gestureHandler.panCompletionThreshold = 15.0
        
        self.animator = ARNTransitionAnimator(duration: 1.0, animation: animation)
        self.animator?.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)
        
        modalVC.transitioningDelegate = self.animator
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        return cell
    }
}

