//
//  JFPresentationController.swift
//  popoverDemo
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFPresentationController: UIPresentationController {
    
    /// 关闭按钮
    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: 0, y: 20, width: layoutHorizontal(iPhone6: 44), height: layoutVertical(iPhone6: 44))
        closeButton.setImage(UIImage(named: "nav_return"), for: .normal)
        closeButton.alpha = 0.0
        closeButton.addTarget(self, action: #selector(didTappedCloseButton(_:)), for: .touchUpInside)
        return closeButton
    }()
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        presentedView?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        
        containerView?.addSubview(closeButton)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.closeButton.alpha = 1.0
            self.closeButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) - 0.01)
        })
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: SettingViewControllerWillPresent), object: nil)
    }
    
    /**
     容器视图区域的点击手势
     */
    @objc fileprivate func didTappedCloseButton(_ button: UIButton) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: SettingViewControllerWillDismiss), object: nil)
        
        UIView.animate(withDuration: 0.5, animations: { 
            button.imageView?.transform = CGAffineTransform.identity
            button.alpha = 0.0
            }, completion: { (_) in
                button.removeFromSuperview()
        }) 
        
        // 会触发自定义dismiss动画
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
