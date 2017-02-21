//
//  JFPhotoPresentationController.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFPhotoPresentationController: UIPresentationController {
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        // 设置容器视图透明背景
        let bgView = UIView(frame: SCREEN_BOUNDS)
        bgView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        containerView?.insertSubview(bgView, at: 0)
        
        // 添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTappedContainerView))
        bgView.addGestureRecognizer(tap)
        
        // 呈现视图尺寸
        let popWidth: CGFloat = layoutHorizontal(iPhone6: 300)
        let popHeight: CGFloat = layoutVertical(iPhone6: 370)
        
        presentedView?.frame = CGRect(x: (SCREEN_WIDTH - popWidth) * 0.5, y: 20 + layoutVertical(iPhone6: 40), width: popWidth, height: popHeight)
    }
    
    /**
     容器视图区域的点击手势
     */
    @objc fileprivate func didTappedContainerView() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
