//
//  JFPopoverModalAnimation.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFPopoverModalAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    // modal动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // 获取到需要modal的控制器的view
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        // 将需要modal的控制器的view添加到容器视图
        transitionContext.containerView.addSubview(toView)
        
        toView.transform = CGAffineTransform(translationX: SCREEN_WIDTH, y: 0)
        
        UIView.animate(withDuration: transitionDuration(using: nil), animations: {
            toView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (_) in
                transitionContext.completeTransition(true)
        }) 
    }
}
