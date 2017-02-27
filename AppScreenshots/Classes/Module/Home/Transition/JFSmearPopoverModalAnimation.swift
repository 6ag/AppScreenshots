//
//  JFSmearPopoverModalAnimation.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFSmearPopoverModalAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    // modal动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        toView.alpha = 0.0
        transitionContext.containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration(using: nil), animations: {
            toView.alpha = 1.0
            }, completion: { (_) in
                transitionContext.completeTransition(true)
        }) 
    }
}
