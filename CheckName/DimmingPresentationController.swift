//
//  DimmingPresentationController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/4/3.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() { // 换新的背景
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1 }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0 }, completion: nil)
        }
    }
    
    override var shouldRemovePresentersView: Bool {
        return false // 让之前的视图不要消失
    }
}
