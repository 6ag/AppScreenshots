//
//  JFPhotoPopoverModalAnimation.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFPhotoPopoverModalAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    // modal动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        transitionContext.containerView.addSubview(toView)
        toView.alpha = 0.0
        
        UIView.animate(withDuration: transitionDuration(using: nil), animations: { 
            toView.alpha = 1.0
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
