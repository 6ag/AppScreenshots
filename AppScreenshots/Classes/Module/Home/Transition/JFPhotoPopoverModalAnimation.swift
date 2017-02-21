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
        
        // 获取到需要modal的控制器的view
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        // 将需要modal的控制器的view添加到容器视图
        transitionContext.containerView.addSubview(toView)
        
        toView.transform = CGAffineTransform(scaleX: 1, y: 0)
        toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        // 动画缩放modal的控制器的view到正常大小
        UIView.animate(withDuration: transitionDuration(using: nil), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            toView.transform = CGAffineTransform.identity
            }, completion: { (_) -> Void in
                transitionContext.completeTransition(true)
        })
    }
}
