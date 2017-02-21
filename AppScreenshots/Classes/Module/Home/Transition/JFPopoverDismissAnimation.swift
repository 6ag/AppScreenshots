//
//  JFPopoverDismissAnimation.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFPopoverDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    // dismiss动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // 获取到modal出来的控制器的view
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        
        // 动画收起modal出来的控制器的view
        UIView.animate(withDuration: transitionDuration(using: nil), animations: {
            fromView?.transform = CGAffineTransform(translationX: SCREEN_WIDTH, y: 0)
        }, completion: { (_) in
            transitionContext.completeTransition(true)
        }) 
        
    }
}
